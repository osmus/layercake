#!/bin/sh

# Extracts thematic layers from an OSM PBF file into GeoParquet files
# using DuckDB with the osmium and spatial extensions.
#
# Usage: process.sh <input.osm.pbf> <output_dir> [--buildings] [--highways] ...
#                   [--osmium-index-type=TYPE] [--duckdb-memory-limit=LIMIT]
#
# --osmium-index-type sets osmium's node location index type. The default
# is 'flex_mem' which works well for both small and large extracts. For
# full planet builds, use dense_file_array if you don't have enough RAM
# to fit the entire index in memory.
#
# --duckdb-memory-limit sets DuckDB's memory_limit setting (e.g. '64GB')

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT="$1"
OUTPUT_DIR="$2"
shift 2

# Parse optional layer flags
BUILDINGS=0; HIGHWAYS=0; BOUNDARIES=0; SETTLEMENTS=0; PARKS=0
ALL=1
OSMIUM_INDEX_TYPE=""
DUCKDB_MEMORY_LIMIT=""

for arg in "$@"; do
  case $arg in
    --buildings)   BUILDINGS=1; ALL=0 ;;
    --highways)    HIGHWAYS=1; ALL=0 ;;
    --boundaries)  BOUNDARIES=1; ALL=0 ;;
    --settlements) SETTLEMENTS=1; ALL=0 ;;
    --parks)       PARKS=1; ALL=0 ;;
    --osmium-index-type=*)   OSMIUM_INDEX_TYPE="${arg#*=}" ;;
    --duckdb-memory-limit=*) DUCKDB_MEMORY_LIMIT="${arg#*=}" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

if [ "$ALL" = "1" ]; then
  BUILDINGS=1; HIGHWAYS=1; BOUNDARIES=1; SETTLEMENTS=1; PARKS=1
fi

mkdir -p "$OUTPUT_DIR"

# Run a layer's SQL file through DuckDB, prepending shared macros and
# substituting {{INPUT}} and {{OUTPUT}} placeholders.
run_layer() {
  local name="$1"
  local output="${OUTPUT_DIR}/${name}.parquet"
  echo "Extracting ${name} layer"
  {
    cat "${SCRIPT_DIR}/sql/macros.sql"
    [ -n "$DUCKDB_MEMORY_LIMIT" ] && echo "SET memory_limit = '${DUCKDB_MEMORY_LIMIT}';"
    [ -n "$OSMIUM_INDEX_TYPE" ] && echo "SET osmium_index_type = '${OSMIUM_INDEX_TYPE}';"
    cat "${SCRIPT_DIR}/sql/${name}.sql"
  } | \
    sed "s|{{INPUT}}|${INPUT}|g; s|{{OUTPUT}}|${output}|g" | \
    duckdb --unsigned
}

[ "$BUILDINGS" = "1" ]   && run_layer buildings
[ "$HIGHWAYS" = "1" ]    && run_layer highways
[ "$BOUNDARIES" = "1" ]  && run_layer boundaries
[ "$SETTLEMENTS" = "1" ] && run_layer settlements
[ "$PARKS" = "1" ]       && run_layer parks

echo "Done"
