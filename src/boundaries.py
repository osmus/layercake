import sys

import pyarrow
from osmium.osm import TagList

from .geoparquet import GeoParquetWriter


class BoundariesWriter(GeoParquetWriter):
    COLUMNS = [
        ("name", pyarrow.string()),
        ("multilingual_names", pyarrow.map_(pyarrow.string(), pyarrow.string())),
        ("type", pyarrow.string()),
        ("admin_level", pyarrow.string()),
        ("boundary", pyarrow.string()),
        ("place", pyarrow.string()),
        ("ISO3166-2", pyarrow.string()),
        ("ISO3166-1:alpha2", pyarrow.string()),
        ("ISO3166-1:alpha3", pyarrow.string()),
    ]

    FILTERS = {"boundary"}

    def area(self, o):
        if o.tags.get("boundary") not in {
            "administrative",
            "maritime",
            "disputed",
            "place",
        }:
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

    def columns(self, tags: TagList):
        # Preserve the basic tags as-is
        res = {tag.k: tag.v for tag in tags if not tag.k.startswith("name:")}

        # Special shape transformation for names
        name_tags = {tag.k: tag.v for tag in tags if tag.k.startswith("name:")}

        res["multilingual_names"] = name_tags

        # TODO: alt names?

        return {key: res.get(key) for (key, _) in self.COLUMNS}
