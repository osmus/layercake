LOAD osmium;
LOAD spatial;

SET memory_limit = '64GB';
SET osmium_index_type = 'dense_file_array';

-- Split a semicolon-delimited OSM tag value into a list of trimmed strings.
-- See https://wiki.openstreetmap.org/wiki/Semi-colon_value_separator
CREATE OR REPLACE MACRO split_multi(s) AS (
  CASE WHEN s IS NOT NULL
    THEN list_transform(str_split(s, ';'), lambda x : trim(x))
    ELSE NULL
  END
);

-- Extract all tags matching a prefix into a MAP, stripping the prefix from keys.
-- e.g. prefix_map('name:', tags) on {name:en: 'London', name:fr: 'Londres'}
-- yields {en: 'London', fr: 'Londres'}
CREATE OR REPLACE MACRO prefix_map(pfx, t) AS (
  MAP_FROM_ENTRIES(
    LIST_TRANSFORM(
      LIST_FILTER(MAP_ENTRIES(t), lambda x : starts_with(x.key, pfx)),
      lambda x : {key: x.key[len(pfx)+1:], value: x.value}
    )
  )
);

-- Same as prefix_map but splits each value on semicolons.
CREATE OR REPLACE MACRO prefix_map_split(pfx, t) AS (
  MAP_FROM_ENTRIES(
    LIST_TRANSFORM(
      LIST_FILTER(MAP_ENTRIES(t), lambda x : starts_with(x.key, pfx)),
      lambda x : {key: x.key[len(pfx)+1:], value: list_transform(str_split(x.value, ';'), lambda v : trim(v))}
    )
  )
);
