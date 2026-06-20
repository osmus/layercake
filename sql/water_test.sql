
-- This script unforunately depends on values being present in the region, it
-- has been known to succesfully pass with https://download.geofabrik.de/north-america/us/washington-latest.osm.pbf
.mode trash
CREATE VIEW water AS SELECT * FROM '{{OUTPUT}}';
SELECT assert_col_not_empty('natural');
SELECT assert_col_not_empty('waterway');
SELECT assert_col_not_empty('man_made');
SELECT assert_col_not_empty('historic');
SELECT assert_col_not_empty('route');
SELECT assert_col_not_empty('intermittent');
SELECT assert_col_not_empty('tunnel');
SELECT assert_col_not_empty('covered');
SELECT assert_col_not_empty('salt');
SELECT assert_col_not_empty('boat');
SELECT assert_col_not_empty('motorboat');
SELECT assert_col_not_empty('canoe');
SELECT assert_col_not_empty('highway');
SELECT assert_col_not_empty('portage');
SELECT assert_col_not_empty('canoe');
SELECT assert_col_not_empty('mooring');
SELECT assert_col_not_empty('intermittent');
SELECT assert_col_not_empty('seasonal');
SELECT assert_col_not_empty('water');
SELECT assert_col_not_empty('bridge');
SELECT assert_col_not_empty('lifeguard');
SELECT assert_col_not_empty('emergency');
SELECT assert_col_not_empty('landuse');
SELECT assert_col_not_empty('industrial');
SELECT assert_col_not_empty('amenity');
SELECT assert_col_not_empty('ford');
SELECT assert_col_not_empty('tidal');
SELECT assert_col_not_empty('flood_prone');

SELECT assert_map_not_empty('seamark');
SELECT assert_map_not_empty('assembly_point');
SELECT assert_map_not_empty('monitoring');

SELECT assert_tag_not_empty('leisure','slipway');
SELECT assert_tag_not_empty('lifeguard','tower');
SELECT assert_tag_not_empty('emergency','lifeguard');
SELECT assert_tag_not_empty('landuse','basin');
SELECT assert_tag_not_empty('landuse','reservoir');
SELECT assert_tag_not_empty('landuse','harbour');
SELECT assert_tag_not_empty('route','portage');
SELECT assert_tag_not_empty('route','ferry');
SELECT assert_tag_not_empty('historic','wreck');
SELECT assert_tag_not_empty('historic','ship');
SELECT assert_tag_not_empty('man_made','pier');
SELECT assert_tag_not_empty('man_made','breakwater');
SELECT assert_tag_not_empty('man_made','groyne');
SELECT assert_tag_not_empty('man_made','lighthouse');
SELECT assert_tag_not_empty('man_made','beacon');
SELECT assert_tag_not_empty('man_made','buoy');
SELECT assert_tag_not_empty('man_made','pumping_station');
SELECT assert_tag_not_empty('man_made','water_well');
SELECT assert_tag_not_empty('man_made','bridge');

SELECT assert_stmt_not_empty('SELECT 1 FROM water WHERE ("landuse" = ''industrial'' AND "industrial" = ''port'') LIMIT 1');

-- Not present in the washington region
-- SELECT assert_tag_not_empty('man_made','offshore_platform');
-- SELECT assert_tag_not_empty('man_made','spring');
-- SELECT assert_tag_not_empty('emergency','lifeboat_station');
-- SELECT assert_tag_not_empty('emergency','marine_rescue');
-- SELECT assert_tag_not_empty('emergency','water_rescue');
-- SELECT assert_tag_not_empty('historic','aquaduct');