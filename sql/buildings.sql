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
    {
      building:            tags['building'],
      "building:levels":   tags['building:levels'],
      "building:flats":    tags['building:flats'],
      "building:material": tags['building:material'],
      "building:colour":   tags['building:colour'],
      "building:part":     tags['building:part'],
      "building:use":      tags['building:use'],
      name:                tags['name'],
      "addr:housenumber":  tags['addr:housenumber'],
      "addr:street":       tags['addr:street'],
      "addr:city":         tags['addr:city'],
      "addr:postcode":     tags['addr:postcode'],
      website:             tags['website'],
      wikipedia:           tags['wikipedia'],
      wikidata:            tags['wikidata'],
      height:              tags['height'],
      "roof:shape":        tags['roof:shape'],
      "roof:levels":       tags['roof:levels'],
      "roof:colour":       tags['roof:colour'],
      "roof:material":     tags['roof:material'],
      "roof:orientation":  tags['roof:orientation'],
      "roof:height":       tags['roof:height'],
      start_date:          tags['start_date'],
      access:              tags['access'],
      wheelchair:          tags['wheelchair']
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
