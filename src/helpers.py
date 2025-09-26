from typing import Optional


def tags_with_prefix(prefix, tags, transform=None):
    """
    Returns a dict of all tags with the given prefix string; keys in the
    dict will have the prefix dropped.

    The transform argument allows you to transform the value
    from a string into some other type (e.g., an array of strings).
    NOTE: your transform function should take care to handle values like None!
    """
    prefix_len = len(prefix)
    return {
        k[prefix_len:]: transform(v) if transform else v
        for (k, v) in tags
        if k.startswith(prefix)
    }


def split_multi_value_field(s: Optional[str]) -> Optional[list[str]]:
    """Splits an OSM delimited field into an array."""
    # This is extremely simplistic for now,
    # and doesn't handle rare edge cases like double semicolons.
    # See https://wiki.openstreetmap.org/wiki/Semi-colon_value_separator
    # for more possible edge cases to consider later.
    if s:
        return [value.strip() for value in s.split(";")]
    else:
        return None
