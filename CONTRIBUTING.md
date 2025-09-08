# Contributing to Layercake

Thanks for your interest in helping to improve Layercake. Here's some info on how to get started.

## Project structure

Layercake consists of few scripts which work together to read an `.osm.pbf` file, extract some elements, and write them out to GeoParquet files.

- First, `process_osm.py` is run. It reads the OSM PBF file using [pyosmium](https://osmcode.org/pyosmium/), and writes output Parquet files using [pyarrow](https://arrow.apache.org/docs/python/index.html). Each layer is defined in a separate Handler class in the `src` directory (e.g `src/highways.py`). The Handler's job is to choose which OSM elements belong in the layer, and which tags to include on each feature.
- Afterwards, `postprocess.sh` is run on each layer. This script uses [DuckDB](https://duckdb.org/) to sort and compress the parquet files, which improves query performance for users.

## Building Layercake data locally

The easiest way to run Layercake locally is to build a container image from the provided Dockerfile, then run it. You'll need to mount directories into the container to provide the input OSM PBF file, and to store the output data (otherwise it'll be lost when the container exits).

```
$ podman build -t layercake/builder .
$ podman run --rm \
    -v $(pwd)/data:/run/layercake/data \
    -v $(pwd)/out:/run/layercake/out \
    layercake/builder data/planet.osm.pbf out/
```

Alternately, you may wish to run Layercake directly (without a container). This is useful on systems like macOS where containers must be run in a Linux VM, causing significant overhead.

To run Layercake directly, first install the necessary dependencies. Currently they are `python`, `duckdb`, and the Python packages listed in `requirements.txt`.

Then, run `python process_osm.py`, specifying your input OSM PBF file and desired output directory. After that, you may optionally run `postprocess.sh` on each layer. See `entrypoint.sh` for an example of how to run these tools (the entrypoint script is what the above container runs by default).

For development purposes, it's best to run Layercake on a small `.osm.pbf` file (like for a metropolitan area, a US State, or a small country), rather than on the entire planet. The former should take a few minutes; the latter might take many hours, depending on your hardware. Suitable extracts can be downloaded from [Geofabrik](https://download.geofabrik.de/) or from [slice.openstreetmap.us](https://slice.openstreetmap.us).

## Adding new layers

Before working on a new layer definition, please discuss your idea with the maintainers, either on GitHub or in the `#layercake` channel on the OSM US Slack.

To add a new layer, create a new GeoParquetWriter subclass (see existing layers for guidance), and then register it in the `LAYERS` dictionary in `process_osm.py`.

## Modifying existing layers

Feel free to request new columns (tags) to add to existing layers, or simply make a PR.

## Reporting problems

If you find an issue with Layercake (such as certain features being processed incorretly), please open a bug on GitHub. If there's an error _in the data itself_, that is most likely a problem with the upstream OpenStreetMap data. You can check the data yourself on [openstreetmap.org](https://openstreetmap.org), and edit the map to fix the issue if it hasn't already been fixed.

## General PR guidelines

When sending a PR, please include a clear description of what it does. This helps the maintainers review it efficiently.

We don't currently enforce style checks in CI, but do periodically format the codebase with [`ruff`](https://docs.astral.sh/ruff/). If you do the same, it will reduce the chance of merge conflicts.
