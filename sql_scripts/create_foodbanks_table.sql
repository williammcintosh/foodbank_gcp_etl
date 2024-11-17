DROP TABLE IF EXISTS foodbanks_details;
CREATE TABLE foodbanks_details (
    name TEXT,
    slug TEXT,
    url TEXT,
    shopping_list_url TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    postcode TEXT,
    parliamentary_constituency TEXT,
    mp TEXT,
    mp_party TEXT,
    ward TEXT,
    district TEXT,
    country TEXT,
    charity_number TEXT,
    charity_register_url TEXT,
    closed BOOLEAN,
    latt_long TEXT,
    network TEXT
);
