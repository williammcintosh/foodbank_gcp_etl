- Drop existing views if they exist to avoid conflicts
DROP VIEW IF EXISTS View_FoodNeeds;
DROP VIEW IF EXISTS View_FoodExcess;
DROP VIEW IF EXISTS View_CloseFoodbanks;

-- Create views for Food Needs and Food Excess with Foodbank information
CREATE VIEW View_FoodNeeds AS
SELECT 
    fn.record_id,
    fn.item,
    fn.recorded_at as need_recorded_at,
    n.foodbank_name as foodbank_name
FROM 
    FoodNeed fn
JOIN 
    needs n ON fn.record_id = n.id;

CREATE VIEW View_FoodExcess AS
SELECT 
    fe.record_id,
    fe.item,
    fe.recorded_at as excess_recorded_at,
    n.foodbank_name as foodbank_name
FROM 
    FoodExcess fe
JOIN 
    needs n ON fe.record_id = n.id;

-- Create a view for close Foodbanks within 15 km distance
CREATE VIEW View_CloseFoodbanks AS
SELECT 
    fd.foodbank_name_1,
    fd.foodbank_name_2,
    fd.distance_km
FROM 
    foodbanks_distances fd
WHERE
    fd.distance_km <= 15;

-- Drop the table if it already exists to refresh the data
DROP TABLE IF EXISTS Foodbank_Item_Matches;

-- Create table and populate it with the query results
CREATE TABLE Foodbank_Item_Matches AS

SELECT 
    fn.record_id AS receiving_record_id,
    fn.foodbank_name AS receiving_foodbank_name,
    fl1.district AS receiving_district,
    fl1.location AS receiving_location,
    fe.record_id AS supplying_record_id,
    fe.foodbank_name AS supplying_foodbank_name,
    fl2.district AS supplying_district,
    fl2.location AS supplying_location,
    fn.item,
    fd.distance_km
FROM 
    View_FoodNeeds fn
JOIN 
    View_FoodExcess fe ON fn.item = fe.item AND fn.record_id != fe.record_id
JOIN 
    View_CloseFoodbanks fd ON fn.foodbank_name = fd.foodbank_name_1 AND fe.foodbank_name = fd.foodbank_name_2
JOIN 
    foodbanks_locations fl1 ON fn.foodbank_name = fl1.name
JOIN 
    foodbanks_locations fl2 ON fe.foodbank_name = fl2.name

UNION

SELECT 
    fn.record_id AS receiving_record_id,
    fn.foodbank_name AS receiving_foodbank_name,
    fl1.district AS receiving_district,
    fl1.location AS receiving_location,
    fe.record_id AS supplying_record_id,
    fe.foodbank_name AS supplying_foodbank_name,
    fl2.district AS supplying_district,
    fl2.location AS supplying_location,
    fn.item,
    fd.distance_km
FROM 
    View_FoodNeeds fn
JOIN 
    View_FoodExcess fe ON fn.item = fe.item AND fn.record_id != fe.record_id
JOIN 
    View_CloseFoodbanks fd ON fn.foodbank_name = fd.foodbank_name_2 AND fe.foodbank_name = fd.foodbank_name_1
JOIN 
    foodbanks_locations fl1 ON fn.foodbank_name = fl1.name
JOIN 
    foodbanks_locations fl2 ON fe.foodbank_name = fl2.name;

-- Now the results are stored in Foodbank_Item_Matches
