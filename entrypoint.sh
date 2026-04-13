#!/bin/sh

set -eu

echo "Extracting feature layers from $1"
./process.sh "$@"

for input_file in out/*.parquet; do
  echo "Sorting and compressing $input_file"
  output_file="out/$(basename -s .parquet $input_file)-optimized.parquet"
  ./postprocess.sh $input_file $output_file
  mv $output_file $input_file
done
