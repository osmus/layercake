
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
SELECT assert_map_not_empty('seamark');
SELECT assert_map_not_empty('assembly_point');
