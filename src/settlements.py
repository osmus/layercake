import sys
import pyarrow

from .geoparquet import GeoParquetWriter


class SettlementsWriter(GeoParquetWriter):
    """
    The settlements layer contains point geometries representing named human
    settlements (cities, towns, villages) and parts of settlements (boroughs,
    qaurters, neighborhoods) from OSM.
    """

    COLUMNS = [
        ("place", pyarrow.string()),
        ("name", pyarrow.string()),
        ("names", pyarrow.map_(pyarrow.string(), pyarrow.string())),
        ("alt_name", pyarrow.string()),
        ("alt_names", pyarrow.map_(pyarrow.string(), pyarrow.string())),
        ("official_name", pyarrow.string()),
        ("official_names", pyarrow.map_(pyarrow.string(), pyarrow.string())),
        ("wikidata", pyarrow.string()),
        ("wikipedia", pyarrow.string()),
        ("population", pyarrow.uint32()),
    ]

    FILTERS = {"place"}

    PLACE_TYPES = {
        # place=* values from OSM that represent human settlements
        "city",
        "town",
        "village",
        "hamlet",
        "isolated_dwelling",
        "farm",
        "allotments"
        # ...and parts of settlements:
        "borough",
        "suburb",
        "quarter",
        "neighborhood",
        "city_block",
    }

    def node(self, o):
        if o.tags.get("place") not in self.PLACE_TYPES or "name" not in o.tags:
            return

        try:
            self.append(
                "node", o.id, self.columns(o.tags), self.wkbfactory.create_point(o)
            )
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def columns(self, tags):
        return {key: column(key, tags) for (key, _) in self.COLUMNS}


def column(column_name, tags):
    """
    Using the tags for a given OSM element, return the appropriate value
    for the specified column in the output dataset.
    """
    match column_name:
        case "population":
            try:
                return int(tags.get("population"))
            except (TypeError, ValueError):
                return None
        case "names" | "alt_names" | "official_names":
            return tags_with_prefix(f"{column_name[:-1]}:", tags)
        case _:
            return tags.get(column_name)


def tags_with_prefix(prefix, tags):
    """
    Returns a dict of all tags with the given prefix string; keys in the
    dict will have the prefix dropped.
    """
    prefix_len = len(prefix)
    return {k[prefix_len:]: v for (k, v) in tags if k.startswith(prefix)}
