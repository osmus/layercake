COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'area'
      AND tags['boundary'] IN ('administrative', 'aboriginal_lands', 'maritime', 'disputed', 'place')
  )
  SELECT
    type,
    id,
    tags['boundary']                         AS boundary,
    tags['admin_level']                      AS admin_level,
    split_multi(tags['name'])                AS name,
    prefix_map_split('name:', tags)          AS names,
    split_multi(tags['official_name'])       AS official_name,
    prefix_map_split('official_name:', tags) AS official_names,
    split_multi(tags['int_name'])            AS int_name,
    split_multi(tags['alt_name'])            AS alt_name,
    prefix_map_split('alt_name:', tags)      AS alt_names,
    tags['place']                            AS place,
    tags['border_type']                      AS border_type,
    tags['ISO3166-2']                        AS "ISO3166-2",
    tags['ISO3166-1:alpha2']                 AS "ISO3166-1:alpha2",
    tags['ISO3166-1:alpha3']                 AS "ISO3166-1:alpha3",
    tags['wikidata']                         AS wikidata,
    tags['wikipedia']                        AS wikipedia,
    split_multi(tags['disputed_by'])         AS disputed_by,
    split_multi(tags['claimed_by'])          AS claimed_by,
    split_multi(tags['controlled_by'])       AS controlled_by,
    split_multi(tags['recognized_by'])       AS recognized_by,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
