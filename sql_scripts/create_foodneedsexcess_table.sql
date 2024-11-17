-- Drop existing tables if they exist
DROP TABLE IF EXISTS FoodExcess, FoodNeed, Foodbank CASCADE;

-- Creating the Foodbank table
CREATE TABLE Foodbank (
    id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL,
    CONSTRAINT unique_record_id_name UNIQUE (id, name)
);

-- Creating the FoodNeed table
CREATE TABLE FoodNeed (
    id SERIAL PRIMARY KEY,
    record_id VARCHAR REFERENCES Foodbank(id),
    item VARCHAR NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_foodbank_item_time UNIQUE (record_id, item, recorded_at)
);

-- Creating the FoodExcess table
CREATE TABLE FoodExcess (
    id SERIAL PRIMARY KEY,
    record_id VARCHAR REFERENCES Foodbank(id),
    item VARCHAR NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_foodbank_excess_time UNIQUE (record_id, item, recorded_at)
);
