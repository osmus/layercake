COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE tags['highway'] IS NOT NULL
      AND (
        kind = 'node'
        OR (kind = 'line' AND (tags['area'] IS NULL OR tags['area'] != 'yes'))
        OR (kind = 'area' AND (type = 'relation' OR tags['area'] = 'yes'))
      )
  )
  SELECT
    type,
    id,
    {
      highway:            tags['highway'],
      service:            tags['service'],
      crossing:           tags['crossing'],
      cycleway:           tags['cycleway'],
      "cycleway:left":    tags['cycleway:left'],
      "cycleway:right":   tags['cycleway:right'],
      footway:            tags['footway'],
      construction:       tags['construction'],
      name:               tags['name'],
      ref:                tags['ref'],
      bridge:             tags['bridge'],
      covered:            tags['covered'],
      lanes:              tags['lanes'],
      "layer":            tags['layer'],
      lit:                tags['lit'],
      sidewalk:           tags['sidewalk'],
      smoothness:         tags['smoothness'],
      surface:            tags['surface'],
      tracktype:          tags['tracktype'],
      tunnel:             tags['tunnel'],
      wheelchair:         tags['wheelchair'],
      width:              tags['width'],
      access:             tags['access'],
      bicycle:            tags['bicycle'],
      bus:                tags['bus'],
      foot:               tags['foot'],
      hgv:                tags['hgv'],
      maxspeed:           tags['maxspeed'],
      motor_vehicle:      tags['motor_vehicle'],
      motorcycle:         tags['motorcycle'],
      oneway:             tags['oneway'],
      toll:               tags['toll']
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
