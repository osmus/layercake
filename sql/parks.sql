COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE (kind = 'node' OR kind = 'area')
      AND (
        tags['boundary'] IN ('national_park', 'protected_area')
        OR tags['leisure'] IN ('park', 'nature_reserve')
      )
  )
  SELECT
    type,
    id,
    tags['boundary']                            AS boundary,
    tags['protected_area']                      AS protected_area,
    tags['leisure']                             AS leisure,
    split_multi(tags['name'])                   AS name,
    prefix_map_split('name:', tags)             AS names,
    split_multi(tags['short_name'])             AS short_name,
    prefix_map_split('short_name:', tags)       AS short_names,
    split_multi(tags['official_name'])          AS official_name,
    prefix_map_split('official_name:', tags)    AS official_names,
    tags['protect_class']                       AS protect_class,
    tags['protection_title']                    AS protection_title,
    tags['protected']                           AS protected,
    tags['iucn_level']                          AS iucn_level,
    tags['access']                              AS access,
    tags['operator']                            AS operator,
    tags['operator:type']                       AS "operator:type",
    tags['owner']                               AS owner,
    tags['ownership']                           AS ownership,
    tags['start_date']                          AS start_date,
    tags['related_law']                         AS related_law,
    tags['website']                             AS website,
    tags['wikidata']                            AS wikidata,
    tags['wikipedia']                           AS wikipedia,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
