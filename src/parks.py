import sys

import pyarrow
from osmium.osm import TagList

from .geoparquet import GeoParquetWriter
from .helpers import tags_with_prefix, split_multi_value_field


class ParksWriter(GeoParquetWriter):
    COLUMNS = [
        ("boundary", pyarrow.string()),
        ("protected_area", pyarrow.string()),
        ("leisure", pyarrow.string()),
        ("name", pyarrow.list_(pyarrow.string())),
        ("names", pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string()))),
        ("short_name", pyarrow.list_(pyarrow.string())),
        ("short_names", pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string()))),
        ("official_name", pyarrow.list_(pyarrow.string())),
        ("official_names", pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string()))),
        ("protect_class", pyarrow.string()),
        ("protection_title", pyarrow.string()),
        ("protected", pyarrow.string()),
        ("iucn_level", pyarrow.string()),
        ("access", pyarrow.string()),
        ("operator", pyarrow.string()),
        ("operator:type", pyarrow.string()),
        ("owner", pyarrow.string()),
        ("ownership", pyarrow.string()),
        ("start_date", pyarrow.string()),
        ("related_law", pyarrow.string()),
        ("website", pyarrow.string()),
        ("wikidata", pyarrow.string()),
        ("wikipedia", pyarrow.string()),
    ]

    FILTERS = {"boundary", "leisure"}

    def node(self, o):
        if not self._is_park(o.tags):
            return

        try:
            self.append(
                "node",
                o.id,
                self.columns(o.tags),
                self.wkbfactory.create_point(o),
            )
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def area(self, o):
        if not self._is_park(o.tags):
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

    def _is_park(self, tags):
        return (
            tags.get("boundary") in {"national_park", "protected_area"} or
            tags.get("leisure") in {"park", "nature_reserve"}
        )

    def columns(self, tags: TagList):
        return {key: column(key, tags) for (key, _) in self.COLUMNS}


def column(column_name: str, tags: TagList):
    match column_name:
        case "name" | "short_name" | "official_name":
            return split_multi_value_field(tags.get(column_name))
        case "names" | "short_names" | "official_names":
            return tags_with_prefix(f"{column_name[:-1]}:", tags, transform=split_multi_value_field)
        case _:
            return tags.get(column_name)
