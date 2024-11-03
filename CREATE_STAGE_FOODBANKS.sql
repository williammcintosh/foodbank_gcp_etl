
-- Create or replace file format for GCP CSV files
create or replace file format UK_FOOD_DONATION.PUBLIC.FILEFORMAT_GCP
    TYPE = CSV                              -- Specify file type as CSV
    FIELD_DELIMITER = ','                   -- Use a comma as the field delimiter
    SKIP_HEADER = 1                         -- Skip the first row (header row)
    EMPTY_FIELD_AS_NULL = true              -- Interpret empty fields as NULL values
    ESCAPE_UNENCLOSED_FIELD = none          -- Do not escape unquoted fields
    ERROR_ON_COLUMN_COUNT_MISMATCH = false  -- Ignore column count mismatches to avoid load errors
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'      -- Handle fields enclosed in double quotes for multiline support
    ESCAPE = '\\';                          -- Use backslash as the escape character for special characters


-- create stage object
create or replace stage UK_FOOD_DONATION.public.stage_gcp_foodbanks
    STORAGE_INTEGRATION = gcp_integration
    URL = 'gcs://uk-food-donation-bucket/data_via_direct_download/foodbanks'
    FILE_FORMAT = fileformat_gcp;

    
LIST @UK_FOOD_DONATION.public.stage_gcp_foodbanks;


CREATE OR REPLACE TABLE FOODBANKS_DETAILS (
    name varchar,
    slug varchar,
    url varchar,
    shopping_list_url varchar,
    phone varchar, -- Store phone as varchar to keep leading zeros
    email varchar,
    address varchar,
    postcode varchar,
    parliamentary_constituency varchar,
    mp varchar,
    mp_party varchar,
    ward varchar,
    district varchar,
    country varchar,
    charity_number varchar,  -- Some contain letters
    charity_register_url varchar,
    closed boolean,
    latt_long varchar,
    "network" varchar
);


COPY INTO FOODBANKS_DETAILS 
FROM @UK_FOOD_DONATION.public.stage_gcp_foodbanks;


SELECT * FROM FOODBANKS_DETAILS;

