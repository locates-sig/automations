-- Listar todos os schemas que começam com 'geo_', 'esteira' e 'observatorio'
SELECT 
    schema_name
FROM information_schema.schemata
WHERE schema_name LIKE 'geo_%'
   OR schema_name = 'esteira'
   OR schema_name = 'observatorio'
ORDER BY schema_name;
