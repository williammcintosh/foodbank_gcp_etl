-- Enable PostGIS extension to use geographic functions
CREATE EXTENSION IF NOT EXISTS postgis;

-- Drop and recreate the foodbanks_locations table with GEOGRAPHY data type for latitude and longitude
DROP TABLE IF EXISTS foodbanks_locations;
CREATE TABLE foodbanks_locations (
    name VARCHAR,
    district VARCHAR,
    location GEOGRAPHY(POINT, 4326)  -- 4326 is the SRID for WGS84, standard lat-long
);

-- Populate locations with unique (name, district) combinations
INSERT INTO foodbanks_locations (name, district, location)
SELECT 
    LOWER(name) AS name,
    district,
    ST_SetSRID(ST_MakePoint(
        CAST(SPLIT_PART(latt_long, ',', 2) AS FLOAT),  -- Longitude
        CAST(SPLIT_PART(latt_long, ',', 1) AS FLOAT)   -- Latitude
    ), 4326) AS location
FROM 
    foodbanks_details;

-- Drop and recreate the foodbanks_distances table
DROP TABLE IF EXISTS foodbanks_distances;
CREATE TABLE foodbanks_distances (
    foodbank_name_1 VARCHAR,
    foodbank_district_1 VARCHAR,
    foodbank_name_2 VARCHAR,
    foodbank_district_2 VARCHAR,
    distance_km FLOAT
);

-- Calculate distances between each unique foodbank pair
INSERT INTO foodbanks_distances (foodbank_name_1, foodbank_district_1, foodbank_name_2, foodbank_district_2, distance_km)
SELECT 
    f1.name AS foodbank_name_1,
    f1.district AS foodbank_district_1,
    f2.name AS foodbank_name_2,
    f2.district AS foodbank_district_2,
    ST_Distance(f1.location, f2.location) / 1000 AS distance_km  -- Divide by 1000 to get kilometers
FROM 
    foodbanks_locations AS f1
JOIN 
    foodbanks_locations AS f2
ON 
    f1.name != f2.name OR f1.district != f2.district  -- Avoid self-joins
WHERE
    f1.name < f2.name OR (f1.name = f2.name AND f1.district < f2.district);  -- Avoid duplicate pairs
