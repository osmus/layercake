COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'node'
      AND tags['place'] IN (
        'city', 'town', 'village', 'hamlet', 'isolated_dwelling', 'farm', 'allotments',
        'borough', 'suburb', 'quarter', 'neighborhood', 'city_block'
      )
      AND tags['name'] IS NOT NULL
  )
  SELECT
    type,
    id,
    tags['place']                           AS place,
    tags['name']                            AS name,
    prefix_map('name:', tags)               AS names,
    tags['alt_name']                        AS alt_name,
    prefix_map('alt_name:', tags)           AS alt_names,
    tags['official_name']                   AS official_name,
    prefix_map('official_name:', tags)      AS official_names,
    tags['wikidata']                        AS wikidata,
    tags['wikipedia']                       AS wikipedia,
    TRY_CAST(tags['population'] AS UBIGINT) AS population,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
