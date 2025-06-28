import sys
import json
import binascii

import osmium
import pyarrow
import pyarrow.parquet
import shapely
import shapely.wkb


class GeoParquetWriter(osmium.SimpleHandler):
    """Base class for writing OSM data to GeoParquet files.

    This class handles the common functionality of writing OSM data to GeoParquet files,
    including chunking, geometry handling, and file writing. Subclasses should implement
    their own tag sets and filtering logic.
    """

    def __init__(self, filename, tags, schema_metadata=None):
        """Initialize the writer.

        Args:
            filename: Path to the output Parquet file
            tags: List of OSM tags to include in the output
            schema_metadata: Optional additional metadata to include in the schema
        """
        super().__init__()
        self.filename = filename
        self.tags = tags

        # Create the schema
        bbox_schema = pyarrow.struct(
            [
                ("xmin", pyarrow.float32()),
                ("ymin", pyarrow.float32()),
                ("xmax", pyarrow.float32()),
                ("ymax", pyarrow.float32()),
            ]
        )

        # Combine base metadata with any additional metadata
        base_metadata = {
            "geo": json.dumps(
                {
                    "version": "1.1.0",
                    "primary_column": "geometry",
                    "columns": {
                        "geometry": {
                            "encoding": "WKB",
                            "geometry_types": [],
                            "covering": {
                                "bbox": {
                                    "xmin": ["bbox", "xmin"],
                                    "ymin": ["bbox", "ymin"],
                                    "xmax": ["bbox", "xmax"],
                                    "ymax": ["bbox", "ymax"],
                                }
                            },
                        }
                    },
                }
            )
        }
        if schema_metadata:
            base_metadata.update(schema_metadata)

        self.schema = pyarrow.schema(
            [
                ("type", pyarrow.string()),
                ("id", pyarrow.int64()),
                ("tags", pyarrow.struct([(tag, pyarrow.string()) for tag in tags])),
                ("bbox", bbox_schema),
                ("geometry", pyarrow.binary()),
            ],
            metadata=base_metadata,
        )

        self.writer = pyarrow.parquet.ParquetWriter(filename, self.schema)
        self.chunk = []
        self.wkbfactory = osmium.geom.WKBFactory()

    def finish(self):
        """Finish writing the file."""
        if self.chunk:
            self.flush()
        self.writer.close()

    def append(self, type, id, tags, wkb_hex):
        """Append a record to the current chunk.

        Args:
            type: OSM element type ('node', 'way', or 'relation')
            id: OSM element ID
            tags: OSM tags dictionary
            wkb_hex: WKB geometry in hex format
        """
        geom = shapely.wkb.loads(wkb_hex, hex=True)
        wkb = binascii.unhexlify(wkb_hex)

        attrs = {key: tags.get(key) for key in self.tags}

        bbox = dict(zip(["xmin", "ymin", "xmax", "ymax"], shapely.bounds(geom)))

        self.chunk.append({"type": type, "id": id, "tags": attrs, "bbox": bbox, "geometry": wkb})

        if len(self.chunk) >= 1000:
            self.flush()

    def flush(self):
        """Write the current chunk to the Parquet file."""
        table = pyarrow.Table.from_pylist(self.chunk, schema=self.schema)
        self.writer.write_table(table)
        self.chunk = []
