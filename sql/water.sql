COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'line'
      AND tags['waterway'] IN ('river', 'stream', 'canal', 'ditch', 'drain', 'flowline', 'fairway', 'link',
        -- Reason: Routing obstructions.
        'dam', 'weir', 'waterfall'
      )
  )
  SELECT
    type,
    id,
    tags['waterway']        AS waterway,
    tags['name']            AS name,
    tags['ref']             AS ref,
    tags['intermittent']    AS intermittent,
    tags['layer']           AS layer,
    tags['bridge']          AS bridge,
    tags['tunnel']          AS tunnel,
    tags['access']          AS access,
    
    -- waterway-relevant tags i've added or changed...   
      -- Reason: general
      tags['usage']           AS usage,
      tags['natural']         AS natural,
      split_multi(tags['seasonal']) AS seasonal,
      tags['tidal']           AS tidal,

      -- Reason: dimensions.
      tags['width']           AS width,
      tags['depth']           AS depth,
      tags['depth:']          AS 'depth:',
      tags['height']          AS height,    -- For waterfalls?

      -- Reason: navigation direction and obstruction bypass,
      prefix_map('oneway:', tags)    AS 'oneway:',
      tags['oneway']          AS oneway,
      tags['canoe_pass']      AS canoe_pass,
      tags['lock']            AS lock,

      -- Boat access
      map_from_tag_list(tags, ['motorboat', 'ship', 'sailboat', 'boat', 'canoe']) as vessel_access,

      -- Reason: Hazards,
      tags['open_water']      AS open_water,
      prefix_map('whitewater:', tags) AS whitewater,
      tags['narrow']          AS narrow,
      tags['rapids']          AS rapids,
      tags['rapids:']         AS rapids,
      tags['hazard']          AS hazard,

      -- Reason: Fish navigation?
      tags['fish_pass']       AS fish_pass,   
      -- Reason: hydrology
      tags['order:strahler']  AS 'order:strahler',
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
