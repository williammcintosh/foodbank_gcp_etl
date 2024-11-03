
-- Create or replace file format for GCP JSON files
create or replace file format UK_FOOD_DONATION.PUBLIC.FILEFORMAT_GCP_JSON
    TYPE = JSON
    STRIP_OUTER_ARRAY = true;  -- this handles the outer brackets in your JSON array


-- Update stage object to use JSON file format
create or replace stage UK_FOOD_DONATION.public.stage_gcp_needs
    STORAGE_INTEGRATION = gcp_integration
    URL = 'gcs://uk-food-donation-bucket/data_via_direct_download/needs'
    FILE_FORMAT = fileformat_gcp_json;

    
LIST @UK_FOOD_DONATION.public.stage_gcp_needs;


-- Create a staging table to load JSON data
CREATE OR REPLACE TABLE NEEDS_STAGE (data VARIANT);

-- Copy the JSON data into the staging area
COPY INTO NEEDS_STAGE
FROM @UK_FOOD_DONATION.public.stage_gcp_needs
FILE_FORMAT = FILEFORMAT_GCP_JSON;


-- Now, extract fields from the data column in NEEDS_STAGE and insert them into the NEEDS table:
-- Ensure final table has composite primary key for uniqueness
CREATE OR REPLACE TABLE NEEDS (
    id varchar,
    found timestamp,
    foodbank_name varchar,
    foodbank_slug varchar,
    needs varchar,
    excess varchar,
    self varchar,
    CONSTRAINT unique_id_found UNIQUE (id, found)  -- enforce uniqueness on id + found
);

-- Load JSON data with transformation, ensuring unique rows based on (id, found)
MERGE INTO NEEDS AS target
USING (
    SELECT 
        data:id::string AS id,
        data:found::timestamp AS found,
        data:foodbank.name::string AS foodbank_name,
        data:foodbank.slug::string AS foodbank_slug,
        data:needs::string AS needs,
        data:excess::string AS excess,
        data:self::string AS self
    FROM NEEDS_STAGE
) AS source
ON target.id = source.id AND target.found = source.found
WHEN NOT MATCHED THEN
    INSERT (id, found, foodbank_name, foodbank_slug, needs, excess, self)
    VALUES (source.id, source.found, source.foodbank_name, source.foodbank_slug, source.needs, source.excess, source.self);

DROP TABLE NEEDS_STAGE;


SELECT TOP 30 * FROM NEEDS;

