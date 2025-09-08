import sys
import pyarrow
import shapely.wkb

from .geoparquet import GeoParquetWriter


class PlacesWriter(GeoParquetWriter):
    """
    The places layer contains point geometries representing named places
    (cities, towns, neighborhoods, etc) from OSM - anything tagged place=*
    that has a name.

    Most place features are mapped as nodes, but some are mapped as areas
    (typically neighborhoods, islands, etc). In these cases we include the
    area's centroid in the output dataset.
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

    def node(self, o):
        if "place" not in o.tags or "name" not in o.tags:
            return

        try:
            self.append("node", o.id, self.columns(o.tags), self.wkbfactory.create_point(o))
        except RuntimeError as e:
            print(e, file=sys.stderr)

    def area(self, o):
        if "place" not in o.tags or "name" not in o.tags:
            return

        if not o.from_way() and "boundary" in o.tags:
            # Administrativie boundary relations often have a 'label' member,
            # which is itself a place=* node. To avoid creating multiple rows
            # for a given place (city, town, etc), we skip boundary relations
            # that are tagged place=*. It would be better to check if the
            # relation actually has a member with the 'label' role, but Osmium
            # doesn't let us access members on Area instances, so we're forced
            # to just assume.
            return

        try:
            # The "places" layer contains only POINT geometries; for areas
            # tagged place=* we use the centroid.
            polygon_wkb = self.wkbfactory.create_multipolygon(o)
            polygon = shapely.wkb.loads(polygon_wkb, hex=True)
            centroid = polygon.centroid
            centroid_wkb = shapely.wkb.dumps(centroid).hex()

            self.append(
                "way" if o.from_way() else "relation",
                o.orig_id(),
                self.columns(o.tags),
                centroid_wkb,
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
