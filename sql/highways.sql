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
    tags['highway']         AS highway,
    tags['service']         AS service,
    tags['crossing']        AS crossing,
    tags['cycleway']        AS cycleway,
    tags['cycleway:left']   AS "cycleway:left",
    tags['cycleway:right']  AS "cycleway:right",
    tags['footway']         AS footway,
    tags['construction']    AS construction,
    tags['name']            AS name,
    tags['ref']             AS ref,
    tags['bridge']          AS bridge,
    tags['covered']         AS covered,
    tags['lanes']           AS lanes,
    tags['layer']           AS layer,
    tags['lit']             AS lit,
    tags['sidewalk']        AS sidewalk,
    tags['smoothness']      AS smoothness,
    tags['surface']         AS surface,
    tags['tracktype']       AS tracktype,
    tags['tunnel']          AS tunnel,
    tags['wheelchair']      AS wheelchair,
    tags['width']           AS width,
    tags['access']          AS access,
    tags['bicycle']         AS bicycle,
    tags['bus']             AS bus,
    tags['foot']            AS foot,
    tags['hgv']             AS hgv,
    tags['maxspeed']        AS maxspeed,
    tags['motor_vehicle']   AS motor_vehicle,
    tags['motorcycle']      AS motorcycle,
    tags['oneway']          AS oneway,
    tags['toll']            AS toll,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
