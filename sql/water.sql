CREATE OR REPLACE TEMP TABLE bridges_unfiltered AS
SELECT type, id, tags, geometry
FROM '{{INPUT}}'
WHERE tags['man_made'] = 'bridge' OR tags['bridge'] IS NOT NULL;

CREATE OR REPLACE TEMP TABLE water_features AS
SELECT type, id, tags, geometry
FROM '{{INPUT}}'
WHERE (
          (kind = 'line' AND tags['waterway'] IS NOT NULL) OR
          (kind = 'area' AND (
            tags['natural'] IN ('water', 'coastline', 'wetland') OR
            tags['landuse'] IN ('basin', 'reservoir', 'harbour') OR
            tags['waterway'] IS NOT NULL
          )) OR
          tags['man_made'] IN ('pier', 'breakwater', 'groyne', 'lighthouse', 'beacon', 'buoy', 'offshore_platform', 'pumping_station', 'water_well', 'spring') OR
          (
            tags['man_made'] = 'monitoring_station' AND (
              tags['monitoring:water'] IS NOT NULL OR
              tags['monitoring:water_level'] IS NOT NULL OR
              tags['monitoring:water_quality'] IS NOT NULL
            )
          ) OR
          tags['historic'] IN ('wreck','ship', 'aquaduct') OR
          tags['seamark:type'] IS NOT NULL OR
          tags['route'] IN ('ferry', 'portage') OR
          tags['leisure'] IN ('slipway', 'marina', 'swimming_pool', 'swimming_area', 'water_park') OR
          tags['amenity'] IN ('drinking_water', 'foot_shower', 'shower', 'boat_rental') OR
          tags['sport'] IN ('canoe', 'cliff_diving', 'diving', 'dragon_boat', 'rowing', 'sailing', 'scuba_diving', 'surfing', 'swimming', 'wakeboarding', 'water_ski', 'windsurfing') OR
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
              -- Unfortunately not all tsunami assembly points have the correct assembly_point:tsunami tag
              -- https://www.openstreetmap.org/node/4368193931
              tags['assembly_point:tsunami'] IS NOT NULL OR
              tags['assembly_point:storm_surge'] IS NOT NULL
            )
          ) OR
          tags['ford'] IS NOT NULL OR
          tags['tidal'] IS NOT NULL OR
          tags['flood_prone'] IS NOT NULL OR
          tags['whitewater'] IS NOT NULL OR
          tags['club'] in ('sailing', 'scuba_diving', 'surf_life_saving')
);

-- Known to exclude https://www.openstreetmap.org/way/35457618 from the Oregon region
CREATE OR REPLACE TEMP TABLE water_bridges AS
SELECT b.type, b.id, b.tags, b.geometry
FROM bridges_unfiltered b
JOIN water_features w
  ON b.geometry && w.geometry
  WHERE ST_Intersects(b.geometry, w.geometry);

COPY (
  WITH raw AS (
    -- We call `SELECT DISTINCT` here instead of when the building of the "water_bridges" table
    -- to work around a floating point exception which randomly goes away if you `PRAGMA threads = 1`
    SELECT DISTINCT type, id, tags, geometry FROM water_bridges

    UNION ALL
      SELECT type, id, tags, geometry FROM water_features
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
    tags['mooring']                          AS mooring,
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
    tags['whitewater']                       AS whitewater,
    tags['shop']                             AS shop,
    prefix_map('seamark:', tags)             AS seamark,
    prefix_map('assembly_point:', tags)      AS assembly_point,
    prefix_map('monitoring:', tags)          AS monitoring,
    prefix_map('whitewater:', tags)          AS whitewater_map,
    prefix_map('addr:', tags)                AS addr,
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