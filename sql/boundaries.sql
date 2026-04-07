COPY (
  WITH raw AS (
    SELECT type, id, tags, geometry
    FROM '{{INPUT}}'
    WHERE kind = 'area'
      AND tags['boundary'] IN ('administrative', 'aboriginal_lands', 'maritime', 'disputed', 'place')
  )
  SELECT
    type,
    id,
    {
      name:                  split_multi(tags['name']),
      names:                 prefix_map_split('name:', tags),
      official_name:         split_multi(tags['official_name']),
      official_names:        prefix_map_split('official_name:', tags),
      int_name:              split_multi(tags['int_name']),
      alt_name:              split_multi(tags['alt_name']),
      alt_names:             prefix_map_split('alt_name:', tags),
      type:                  tags['type'],
      admin_level:           tags['admin_level'],
      boundary:              tags['boundary'],
      place:                 tags['place'],
      border_type:           tags['border_type'],
      "ISO3166-2":           tags['ISO3166-2'],
      "ISO3166-1:alpha2":    tags['ISO3166-1:alpha2'],
      "ISO3166-1:alpha3":    tags['ISO3166-1:alpha3'],
      wikidata:              tags['wikidata'],
      wikipedia:             tags['wikipedia'],
      disputed_by:           split_multi(tags['disputed_by']),
      claimed_by:            split_multi(tags['claimed_by']),
      controlled_by:         split_multi(tags['controlled_by']),
      recognized_by:         split_multi(tags['recognized_by'])
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
