COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'line'
      AND tags['waterway'] IN ('river', 'stream', 'canal', 'ditch', 'drain', 'flowline', 'fairway', 'link')
  )
  SELECT
    type,
    id,
    tags['waterway']        AS waterway,
    split_multi(tags['name']) AS name,
    prefix_map_split('name:', tags) AS names,
    tags['ref']             AS ref,
    tags['intermittent']    AS intermittent,
    tags['layer']           AS layer,
    tags['bridge']          AS bridge,
    tags['tunnel']          AS tunnel,
    tags['access']          AS access,
    -- General
    tags['usage']           AS usage,
    split_multi(tags['seasonal']) AS seasonal,
    tags['tidal']           AS tidal,
    -- Dimensions.
    tags['width']           AS width,
    tags['depth']           AS depth,
    -- Navigation direction and obstruction bypass,
    tags['oneway']          AS oneway,
    tags['lock']            AS lock,
    tags['lock_name']       AS lock,
    tags['lock_ref']        AS lock,
    -- Boat access
    tags['motorboat']	      AS motorboat,
    tags['ship']            AS ship,
    tags['sailboat']	      AS sailboat,
    tags['boat']            AS boat,
    tags['canoe']   	      AS canoe,
    -- Reason: Hazards,
    tags['open_water']      AS open_water,
    tags['narrow']          AS narrow,
    tags['rapids']          AS rapids,
    tags['rapids:name']     AS 'rapids:name',
    tags['hazard']          AS hazard,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
