SELECT 
    fn.foodbank_id AS receiving_foodbank_id,
    fb_receiver.name AS receiving_foodbank_name,
    fe.foodbank_id AS supplying_foodbank_id,
    fb_supplier.name AS supplying_foodbank_name,
    fn.item,
    MAX(fn.recorded_at) AS need_recorded_at,     -- Most recent need
    MIN(fe.recorded_at) AS excess_recorded_at,    -- Oldest excess
    fb_details.url,
    fb_details.latt_long,
    fb_details.district,
    fb_details.postcode,
    fb_details.phone
FROM 
    FoodNeed AS fn
JOIN 
    FoodExcess AS fe ON fn.item = fe.item
AND 
    fn.foodbank_id != fe.foodbank_id
JOIN 
    Foodbank AS fb_receiver ON fn.foodbank_id = fb_receiver.id
JOIN 
    Foodbank AS fb_supplier ON fe.foodbank_id = fb_supplier.id
LEFT JOIN 
    foodbanks_details AS fb_details ON LOWER(fb_receiver.name) = LOWER(fb_details.name)
GROUP BY 
    fn.foodbank_id,
    fb_receiver.name,
    fe.foodbank_id,
    fb_supplier.name,
    fn.item,
    fb_details.url,
    fb_details.latt_long,
    fb_details.district,
    fb_details.postcode,
    fb_details.phone
ORDER BY 
    fn.foodbank_id, fe.foodbank_id, fn.item;
