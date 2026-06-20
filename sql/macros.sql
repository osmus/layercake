LOAD osmium;
LOAD spatial;


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

CREATE OR REPLACE MACRO assert_col_not_empty(table_name, col_name) AS (
    SELECT CASE
        WHEN NOT EXISTS (
            -- Must rewrap the col_name in an extra layer of quoting.
            SELECT 1 FROM query('SELECT 1 FROM ' || table_name || ' WHERE "' || col_name || '" IS NOT NULL LIMIT 1')
        )
        THEN CAST(error('Assertion Failed: Empty column: ' || col_name) AS INTEGER)
        ELSE 1
    END
);

CREATE OR REPLACE MACRO assert_map_not_empty(table_name, col_name) AS (
    SELECT CASE
        WHEN NOT EXISTS (
            -- Must rewrap the col_name in an extra layer of quoting.
            SELECT 1 FROM query('SELECT 1 FROM ' || table_name || ' WHERE cardinality("' || col_name || '") > 0 LIMIT 1')
        )
        THEN CAST(error('Assertion Failed: Empty map found for column: ' || col_name) AS INTEGER)
        ELSE 1
    END
);

CREATE OR REPLACE MACRO assert_tag_not_empty(table_name, k, v) AS (
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM query(
                printf('SELECT 1 FROM %s WHERE "%s" = ''%s'' LIMIT 1',table_name, k, v)
            )
        )
        THEN CAST(error(printf('Assertion Failed: Empty tag for "%s"=''%s''', k, v)) AS INTEGER)
        ELSE 1
    END
);

CREATE OR REPLACE MACRO assert_stmt_not_empty(stmt) AS (
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM query(stmt)
        )
        THEN CAST(error(printf('Assertion Failed: stmt ''%s'' produced no values', stmt)) AS INTEGER)
        ELSE 1
    END
);
