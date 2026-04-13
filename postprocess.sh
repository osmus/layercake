#!/bin/sh

# Spatially sorts a GeoParquet file by Hilbert curve and compresses with ZSTD.
# Usage: postprocess.sh <input.parquet> <output.parquet>

set -eu

duckdb << EOF | cat
LOAD spatial;

COPY (
    SELECT *
    FROM '$1'
    ORDER BY ST_Hilbert(
        geometry,
        ST_Extent(ST_MakeEnvelope(-180, -90, 180, 90))
    )
)
TO '$2' (
    FORMAT PARQUET,
    COMPRESSION ZSTD,
    COMPRESSION_LEVEL 10
    -- TBD: Partitioning; row group size by bytes?
);
EOF
