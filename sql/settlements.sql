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
    {
      place:            tags['place'],
      name:             tags['name'],
      names:            prefix_map('name:', tags),
      alt_name:         tags['alt_name'],
      alt_names:        prefix_map('alt_name:', tags),
      official_name:    tags['official_name'],
      official_names:   prefix_map('official_name:', tags),
      wikidata:         tags['wikidata'],
      wikipedia:        tags['wikipedia'],
      population:       TRY_CAST(tags['population'] AS UBIGINT)
    } AS tags,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
