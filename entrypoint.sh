#!/bin/sh

# add duckdb cli to path
export PATH='/root/.duckdb/cli/latest':$PATH

# activate python virtual environment
. venv/bin/activate

python process_osm.py "$@"

for input_file in out/*.parquet; do
  output_file="out/$(basename -s .parquet $input_file)-optimized.parquet"
  ./postprocess.sh $input_file $output_file
  mv $output_file $input_file
done
