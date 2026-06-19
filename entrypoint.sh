#!/bin/sh

set -eu

if [[ $# -lt 2 ]]; then
    echo "Error: Expected ./entrypoint.sh <input_file> <output_dir>"
    exit 1
fi

TEST=0
for arg in "$@"; do
  case $arg in
    --test)        TEST=1 ;;
  esac
done

echo "Extracting feature layers from $1"
./process.sh "$@"

if [ "$TEST" = "0" ]; then
  for input_file in "$2"/*.parquet; do
    echo "Sorting and compressing $input_file"
    output_file="$2/$(basename -s .parquet $input_file)-optimized.parquet"
    ./postprocess.sh $input_file $output_file
    mv $output_file $input_file
  done
fi