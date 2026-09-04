COPY (
  WITH raw AS (
    SELECT type, id, tags, version, timestamp, geometry
    FROM '{{INPUT}}'
    WHERE (kind = 'node' OR kind = 'area')
      AND (
        tags['amenity']    IS NOT NULL OR
        tags['attraction'] IS NOT NULL OR
        tags['club']       IS NOT NULL OR
        tags['craft']      IS NOT NULL OR
        tags['education']  IS NOT NULL OR
        tags['healthcare'] IS NOT NULL OR
        (tags['historic']  IS NOT NULL AND tags['historic'] != 'yes'
                                       AND tags['historic'] != 'no') OR
        tags['leisure']    IS NOT NULL OR
        tags['office']     IS NOT NULL OR
        tags['playground'] IS NOT NULL OR
        tags['shop']       IS NOT NULL OR
        tags['tourism']    IS NOT NULL
      )
  )
  SELECT
    type,
    id,
    tags['amenity']                          AS amenity,
    tags['attraction']                       AS attraction,
    tags['club']                             AS club,
    tags['craft']                            AS craft,
    tags['education']                        AS education,
    tags['healthcare']                       AS healthcare,
    tags['historic']                         AS historic,
    tags['leisure']                          AS leisure,
    tags['office']                           AS office,
    tags['playground']                       AS playground,
    tags['shop']                             AS shop,
    tags['tourism']                          AS tourism,
    tags['landuse']                          AS landuse,
    tags['natural']                          AS "natural",
    split_multi(tags['name'])                AS name,
    prefix_map_split('name:', tags)          AS names,
    split_multi(tags['official_name'])       AS official_name,
    prefix_map_split('official_name:', tags) AS official_names,
    split_multi(tags['old_name'])            AS old_name,
    prefix_map_split('old_name:', tags)      AS old_names,
    split_multi(tags['alt_name'])            AS alt_name,
    prefix_map_split('alt_name:', tags)      AS alt_names,
    split_multi(tags['short_name'])          AS short_name,
    prefix_map_split('short_name:', tags)    AS short_names,
    tags['brand']                            AS brand,
    tags['brand:wikidata']                   AS "brand:wikidata",
    tags['operator']                         AS operator,
    tags['operator:wikidata']                AS "operator:wikidata",
    tags['phone']                            AS phone,
    tags['email']                            AS email,
    tags['website']                          AS website,
    tags['wikidata']                         AS wikidata,
    tags['wikipedia']                        AS wikipedia,
    tags['access']                           AS access,
    tags['bar']                              AS bar,
    tags['bicycle_parking']                  AS bicycle_parking,
    tags['building']                         AS building,
    tags['check_date']                       AS check_date,
    prefix_map('check_date:', tags)          AS check_dates,
    split_multi(tags['cuisine'])             AS cuisine,
    prefix_map('food:', tags)                AS foods,
    prefix_map('drink:', tags)               AS drinks,
    prefix_map('diet:', tags)                AS diets,
    tags['denomination']                     AS denomination,
    tags['description']                      AS description,
    tags['emergency']                        AS emergency,
    tags['fountain']                         AS fountain,
    tags['healthcare:speciality']            AS "healthcare:speciality",
    tags['heritage']                         AS heritage,
    tags['nursery']                          AS nursery,
    tags['opening_hours']                    AS opening_hours,
    tags['preschool']                        AS preschool,
    tags['recycling_type']                   AS recycling_type,
    tags['religion']                         AS religion,
    tags['self_service']                     AS self_service,
    tags['shelter']                          AS shelter,
    tags['social_facility']                  AS social_facility,
    tags['social_facility:for']              AS "social_facility:for",
    tags['source']                           AS source,
    tags['sport']                            AS sport,
    tags['wheelchair']                       AS wheelchair,
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
