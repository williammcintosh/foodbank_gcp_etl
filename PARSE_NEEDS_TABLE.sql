
CREATE OR REPLACE TABLE Foodbank (
    id varchar PRIMARY KEY,
    name VARCHAR NOT NULL,
    CONSTRAINT unique_foodbank_id_name UNIQUE (id, name)
);


CREATE OR REPLACE TABLE FoodNeed (
    id INT AUTOINCREMENT PRIMARY KEY,
    foodbank_id varchar REFERENCES Foodbank(id),
    item VARCHAR NOT NULL,
    recorded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT unique_foodbank_item_time UNIQUE (foodbank_id, item, recorded_at)
);


CREATE OR REPLACE TABLE FoodExcess (
    id INT AUTOINCREMENT PRIMARY KEY,
    foodbank_id varchar REFERENCES Foodbank(id),
    item VARCHAR NOT NULL,
    recorded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CONSTRAINT unique_foodbank_excess_time UNIQUE (foodbank_id, item, recorded_at)
);


-- Insert into Foodbank with lowercased id and name
INSERT INTO Foodbank (id, name)
SELECT DISTINCT LOWER(id), LOWER(FOODBANK_NAME) FROM Needs;


-- Insert into FoodNeed with lowercased foodbank_id and item
INSERT INTO FoodNeed (id, foodbank_id, item, recorded_at)
SELECT 
    SEQ4() AS id,  -- Generate a unique ID for each row
    LOWER(n.id) AS foodbank_id,
    LOWER(TRIM(f.value)) AS item,
    n.found AS recorded_at
FROM 
    Needs AS n,
    LATERAL FLATTEN(input => SPLIT(REGEXP_REPLACE(n.needs, '\r\n|\r|\n', ','), ',')) AS f
WHERE n.needs IS NOT NULL;


-- Insert into FoodExcess with lowercased foodbank_id and item
INSERT INTO FoodExcess (id, foodbank_id, item, recorded_at)
SELECT 
    SEQ4() AS id,  -- Generate a unique ID for each row
    LOWER(n.id) AS foodbank_id,
    LOWER(TRIM(f.value)) AS item,
    n.found AS recorded_at
FROM 
    Needs AS n,
    LATERAL FLATTEN(input => SPLIT(REGEXP_REPLACE(n.excess, '\r\n|\r|\n', ','), ',')) AS f
WHERE n.excess IS NOT NULL;


SELECT TOP 30 * FROM FOODNEED;
