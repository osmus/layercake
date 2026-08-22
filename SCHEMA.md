# Layercake schema

Generated from the SQL layer definitions in [`sql/`](sql/).

For an exact version of the deployed schema, use duckdb to check ex.

`DESCRIBE SELECT * FROM 'https://data.openstreetmap.us/layercake/parks.parquet';`

## addresses

`type`, `id`, `addr:housenumber`, `addr:housename`, `addr:conscriptionnumber`, `addr:streetnumber`, `addr:provisionalnumber`, `addr:flats`, `addr:unit`, `addr:floor`, `addr:door`, `addr:street`, `addr:place`, `addr:city`, `addr:postcode`, `addr:hamlet`, `addr:district`, `addr:suburb`, `addr:neighbourhood`, `addr:quarter`, `addr:block_number`, `addr:block`, `addr:village`, `addr:town`, `addr:subdistrict`, `addr:county`, `addr:province`, `addr:state`, `addr:country`, `addr:full`, `bbox`, `geometry`
## boundaries

`type`, `id`, `boundary`, `admin_level`, `name`, `names`, `official_name`, `official_names`, `int_name`, `alt_name`, `alt_names`, `place`, `border_type`, `ISO3166-2`, `ISO3166-1:alpha2`, `ISO3166-1:alpha3`, `wikidata`, `wikipedia`, `disputed_by`, `claimed_by`, `controlled_by`, `recognized_by`, `bbox`, `geometry`
## buildings

`type`, `id`, `building`, `building:levels`, `building:flats`, `building:material`, `building:colour`, `building:part`, `building:use`, `name`, `website`, `wikipedia`, `wikidata`, `height`, `roof:shape`, `roof:levels`, `roof:colour`, `roof:material`, `roof:orientation`, `roof:height`, `start_date`, `access`, `wheelchair`, `bbox`, `geometry`
## highways

`type`, `id`, `highway`, `service`, `crossing`, `cycleway`, `cycleway:left`, `cycleway:right`, `footway`, `construction`, `name`, `ref`, `bridge`, `covered`, `lanes`, `layer`, `lit`, `sidewalk`, `smoothness`, `surface`, `tracktype`, `tunnel`, `wheelchair`, `width`, `access`, `bicycle`, `bus`, `foot`, `hgv`, `maxspeed`, `motor_vehicle`, `motorcycle`, `oneway`, `toll`, `bbox`, `geometry`
## parks

`type`, `id`, `boundary`, `protected_area`, `leisure`, `name`, `names`, `short_name`, `short_names`, `official_name`, `official_names`, `protect_class`, `protection_title`, `protected`, `iucn_level`, `access`, `operator`, `operator:type`, `owner`, `ownership`, `start_date`, `related_law`, `website`, `wikidata`, `wikipedia`, `bbox`, `geometry`
## pois

`type`, `id`, `amenity`, `attraction`, `club`, `craft`, `education`, `healthcare`, `historic`, `leisure`, `office`, `playground`, `shop`, `tourism`, `landuse`, `natural`, `name`, `names`, `official_name`, `official_names`, `old_name`, `old_names`, `alt_name`, `alt_names`, `short_name`, `short_names`, `brand`, `brand:wikidata`, `operator`, `operator:wikidata`, `phone`, `email`, `website`, `wikidata`, `wikipedia`, `access`, `bar`, `bicycle_parking`, `building`, `check_date`, `check_dates`, `cuisine`, `foods`, `drinks`, `diets`, `denomination`, `description`, `emergency`, `fountain`, `healthcare:speciality`, `heritage`, `nursery`, `opening_hours`, `preschool`, `recycling_type`, `religion`, `self_service`, `shelter`, `social_facility`, `social_facility:for`, `source`, `sport`, `wheelchair`, `bbox`, `geometry`
## settlements

`type`, `id`, `place`, `name`, `names`, `alt_name`, `alt_names`, `official_name`, `official_names`, `wikidata`, `wikipedia`, `population`, `bbox`, `geometry`
## waterways

`type`, `id`, `waterway`, `name`, `names`, `ref`, `intermittent`, `layer`, `bridge`, `tunnel`, `access`, `usage`, `seasonal`, `tidal`, `width`, `depth`, `oneway`, `lock`, `lock`, `lock`, `motorboat`, `ship`, `sailboat`, `boat`, `canoe`, `open_water`, `narrow`, `rapids`, `rapids:name`, `hazard`, `bbox`, `geometry`
