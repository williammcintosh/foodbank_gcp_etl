SELECT 
    fn.foodbank_id AS receiving_foodbank_id,
    fb_receiver.name AS receiving_foodbank_name,
    fe.foodbank_id AS supplying_foodbank_id,
    fb_supplier.name AS supplying_foodbank_name,
    fn.item,
    MAX(fn.recorded_at) AS need_recorded_at,     -- Most recent need
    MIN(fe.recorded_at) AS excess_recorded_at,    -- Oldest excess
    fb_receiver_details.url,
    fb_receiver_details.latt_long,
    fb_receiver_details.district AS receiving_district,
    fb_receiver_details.postcode,
    fb_receiver_details.phone,
    fd.distance_km   -- Distance between the foodbanks
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
    foodbanks_details AS fb_receiver_details 
    ON LOWER(fb_receiver.name) = LOWER(fb_receiver_details.name)
LEFT JOIN 
    foodbanks_details AS fb_supplier_details 
    ON LOWER(fb_supplier.name) = LOWER(fb_supplier_details.name)
JOIN 
    foodbank_distances AS fd ON 
        (LOWER(fb_receiver.name) = LOWER(fd.foodbank_name_1) 
         AND fb_receiver_details.district = fd.foodbank_district_1
         AND LOWER(fb_supplier.name) = LOWER(fd.foodbank_name_2)
         AND fb_supplier_details.district = fd.foodbank_district_2)
        OR
        (LOWER(fb_receiver.name) = LOWER(fd.foodbank_name_2) 
         AND fb_receiver_details.district = fd.foodbank_district_2
         AND LOWER(fb_supplier.name) = LOWER(fd.foodbank_name_1)
         AND fb_supplier_details.district = fd.foodbank_district_1)  -- Matches distances in either direction
GROUP BY 
    fn.foodbank_id,
    fb_receiver.name,
    fe.foodbank_id,
    fb_supplier.name,
    fn.item,
    fb_receiver_details.url,
    fb_receiver_details.latt_long,
    fb_receiver_details.district,
    fb_receiver_details.postcode,
    fb_receiver_details.phone,
    fd.distance_km
ORDER BY 
    fn.foodbank_id, fn.item, fd.distance_km;  -- Prioritizes closest supplier first
