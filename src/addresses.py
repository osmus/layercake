import sys

import pyarrow
from osmium.osm import OSMObject, Relation
from .geoparquet import GeoParquetWriter


class AddressesWriter(GeoParquetWriter):
    COLUMNS = [
        ("addr:housenumber", pyarrow.string()),
        ("addr:housename", pyarrow.string()),
        # Conscription, street, and provisional numbers for Czechia
        ("addr:conscriptionnumber", pyarrow.string()),
        ("addr:streetnumber", pyarrow.string()),
        ("addr:provisionalnumber", pyarrow.string()),
        ("addr:unit", pyarrow.string()),
        # TODO: Localized street names?? pyarrow.string()),
        ("addr:street", pyarrow.string()),
        # UK-specific streets
        ("naptan:Street", pyarrow.string()),
        # Not all addresses have a street; see https://wiki.openstreetmap.org/wiki/Key:addr:place
        ("addr:place", pyarrow.string()),
        ("addr:city", pyarrow.string()),
        ("addr:postcode", pyarrow.string()),
        ("addr:hamlet", pyarrow.string()),
        ("addr:district", pyarrow.string()),
        ("addr:suburb", pyarrow.string()),
        # Typically used in Japan
        ("addr:neighbourhood", pyarrow.string()),
        ("addr:quarter", pyarrow.string()),
        ("addr:block_number", pyarrow.string()),
        # Not machine-readable, but maybe useful to some?
        ("addr:full", pyarrow.string()),
        # Typically a tagging error for addresses
        ("postal_code", pyarrow.string()),
        # TODO: Entrance tags, probably? Seems useful for geocoding...
        # TODO: Is this an "address" that we'd want in this layer? https://wiki.openstreetmap.org/wiki/Key:nohousenumber
        # If so, we'll need to modify FILTERS
        # ("nohousenumber", pyarrow.string()),
        ("building", pyarrow.string()),
        ("name", pyarrow.string()),
    ]

    FILTERS = {"addr:housenumber", "addr:housename", "type"}

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # TODO: Decide what we do with things like https://www.openstreetmap.org/relation/18131322#map=19/48.828354/2.537284&layers=PN
        # which have an `addr:housenumber` but do NOT have a street, place, etc. (directly or as part of a parent relation)
        self.house_number_node_cache = {}
        self.house_number_area_cache = {}

    def node(self, o):
        if is_house_number_or_name(o) and not is_address(o):
            # Some addresses are part of a street relation which has the street name, rather than the node!
            # We won't know in advance, so we have to cache tags like this.
            # We can't save the object, because it's immediately freed after handler exit,
            # so we save a copy of the geometry and tags in a Python dict like this.
            #
            # Assumptions:
            # - There will not be an inordinate number of nodes tagged with address info,
            #   but missing a street, which are orphans.
            # - This cache doesn't take an inordinate amount of space.
            #   (OSM Wiki estimated that only ~5% of global addresses are tagged this way several years ago.)
            self.house_number_node_cache[o.id] = (
                self.wkbfactory.create_point(o),
                {tag.k: tag.v for tag in o.tags},
            )
            return
        elif not is_address(o):
            return

        try:
            self.append(
                "node", o.id, self.columns(o.tags), self.wkbfactory.create_point(o)
            )
        except RuntimeError as e:
            print(e, file=sys.stderr)

    # TODO: Maybe we should externalize the area cache to Python for flexibility??? We rarely care about EVERY area. But that's probably stupid and I'm missing something.
    def area(self, o):
        if is_house_number_or_name(o) and not is_address(o):
            # See comment above on the node cache
            self.house_number_area_cache[o.orig_id()] = (
                "way" if o.from_way() else "relation",
                self.wkbfactory.create_multipolygon(o),
                {tag.k: tag.v for tag in o.tags},
            )
        if not is_address(o):
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

    def relation(self, o: Relation):
        # Some areas (France, for example) use relations to avoid needing to enter a bunch of duplicate tags
        # for addresses along a street.
        # This makes data consumption tricky, so we denormalize these relations into their components.
        if (
            o.tags.get("type") not in {"associatedStreet", "street"}
            or "name" not in o.tags
        ):
            return

        member_addresses = [
            member
            for member in o.members
            if member.role in {"house", "address", "addr:houselink"}
        ]
        if member_addresses:
            # TODO: Handle name:xx tags for language-specific names?
            name = o.tags["name"]
            if not name:
                print(f"WARNING: Relation {o.id} has no name")
                return

            for member in member_addresses:
                # TODO: Sholud we "pop" the node out of the cache?
                # - We can return memory
                # - At the end of the import, we could decide what to do with elements that haven't been matched with a relation
                #   (e.g. log it as a reject, or add it anyways with null fields)
                if member.type == "n":
                    # Try to get the node out of the cache.
                    # This may fail for two reasons:
                    # 1. We already processed the node, because it contains the full address tags.
                    #    In that case, we process it immediately and skip it here.
                    # 2. The node does not have the required address tags, so we didn't cache it.
                    #    This is a tagging error.
                    # In both cases, we skip the node.
                    node_info = self.house_number_node_cache.get(member.ref)
                    if node_info:
                        (geom, tags) = node_info
                        tags["addr:street"] = name
                        self.append("node", member.ref, tags, geom)
                elif member.type in {"w", "r"}:
                    # Same idea as above, but for buildings (usually)
                    area_info = self.house_number_area_cache.get(member.ref)
                    if area_info:
                        (area_type, geom, tags) = area_info
                        tags["addr:street"] = name
                        self.append(area_type, member.ref, tags, geom)
                else:
                    print(
                        f"WARNING: Unexpected relation member type: {member.type} of relation {o.id}"
                    )

    def columns(self, tags):
        return {key: tags.get(key) for (key, _) in self.COLUMNS}


def is_address(o: OSMObject) -> bool:
    # Must have some identifier (number/name) and some sort of location identifier
    # (usually a street).
    return is_house_number_or_name(o) and (
        "addr:street" in o.tags
        # Some places use this instead of a street name
        or "addr:place" in o.tags
        # UK import
        or "naptan:Street" in o.tags
        # Usually addr:neighbourhood or addr:quarter are used instead of addr:street in Japan.
        # This also shows up in a few other places though too, like France.
        or "addr:neighbourhood" in o.tags
        or "addr:quarter" in o.tags
    )


def is_house_number_or_name(o: OSMObject) -> bool:
    return "addr:housenumber" in o.tags or "addr:housename" in o.tags
