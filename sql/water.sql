COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE (
        tags['natural'] IN ('water', 'coastline', 'wetland') OR
        tags['waterway'] IS NOT NULL OR
        tags['man_made'] IN ('pier', 'breakwater', 'groyne', 'lighthouse', 'beacon', 'buoy', 'offshore_platform', 'pumping_station', 'water_well', 'spring', 'bridge') OR
        (
          tags['man_made'] = 'monitoring_station' AND (
            tags['monitoring:water'] = 'yes' OR 
            tags['monitoring:water_level'] = 'yes' OR 
            tags['monitoring:water_quality'] = 'yes'
          )
        ) OR
        tags['historic'] IN ('wreck','ship', 'aquaduct') OR
        tags['seamark:type'] IS NOT NULL OR
        tags['route'] IN ('ferry', 'portage') OR
        tags['leisure'] IN ('slipway', 'marina') OR
        tags['portage'] IS NOT NULL OR
        tags['canoe'] IS NOT NULL OR
        tags['mooring'] IS NOT NULL OR
        (tags['landuse'] = 'industrial' AND tags['industrial'] = 'port') OR
        ( -- All deprecated in favor of tags['emergency'] = 'water_rescue'
          tags['emergency'] IN ('lifeboat_station', 'marine_rescue') OR
          tags['amenity'] = 'lifeboat_station'
        ) OR
        tags['emergency'] IN ( 'lifeguard', 'water_rescue', 'life_ring', 'throw_bag', 'rescue_buoy') OR
        (
          tags['emergency'] = 'assembly_point' AND (
            tags['assembly_point:tsunami'] IS NOT NULL OR
            tags['assembly_point:storm_surge'] IS NOT NULL
          )
        ) OR
        tags['landuse'] IN ('basin', 'reservoir', 'harbour') -- All deprecated synonyms
      )
  )
  SELECT
    type,
    id,
    tags['natural']                          AS "natural",
    tags['waterway']                         AS waterway,
    tags['man_made']                         AS man_made,
    tags['historic']                         AS historic,
    tags['route']                            AS route,
    tags['intermittent']                     AS intermittent,
    tags['tunnel']                           AS tunnel,
    tags['covered']                          AS covered,
    tags['salt']                             AS salt,
    tags['boat']                             AS boat,
    tags['motorboat']                        AS motorboat,
    tags['canoe']                            AS canoe,
    tags['highway']                          AS highway,
    tags['portage']                          AS portage,
    tags['canoe']                            AS canoe,
    tags['mooring']                          AS mooring,
    tags['intermittent']                     AS intermittent,
    tags['seasonal']                         AS seasonal,
    tags['water']                            AS water,
    tags['bridge']                           AS bridge,
    tags['lifeguard']                        AS lifeguard,
    tags['emergency']                        AS emergency,
    tags['landuse']                          AS landuse,
    tags['industrial']                       AS industrial,
    tags['amenity']                          AS amenity,
    prefix_map('seamark:', tags)             AS seamark,
    prefix_map('assembly_point:', tags)      AS assembly_point,
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
    tags['operator']                         AS operator,
    tags['description']                      AS description,
    tags['source']                           AS source,
    tags['wikidata']                         AS wikidata,
    tags['wikipedia']                        AS wikipedia,   
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);