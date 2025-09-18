def tags_with_prefix(prefix, tags):
    """
    Returns a dict of all tags with the given prefix string; keys in the
    dict will have the prefix dropped.
    """
    prefix_len = len(prefix)
    return {k[prefix_len:]: v for (k, v) in tags if k.startswith(prefix)}
