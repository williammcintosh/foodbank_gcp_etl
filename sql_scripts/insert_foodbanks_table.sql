INSERT INTO foodbanks_details (name, slug, url, shopping_list_url, phone, email, address, postcode, 
parliamentary_constituency, mp, mp_party, ward, district, country, charity_number, charity_register_url, 
closed, latt_long, network)
VALUES (:name, :slug, :url, :shopping_list_url, :phone, :email, :address, :postcode, 
:parliamentary_constituency, :mp, :mp_party, :ward, :district, :country, :charity_number, 
:charity_register_url, :closed, :latt_long, :network)
ON CONFLICT DO NOTHING;
