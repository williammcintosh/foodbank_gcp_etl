-- Insert into Foodbank with lowercased id and name
INSERT INTO Foodbank (id, name)
SELECT DISTINCT LOWER(id), LOWER(foodbank_name) FROM Needs
ON CONFLICT (id) DO NOTHING;

-- Insert into FoodNeed with each item separated into its own row
INSERT INTO FoodNeed (record_id, item, recorded_at)
SELECT 
    LOWER(n.id) AS record_id,
    LOWER(TRIM(item)) AS item,
    n.found AS recorded_at
FROM 
    Needs AS n
    JOIN LATERAL UNNEST(STRING_TO_ARRAY(n.needs, E'\n')) AS s(item)
ON TRUE
WHERE n.needs IS NOT NULL AND EXISTS (SELECT 1 FROM Foodbank WHERE id = LOWER(n.id))
ON CONFLICT (record_id, item, recorded_at) DO NOTHING;

-- Assuming a similar logic for FoodExcess if it also contains newline separated values
INSERT INTO FoodExcess (record_id, item, recorded_at)
SELECT 
    LOWER(n.id) AS record_id,
    LOWER(TRIM(item)) AS item,
    n.found AS recorded_at
FROM 
    Needs AS n
    JOIN LATERAL UNNEST(STRING_TO_ARRAY(n.excess, E'\n')) AS s(item)
ON TRUE
WHERE n.excess IS NOT NULL AND EXISTS (SELECT 1 FROM Foodbank WHERE id = LOWER(n.id))
ON CONFLICT (record_id, item, recorded_at) DO NOTHING;
