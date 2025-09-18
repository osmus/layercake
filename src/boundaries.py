import sys

import pyarrow
from osmium.osm import TagList

from .geoparquet import GeoParquetWriter
from .helpers import tags_with_prefix, split_multi_value_field


class BoundariesWriter(GeoParquetWriter):
    COLUMNS = [
        ("name", pyarrow.list_(pyarrow.string())),
        ("names", pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string()))),
        ("official_name", pyarrow.list_(pyarrow.string())),
        (
            "official_names",
            pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string())),
        ),
        ("int_name", pyarrow.list_(pyarrow.string())),
        ("alt_name", pyarrow.list_(pyarrow.string())),
        ("alt_names", pyarrow.map_(pyarrow.string(), pyarrow.list_(pyarrow.string()))),
        ("type", pyarrow.string()),
        ("admin_level", pyarrow.string()),
        ("boundary", pyarrow.string()),
        # Border type tagging is a fairly deep rabbit hole...
        # We may consider harmonizing other tags like admin_type:XX
        # in the future. See https://github.com/osmus/layercake/pull/18#discussion_r2347797702
        ("place", pyarrow.string()),
        ("border_type", pyarrow.string()),
        ("ISO3166-2", pyarrow.string()),
        ("ISO3166-1:alpha2", pyarrow.string()),
        ("ISO3166-1:alpha3", pyarrow.string()),
        ("wikidata", pyarrow.string()),
        ("wikipedia", pyarrow.string()),
        ("disputed_by", pyarrow.list_(pyarrow.string())),
        ("claimed_by", pyarrow.list_(pyarrow.string())),
        ("controlled_by", pyarrow.list_(pyarrow.string())),
        ("recognized_by", pyarrow.list_(pyarrow.string())),
    ]

    FILTERS = {"boundary"}

    def area(self, o):
        if o.tags.get("boundary") not in {
            "administrative",
            "aboriginal_lands",
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
        return {key: column(key, tags) for (key, _) in self.COLUMNS}


def column(column_name: str, tags: TagList):
    match column_name:
        case (
            "name"
            | "official_name"
            | "int_name"
            | "alt_name"
            | "disputed_by"
            | "claimed_by"
            | "controlled_by"
            | "recognized_by"
        ):
            # Multi-value fields
            return split_multi_value_field(tags.get(column_name))
        case "names" | "alt_names" | "official_names":
            # Prefixed maps
            return tags_with_prefix(
                f"{column_name[:-1]}:", tags, transform=split_multi_value_field
            )
        case _:
            # Single value fields
            return tags.get(column_name)
