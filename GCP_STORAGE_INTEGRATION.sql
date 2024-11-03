CREATE OR REPLACE STORAGE INTEGRATION gcp_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = GCS
    ENABLED = TRUE
    STORAGE_ALLOWED_LOCATIONS = (
        'gcs://uk-food-donation-bucket/data_via_direct_download/foodbanks',
        'gcs://uk-food-donation-bucket/data_via_direct_download/needs'
    );

DESC STORAGE integration gcp_integration;
