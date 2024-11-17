DROP TABLE IF EXISTS needs;
CREATE TABLE needs (
    id varchar,
    found varchar,
    foodbank_name varchar,
    foodbank_slug varchar,
    needs varchar,
    excess varchar,
    self varchar,
    foodbank_urls_self varchar,
    foodbank_urls_html varchar,
    PRIMARY KEY (id, found)
);
