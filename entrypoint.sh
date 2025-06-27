#!/bin/sh

. venv/bin/activate

python process_osm.py "$@"
