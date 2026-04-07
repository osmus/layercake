COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE (kind = 'node' OR kind = 'area')
      AND (
        tags['boundary'] IN ('national_park', 'protected_area')
        OR tags['leisure'] IN ('park', 'nature_reserve')
      )
  )
  SELECT
    type,
    id,
    {
      boundary:          tags['boundary'],
      protected_area:    tags['protected_area'],
      leisure:           tags['leisure'],
      name:              split_multi(tags['name']),
      names:             prefix_map_split('name:', tags),
      short_name:        split_multi(tags['short_name']),
      short_names:       prefix_map_split('short_name:', tags),
      official_name:     split_multi(tags['official_name']),
      official_names:    prefix_map_split('official_name:', tags),
      protect_class:     tags['protect_class'],
      protection_title:  tags['protection_title'],
      protected:         tags['protected'],
      iucn_level:        tags['iucn_level'],
      access:            tags['access'],
      operator:          tags['operator'],
      "operator:type":   tags['operator:type'],
      owner:             tags['owner'],
      ownership:         tags['ownership'],
      start_date:        tags['start_date'],
      related_law:       tags['related_law'],
      website:           tags['website'],
      wikidata:          tags['wikidata'],
      wikipedia:         tags['wikipedia']
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
