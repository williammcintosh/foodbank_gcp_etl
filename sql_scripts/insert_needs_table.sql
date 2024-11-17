INSERT INTO needs (
    id, 
    found, 
    foodbank_name, 
    foodbank_slug, 
    needs, 
    excess, 
    self, 
    foodbank_urls_self, 
    foodbank_urls_html
)
VALUES (
    :id, 
    :found, 
    LOWER(:foodbank_name), 
    :foodbank_slug, 
    LOWER(:needs), 
    LOWER(:excess), 
    :self, 
    :foodbank_urls_self, 
    :foodbank_urls_html
)
ON CONFLICT DO NOTHING;
