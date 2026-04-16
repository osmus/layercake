# Contributing to Layercake

Thanks for your interest in helping to improve Layercake. Here's some info on how to get started.

## Project structure

Layercake consists of a few scripts which work together to read an `.osm.pbf` file, extract features into thematic layers, and write them out as GeoParquet files.

- Each layer is defined as a SQL file in the `sql/` directory (e.g. `sql/highways.sql`). These SQL scripts are executed with [DuckDB](https://duckdb.org/), using the [duckdb-osmium](https://github.com/jake-low/duckdb-osmium/) extension to read OSM PBF input files and the [spatial](https://duckdb.org/docs/extensions/spatial/overview.html) extension to write GeoParquet files. Shared macros are defined in `sql/macros.sql`.
- `process.sh` is a shell script that takes an input OSM PBF file and an output directory, and runs all of the SQL scripts to generate each layer (writing them to the output directory).
- `postprocess.sh` is run on each layer's output. It uses DuckDB to spatially sort and compress the parquet files, which improves query performance for users.
- `entrypoint.sh` ties these together: it runs `process.sh` and then `postprocess.sh` on each output file.

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

To run Layercake directly, install [DuckDB](https://duckdb.org/) and then install the `spatial` and `osmium` extensions:

```
$ duckdb -c 'INSTALL spatial; INSTALL osmium FROM community;'
```

Then run `process.sh`, specifying your input OSM PBF file and desired output directory. You can optionally pass flags to build only specific layers (e.g. `--buildings`, `--highways`). After that, you may optionally run `postprocess.sh` on each layer. See `entrypoint.sh` for an example of how to run these together.

For development purposes, it's best to run Layercake on a small `.osm.pbf` file (like for a metropolitan area, a US State, or a small country), rather than on the entire planet. The former should take a few minutes; the latter might take many hours, depending on your hardware. Suitable extracts can be downloaded from [Geofabrik](https://download.geofabrik.de/) or from [slice.openstreetmap.us](https://slice.openstreetmap.us).

## Adding new layers

Before working on a new layer definition, please discuss your idea with the maintainers, either on GitHub or in the `#layercake` channel on the OSM US Slack.

To add a new layer, create a new SQL file in the `sql/` directory (see existing layers for guidance), and then add it to `process.sh`.

## Modifying existing layers

Feel free to request new columns (tags) to add to existing layers, or simply make a PR.

## Reporting problems

If you find an issue with Layercake (such as certain features being processed incorretly), please open a bug on GitHub. If there's an error _in the data itself_, that is most likely a problem with the upstream OpenStreetMap data. You can check the data yourself on [openstreetmap.org](https://openstreetmap.org), and edit the map to fix the issue if it hasn't already been fixed.

## General PR guidelines

When sending a PR, please include a clear description of what it does. This helps the maintainers review it efficiently.
