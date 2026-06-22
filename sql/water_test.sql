
-- This script unforunately depends on values being present in the region, it
-- has been known to succesfully pass with https://download.geofabrik.de/north-america/us/washington-latest.osm.pbf
.mode trash
CREATE VIEW water AS SELECT * FROM '{{OUTPUT}}';
SELECT assert_col_not_empty('water', 'natural');
SELECT assert_col_not_empty('water', 'waterway');
SELECT assert_col_not_empty('water', 'man_made');
SELECT assert_col_not_empty('water', 'historic');
SELECT assert_col_not_empty('water', 'route');
SELECT assert_col_not_empty('water', 'intermittent');
SELECT assert_col_not_empty('water', 'tunnel');
SELECT assert_col_not_empty('water', 'covered');
SELECT assert_col_not_empty('water', 'salt');
SELECT assert_col_not_empty('water', 'boat');
SELECT assert_col_not_empty('water', 'motorboat');
SELECT assert_col_not_empty('water', 'canoe');
SELECT assert_col_not_empty('water', 'highway');
SELECT assert_col_not_empty('water', 'portage');
SELECT assert_col_not_empty('water', 'canoe');
SELECT assert_col_not_empty('water', 'mooring');
SELECT assert_col_not_empty('water', 'intermittent');
SELECT assert_col_not_empty('water', 'seasonal');
SELECT assert_col_not_empty('water', 'water');
SELECT assert_col_not_empty('water', 'bridge');
SELECT assert_col_not_empty('water', 'lifeguard');
SELECT assert_col_not_empty('water', 'emergency');
SELECT assert_col_not_empty('water', 'landuse');
SELECT assert_col_not_empty('water', 'industrial');
SELECT assert_col_not_empty('water', 'amenity');
SELECT assert_col_not_empty('water', 'ford');
SELECT assert_col_not_empty('water', 'tidal');
SELECT assert_col_not_empty('water', 'flood_prone');
SELECT assert_col_not_empty('water', 'wheelchair');
SELECT assert_col_not_empty('water', 'whitewater');
SELECT assert_col_not_empty('water', 'club');
SELECT assert_col_not_empty('water', 'shop');
SELECT assert_col_not_empty('water', 'canoe_rental');

SELECT assert_map_not_empty('water', 'seamark');
SELECT assert_map_not_empty('water', 'assembly_point');
SELECT assert_map_not_empty('water', 'monitoring');
-- Not present in the washington region
-- SELECT assert_map_not_empty('water', 'whitewater_map');

SELECT assert_tag_not_empty('water', 'leisure','slipway');
SELECT assert_tag_not_empty('water', 'lifeguard','tower');
SELECT assert_tag_not_empty('water', 'emergency','lifeguard');
SELECT assert_tag_not_empty('water', 'landuse','basin');
SELECT assert_tag_not_empty('water', 'landuse','reservoir');
SELECT assert_tag_not_empty('water', 'landuse','harbour');
SELECT assert_tag_not_empty('water', 'route','portage');
SELECT assert_tag_not_empty('water', 'route','ferry');
SELECT assert_tag_not_empty('water', 'historic','wreck');
SELECT assert_tag_not_empty('water', 'historic','ship');
SELECT assert_tag_not_empty('water', 'man_made','pier');
SELECT assert_tag_not_empty('water', 'man_made','breakwater');
SELECT assert_tag_not_empty('water', 'man_made','groyne');
SELECT assert_tag_not_empty('water', 'man_made','lighthouse');
SELECT assert_tag_not_empty('water', 'man_made','beacon');
SELECT assert_tag_not_empty('water', 'man_made','buoy');
SELECT assert_tag_not_empty('water', 'man_made','pumping_station');
SELECT assert_tag_not_empty('water', 'man_made','water_well');
SELECT assert_tag_not_empty('water', 'man_made','bridge');
SELECT assert_tag_not_empty('water', 'waterway','access_point');

-- Amenities and leisure
SELECT assert_tag_not_empty('water', 'amenity','drinking_water');
SELECT assert_tag_not_empty('water', 'amenity','foot_shower');
SELECT assert_tag_not_empty('water', 'amenity','shower');
SELECT assert_tag_not_empty('water', 'amenity','boat_rental');
SELECT assert_tag_not_empty('water', 'leisure','swimming_area');
SELECT assert_tag_not_empty('water', 'leisure','swimming_pool');
SELECT assert_tag_not_empty('water', 'leisure','water_park');
SELECT assert_tag_not_empty('water', 'sport', 'canoe');
SELECT assert_tag_not_empty('water', 'sport', 'diving');
SELECT assert_tag_not_empty('water', 'sport', 'rowing');
SELECT assert_tag_not_empty('water', 'sport', 'sailing');
SELECT assert_tag_not_empty('water', 'sport', 'scuba_diving');
SELECT assert_tag_not_empty('water', 'sport', 'surfing');
SELECT assert_tag_not_empty('water', 'sport', 'swimming');
SELECT assert_tag_not_empty('water', 'sport', 'water_ski');
SELECT assert_tag_not_empty('water', 'sport', 'windsurfing');
-- Not present in the washington region
--
-- SELECT assert_tag_not_empty('water', 'sport', 'cliff_diving');
-- SELECT assert_tag_not_empty('water', 'sport', 'dragon_boat');
-- SELECT assert_tag_not_empty('water', 'sport', 'wakeboarding');

SELECT assert_stmt_not_empty('SELECT 1 FROM water WHERE ("landuse" = ''industrial'' AND "industrial" = ''port'') LIMIT 1');

-- Not present in the washington region
-- SELECT assert_tag_not_empty('water', 'emergency','lifeboat_station');
-- SELECT assert_tag_not_empty('water', 'emergency','marine_rescue');
-- SELECT assert_tag_not_empty('water', 'emergency','water_rescue');
-- SELECT assert_tag_not_empty('water', 'man_made','offshore_platform');
-- SELECT assert_tag_not_empty('water', 'man_made','spring');
-- SELECT assert_tag_not_empty('water', 'historic','aquaduct');
