import json
import binascii
import typing

import osmium
import pyarrow
import pyarrow.parquet
import shapely



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

        self.writer = pyarrow.parquet.ParquetWriter(
            filename, self.schema, compression="zstd"
        )
        self.wkbfactory = osmium.geom.WKBFactory()
        self._tag_names = [key for key, _ in self.COLUMNS]
        self._reset_buffers()

    def _reset_buffers(self):
        self._col_type = []
        self._col_id = []
        self._col_tags = []
        self._col_wkb = []
        self._count = 0

    def finish(self):
        """Finish writing the file."""
        if self._count:
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
        self._col_type.append(type)
        self._col_id.append(id)
        self._col_tags.append(attrs)
        self._col_wkb.append(binascii.unhexlify(wkb_hex))

        self._count += 1
        if self._count >= self.row_group_size:
            self.flush()

    def flush(self):
        """Write the current chunk to the Parquet file.

        Builds the pyarrow table from columnar buffers and computes
        bounding boxes in bulk.
        """
        # Bbox via vectorized shapely
        geoms = shapely.from_wkb(self._col_wkb)
        bounds = shapely.bounds(geoms)

        bbox_array = pyarrow.StructArray.from_arrays(
            [
                pyarrow.array(bounds[:, 0], type=pyarrow.float32()),
                pyarrow.array(bounds[:, 1], type=pyarrow.float32()),
                pyarrow.array(bounds[:, 2], type=pyarrow.float32()),
                pyarrow.array(bounds[:, 3], type=pyarrow.float32()),
            ],
            names=["xmin", "ymin", "xmax", "ymax"],
        )

        # Build per-column tag arrays from the collected dicts
        tag_arrays = []
        for key, pa_type in self.COLUMNS:
            tag_arrays.append(
                pyarrow.array([t.get(key) for t in self._col_tags], type=pa_type)
            )
        tags_array = pyarrow.StructArray.from_arrays(tag_arrays, names=self._tag_names)

        table = pyarrow.Table.from_arrays(
            [
                pyarrow.array(self._col_type, type=pyarrow.string()),
                pyarrow.array(self._col_id, type=pyarrow.int64()),
                tags_array,
                bbox_array,
                pyarrow.array(self._col_wkb, type=pyarrow.binary()),
            ],
            schema=self.schema,
        )

        self.writer.write_table(table)
        self._reset_buffers()
