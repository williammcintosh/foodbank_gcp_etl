-- Create a new table for foodbank locations using name and district as unique identifiers
CREATE OR REPLACE TABLE foodbanks_locations (
    name VARCHAR,
    district VARCHAR,
    latitude FLOAT,
    longitude FLOAT
);

-- Populate locations with unique (name, district) combinations
INSERT INTO foodbanks_locations (name, district, latitude, longitude)
SELECT 
    LOWER(name) AS name,
    district,
    CAST(SPLIT_PART(latt_long, ',', 1) AS FLOAT) AS latitude,
    CAST(SPLIT_PART(latt_long, ',', 2) AS FLOAT) AS longitude
FROM 
    foodbanks_details;

-- Create the distances table with (name, district) as unique identifiers
CREATE OR REPLACE TABLE foodbank_distances (
    foodbank_name_1 VARCHAR,
    foodbank_district_1 VARCHAR,
    foodbank_name_2 VARCHAR,
    foodbank_district_2 VARCHAR,
    distance_km FLOAT
);

-- Insert distance data between each unique foodbank pair
INSERT INTO foodbank_distances (foodbank_name_1, foodbank_district_1, foodbank_name_2, foodbank_district_2, distance_km)
SELECT 
    f1.name AS foodbank_name_1,
    f1.district AS foodbank_district_1,
    f2.name AS foodbank_name_2,
    f2.district AS foodbank_district_2,
    6371 * ACOS(
        LEAST(
            COS(RADIANS(f1.latitude)) * COS(RADIANS(f2.latitude)) *
            COS(RADIANS(f2.longitude) - RADIANS(f1.longitude)) +
            SIN(RADIANS(f1.latitude)) * SIN(RADIANS(f2.latitude)),
            1
        )
    ) AS distance_km
FROM 
    foodbanks_locations AS f1
JOIN 
    foodbanks_locations AS f2
ON 
    f1.name != f2.name OR f1.district != f2.district  -- Avoid self-joins
WHERE
    f1.name < f2.name OR (f1.name = f2.name AND f1.district < f2.district);  -- Avoid duplicate pairs


    
SELECT TOP 30 * FROM FOODBANK_DISTANCES;
