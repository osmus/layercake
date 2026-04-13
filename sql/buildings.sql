COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'area'
      AND tags['building'] IS NOT NULL
      -- AND tags['building'] != 'no'
  )
  SELECT
    type,
    id,
    tags['building']            AS building,
    tags['building:levels']     AS "building:levels",
    tags['building:flats']      AS "building:flats",
    tags['building:material']   AS "building:material",
    tags['building:colour']     AS "building:colour",
    tags['building:part']       AS "building:part",
    tags['building:use']        AS "building:use",
    tags['name']                AS name,
    tags['addr:housenumber']    AS "addr:housenumber",
    tags['addr:street']         AS "addr:street",
    tags['addr:city']           AS "addr:city",
    tags['addr:postcode']       AS "addr:postcode",
    tags['website']             AS website,
    tags['wikipedia']           AS wikipedia,
    tags['wikidata']            AS wikidata,
    tags['height']              AS height,
    tags['roof:shape']          AS "roof:shape",
    tags['roof:levels']         AS "roof:levels",
    tags['roof:colour']         AS "roof:colour",
    tags['roof:material']       AS "roof:material",
    tags['roof:orientation']    AS "roof:orientation",
    tags['roof:height']         AS "roof:height",
    tags['start_date']          AS start_date,
    tags['access']              AS access,
    tags['wheelchair']          AS wheelchair,
    {
      xmin: ST_XMin(geometry)::FLOAT,
      ymin: ST_YMin(geometry)::FLOAT,
      xmax: ST_XMax(geometry)::FLOAT,
      ymax: ST_YMax(geometry)::FLOAT
    } AS bbox,
    geometry
  FROM raw
) TO '{{OUTPUT}}' WITH (FORMAT PARQUET, COMPRESSION ZSTD);
