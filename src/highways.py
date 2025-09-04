import sys

import pyarrow

from .geoparquet import GeoParquetWriter


class HighwaysWriter(GeoParquetWriter):
    TAG_COLUMNS = [
        # type and subtypes
        ("highway", pyarrow.string()),
        ("service", pyarrow.string()),
        ("crossing", pyarrow.string()),
        ("cycleway", pyarrow.string()),
        ("cycleway:left", pyarrow.string()),
        ("cycleway:right", pyarrow.string()),
        ("footway", pyarrow.string()),
        ("construction", pyarrow.string()),
        # identifiers
        ("name", pyarrow.string()),
        ("ref", pyarrow.string()),
        # physical properties
        ("bridge", pyarrow.string()),
        ("covered", pyarrow.string()),
        ("lanes", pyarrow.string()),
        ("layer", pyarrow.string()),
        ("lit", pyarrow.string()),
        ("sidewalk", pyarrow.string()),
        ("smoothness", pyarrow.string()),
        ("surface", pyarrow.string()),
        ("tracktype", pyarrow.string()),
        ("tunnel", pyarrow.string()),
        ("wheelchair", pyarrow.string()),
        ("width", pyarrow.string()),
        # access and restrictions
        ("access", pyarrow.string()),
        ("bicycle", pyarrow.string()),
        ("bus", pyarrow.string()),
        ("foot", pyarrow.string()),
        ("hgv", pyarrow.string()),
        ("maxspeed", pyarrow.string()),
        ("motor_vehicle", pyarrow.string()),
        ("motorcycle", pyarrow.string()),
        ("oneway", pyarrow.string()),
        ("toll", pyarrow.string()),
    ]

    FILTERS = {"highway"}

    def __init__(self, filename):
        super().__init__(filename, self.TAG_COLUMNS)

    def node(self, o):
        if "highway" not in o.tags:
            return

        try:
            self.append("node", o.id, o.tags, self.wkbfactory.create_point(o))
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def way(self, o):
        if "highway" not in o.tags:
            return

        if o.is_closed() and o.tags.get("area") == "yes":
            # closed ways explicitly tagged area=yes are polygons
            # (they will be handled by area() below)
            return

        try:
            self.append("way", o.id, o.tags, self.wkbfactory.create_linestring(o))
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def area(self, o):
        if "highway" not in o.tags:
            return

        if o.from_way() and o.tags.get("area") != "yes":
            # closed ways with highway=* aren't areas unless they are also
            # tagged area=yes (these elements will be handled by way() above)
            return

        try:
            self.append(
                "way" if o.from_way() else "relation",
                o.orig_id(),
                o.tags,
                self.wkbfactory.create_multipolygon(o),
            )
        except RuntimeError as e:
            print(e, file=sys.stderr)
