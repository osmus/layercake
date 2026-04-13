# Changelog

All notable changes to this project will be documented in this file.

Versioning of this project adheres to the [Semantic Versioning](https://semver.org/spec/v2.0.0.html) spec.

## v0.2.0

Released 2026-04-13

- Flatten `tags` struct into top-level columns
- Use [duckdb-osmium](https://github.com/jake-low/duckdb-osmium/) to read OSM PBF instead of pyosmium
- Switch from Debian to Alpine container base image

## v0.1.0

First tagged version of Layercake, released 2026-03-30.

Changes since first public version:
- spatially sort output features and compress output GeoParquet files with zstd
- add boundaries, settlements, and parks layers

## 0eef31d

First public version of Layercake, published on 2025-04-21.

Included two layers: buildings and highways. Used Python scripts to extract features from OSM PBF (using pyosmium) and write them to GeoParquet (using pyarrow).
