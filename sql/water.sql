COPY (
  WITH raw AS (
    SELECT x.type, x.id, x.tags, x.geometry
    FROM '{{INPUT}}' as x
    WHERE (
        x.tags['natural'] IN ('water', 'coastline', 'wetland') OR
        x.tags['waterway'] IS NOT NULL OR
        x.tags['man_made'] IN ('pier', 'breakwater', 'groyne', 'lighthouse', 'beacon', 'buoy', 'offshore_platform', 'pumping_station', 'water_well', 'spring') OR
        (
          x.tags['man_made'] = 'monitoring_station' AND (
            x.tags['monitoring:water'] IS NOT NULL OR
            x.tags['monitoring:water_level'] IS NOT NULL OR
            x.tags['monitoring:water_quality'] IS NOT NULL
          )
        ) OR
        ( -- Bridges that intersect water
          (x.tags['man_made'] = 'bridge' OR x.tags['bridge'] IS NOT NULL) AND EXISTS (
            SELECT 1
            FROM '{{INPUT}}' AS w
            WHERE (
              (w.kind = 'line' AND w.tags['waterway'] IS NOT NULL) OR
              (w.kind = 'area' AND (w.tags['natural'] IN ('water', 'coastline', 'wetland') OR w.tags['landuse'] IN ('basin', 'reservoir', 'harbour') OR w.tags['waterway'] IS NOT NULL))
            )
            AND ST_Intersects(x.geometry, w.geometry)
          )
        ) OR
        x.tags['historic'] IN ('wreck','ship', 'aquaduct') OR
        x.tags['seamark:type'] IS NOT NULL OR
        x.tags['route'] IN ('ferry', 'portage') OR
        x.tags['leisure'] IN ('slipway', 'marina', 'swimming_pool', 'swimming_area', 'water_park') OR
        x.tags['amenity'] IN ('drinking_water', 'foot_shower', 'shower') OR
        x.tags['sport'] IN ('canoe', 'cliff_diving', 'diving', 'dragon_boat', 'rowing', 'sailing', 'scuba_diving', 'surfing', 'swimming', 'wakeboarding', 'water_ski', 'windsurfing') OR
        x.tags['portage'] IS NOT NULL OR
        x.tags['canoe'] IS NOT NULL OR
        x.tags['mooring'] IS NOT NULL OR
        (x.tags['landuse'] = 'industrial' AND x.tags['industrial'] = 'port') OR
        ( -- All deprecated in favor of tags['emergency'] = 'water_rescue'
          x.tags['emergency'] IN ('lifeboat_station', 'marine_rescue') OR
          x.tags['amenity'] = 'lifeboat_station'
        ) OR
        x.tags['emergency'] IN ( 'lifeguard', 'water_rescue', 'life_ring', 'throw_bag', 'rescue_buoy') OR
        (
          x.tags['emergency'] = 'assembly_point' AND (
            -- Unfortunately not all tsunami assembly points have the correct assembly_point:tsunami tag
            -- https://www.openstreetmap.org/node/4368193931
            x.tags['assembly_point:tsunami'] IS NOT NULL OR
            x.tags['assembly_point:storm_surge'] IS NOT NULL
          )
        ) OR
        x.tags['ford'] IS NOT NULL OR
        x.tags['tidal'] IS NOT NULL OR
        x.tags['flood_prone'] IS NOT NULL OR
        x.tags['landuse'] IN ('basin', 'reservoir', 'harbour') -- All deprecated synonyms
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
    tags['leisure']                          AS leisure,
    tags['access']                           AS access,
    tags['fee']                              AS fee,
    tags['surface']                          AS surface,
    tags['ford']                             AS ford,
    tags['tidal']                            AS tidal,
    tags['flood_prone']                      AS flood_prone,
    tags['sport']                            AS sport,
    tags['wheelchair']                       AS wheelchair,
    tags['club']                             AS club,
    prefix_map('seamark:', tags)             AS seamark,
    prefix_map('assembly_point:', tags)      AS assembly_point,
    prefix_map('monitoring:', tags)          AS monitoring,
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