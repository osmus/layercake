COPY (
  WITH raw AS (
    SELECT type, id, tags, version, timestamp, ST_PointOnSurface(geometry) AS geometry
    FROM '{{INPUT}}'
    WHERE (kind = 'node' OR kind = 'area')
      AND (
        tags['addr:housenumber'] IS NOT NULL OR
        tags['addr:housename']   IS NOT NULL
      )
  )
  SELECT
    type,
    id,
    tags['addr:housenumber']         AS "addr:housenumber",
    tags['addr:housename']           AS "addr:housename",
    -- Conscription, street, and provisional numbers used in Czechia and Slovakia
    tags['addr:conscriptionnumber']  AS "addr:conscriptionnumber",
    tags['addr:streetnumber']        AS "addr:streetnumber",
    tags['addr:provisionalnumber']   AS "addr:provisionalnumber",
    tags['addr:flats']               AS "addr:flats",
    tags['addr:unit']                AS "addr:unit",
    tags['addr:floor']               AS "addr:floor",
    tags['addr:door']                AS "addr:door",
    tags['addr:street']              AS "addr:street",
    -- Not all addresses have a street; see https://wiki.openstreetmap.org/wiki/Key:addr:place
    tags['addr:place']               AS "addr:place",
    tags['addr:city']                AS "addr:city",
    tags['addr:postcode']            AS "addr:postcode",
    tags['addr:hamlet']              AS "addr:hamlet",
    tags['addr:district']            AS "addr:district",
    tags['addr:suburb']              AS "addr:suburb",
    tags['addr:neighbourhood']       AS "addr:neighbourhood",
    tags['addr:quarter']             AS "addr:quarter",
    -- Block-based addressing, e.g. in Japan
    tags['addr:block_number']        AS "addr:block_number",
    tags['addr:block']               AS "addr:block",
    -- Other administrative areas
    tags['addr:village']             AS "addr:village",
    tags['addr:town']                AS "addr:town",
    tags['addr:subdistrict']         AS "addr:subdistrict",
    tags['addr:county']              AS "addr:county",
    tags['addr:province']            AS "addr:province",
    tags['addr:state']               AS "addr:state",
    tags['addr:country']             AS "addr:country",
    -- Full, unstructured address; not machine-readable but maybe useful
    tags['addr:full']                AS "addr:full",
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
