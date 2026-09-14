COPY (
  WITH raw AS (
    SELECT type, id, tags, version, timestamp, geometry
    FROM '{{INPUT}}'
    WHERE (kind = 'node' OR kind = 'area')
      AND tags['natural'] = 'wetland'
  )
  SELECT
    type,
    id,
    tags['wetland']                  AS wetland,
    split_multi(tags['name'])        AS name,
    prefix_map_split('name:', tags)  AS names,
    -- Hydrology
    tags['salt']                     AS salt,
    tags['tidal']                    AS tidal,
    tags['intermittent']             AS intermittent,
    split_multi(tags['seasonal'])    AS seasonal,
    -- Land cover and management
    tags['surface']                  AS surface,
    split_multi(tags['crop'])        AS crop,
    tags['managed']                  AS managed,
    tags['wikidata']                 AS wikidata,
    tags['source']                   AS source,
    version,
    timestamp,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
