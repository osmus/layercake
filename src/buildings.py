import sys
from .geoparquet import GeoParquetWriter


class BuildingsWriter(GeoParquetWriter):
    TAGS = [
        # building type and properties
        "building",
        "building:levels",
        "building:flats",
        "building:material",
        "building:colour",
        "building:part",
        "building:use",
        # name, address, and other identifiers
        "name",
        "addr:housenumber",
        "addr:street",
        "addr:city",
        "addr:postcode",
        "website",
        "wikipedia",
        "wikidata",
        # physical properties
        "height",
        "roof:shape",
        "roof:levels",
        "roof:colour",
        "roof:material",
        "roof:orientation",
        "roof:height",
        "start_date",
        # access and restrictions
        "access",
        "wheelchair",
    ]

    FILTERS = {"building"}

    def __init__(self, filename):
        super().__init__(filename, self.TAGS)

    def area(self, o):
        if "building" not in o.tags:
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
