import json
import binascii
import typing

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

    # A set of OSM tags that the writer is interested in.
    # Subclasses MUST add these (or you'll trigger a runtime assertion).
    # Filters are OR'd together across a processing run.
    # Objects will match if they contain a tag that ANY writer is interested in.
    # Writers will receive objects matching the aggregate filter,
    # so handlers should implement their own checks.
    FILTERS: typing.Set[str] = set()

    # List of columns that the writer will write. Each entry is a tuple
    # of (column name, PyArrow type), e.g. ("name", pyarrow.string()).
    # When calling append(), you should pass a dictionary of attributes
    # that matches this schema.
    COLUMNS: typing.List[typing.Tuple[str, pyarrow.Schema]] = []

    def __init__(
        self,
        filename,
        schema_metadata=None,
        row_group_size=100_000,
    ):
        """Initialize the writer.

        Args:
            filename: Path to the output Parquet file
            schema_metadata: Optional additional metadata to include in the schema
            row_group_size: The number of rows to write per group
        """
        super().__init__()
        self.filename = filename
        self.row_group_size = row_group_size

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
                (
                    "tags",
                    pyarrow.struct(self.COLUMNS),
                ),
                ("bbox", bbox_schema),
                ("geometry", pyarrow.binary()),
            ],
            metadata=base_metadata,
        )

        self.writer = pyarrow.parquet.ParquetWriter(filename, self.schema, compression="zstd")
        self.chunk = []
        self.wkbfactory = osmium.geom.WKBFactory()

    def finish(self):
        """Finish writing the file."""
        if self.chunk:
            self.flush()
        self.writer.close()

    def append(self, type, id, attrs, wkb_hex):
        """Append a record to the current chunk.

        Args:
            type: OSM element type ('node', 'way', or 'relation')
            id: OSM element ID
            attrs: additional columns to write; must match COLUMNS schema
            wkb_hex: WKB geometry in hex format
        """
        geom = shapely.wkb.loads(wkb_hex, hex=True)
        wkb = binascii.unhexlify(wkb_hex)

        bbox = dict(zip(["xmin", "ymin", "xmax", "ymax"], shapely.bounds(geom)))

        self.chunk.append({"type": type, "id": id, "tags": attrs, "bbox": bbox, "geometry": wkb})

        if len(self.chunk) >= self.row_group_size:
            self.flush()

    def flush(self):
        """Write the current chunk to the Parquet file."""
        table = pyarrow.Table.from_pylist(self.chunk, schema=self.schema)
        self.writer.write_table(table)
        self.chunk = []
