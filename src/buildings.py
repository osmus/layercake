import sys

import pyarrow

from .geoparquet import GeoParquetWriter


class BuildingsWriter(GeoParquetWriter):
    COLUMNS = [
        # building type and properties
        ("building", pyarrow.string()),
        ("building:levels", pyarrow.string()),
        ("building:flats", pyarrow.string()),
        ("building:material", pyarrow.string()),
        ("building:colour", pyarrow.string()),
        ("building:part", pyarrow.string()),
        ("building:use", pyarrow.string()),
        # name, address, and other identifiers
        ("name", pyarrow.string()),
        ("addr:housenumber", pyarrow.string()),
        ("addr:street", pyarrow.string()),
        ("addr:city", pyarrow.string()),
        ("addr:postcode", pyarrow.string()),
        ("website", pyarrow.string()),
        ("wikipedia", pyarrow.string()),
        ("wikidata", pyarrow.string()),
        # physical properties
        ("height", pyarrow.string()),
        ("roof:shape", pyarrow.string()),
        ("roof:levels", pyarrow.string()),
        ("roof:colour", pyarrow.string()),
        ("roof:material", pyarrow.string()),
        ("roof:orientation", pyarrow.string()),
        ("roof:height", pyarrow.string()),
        ("start_date", pyarrow.string()),
        # access and restrictions
        ("access", pyarrow.string()),
        ("wheelchair", pyarrow.string()),
    ]

    FILTERS = {"building"}

    def area(self, o):
        if "building" not in o.tags:
            return

        try:
            self.append(
                "way" if o.from_way() else "relation",
                o.orig_id(),
                self.columns(o.tags),
                self.wkbfactory.create_multipolygon(o),
            )
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def columns(self, tags):
        return {key: tags.get(key) for (key, _) in self.COLUMNS}
