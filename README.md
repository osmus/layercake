# Layercake

Layercake is a set of thematic extracts of [OpenStreetMap](https://www.openstreetmap.org/about) data in cloud-native file formats.

OpenStreetMap’s native file format is OSM PBF, but this 80GB ‘planet file’ is unwieldy and not supported by all GIS software. Layercake provides OSM data separated into thematic layers (buildings, transportation, etc) and converted to cloud-native file formats like GeoParquet that are easy to use with software from DuckDB to QGIS.

This repository contains the code that is used to generate the extracts, which are hosted by [OpenStreetMap US](https://openstreetmap.us/) at `data.openstreetmap.us`. [Instructions on how to access the data](https://openstreetmap.us/our-work/layercake/) are available on the OpenStreetMap US website.

> [!WARNING]
> Layercake is still experimental, and may change as it evolves. If you are interested in thematic extracts of OSM data, you can help the project's development by using it and providing feedback.

## Design goals

- **Make OpenStreetMap data more accessible to the broader GIS community**: Layercake organizes OpenStreetMap data into thematic layers, converts OSM's tag-based schema into columnar attributes, and transforms OSM elements into standard OGC Geometry types. This makes the data compatible with a wide array of standard GIS software and workflows.
- **Enable complex and efficient analysis**: Layercake's cloud-native formats support efficient querying without needing to download all of the data first. Users can use SQL (via tools like [DuckDB](https://duckdb.org/)) to filter and download just the data that is relevant for their use case.
- **Preserve OSM's rich data model**: Layercake layers contain numerous columns, representing the wide rande of data that is available in OpenStreetMap. Columns correspond directly to OSM tags (in a 1:1 mapping where possible), which makes it easy to find relevant documentation on the [OSM Wiki](https://osm.wiki) for how to interpret the data.

These goals come with some trade-offs:
- Layercake inherits OSM's tag schema, which is complex and can even be ambigouous. Users will need to think about [synonymous tags](https://wiki.openstreetmap.org/wiki/Synonymous_tags), [skunked tags](https://wiki.openstreetmap.org/wiki/Skunked_tag), and other irregularities when interpreting the data.
- Layercake does not include any quality assurance checks, so it may contain typos, invalid values, and in rare cases vandalism.

## License

Code in this repository is dedicated to the public domain via the [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) license. You may use or modify it for any purpose, without needing to ask permission. See the [LICENSE](./LICENSE) file for details.

Data from the OpenStreetMap project is licensed under [ODbL](https://opendatacommons.org/licenses/odbl/). Layercake extracts are subject to the same license. You are free to copy, distribute, transmit and adapt OpenStreetMap data, as long as you credit OpenStreetMap and its contributors. If you alter or build upon our data, you may distribute the result only under the same license.
