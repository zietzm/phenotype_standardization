SELECT DISTINCT person_id
FROM measurement
WHERE measurement_concept_id IN (3029859, 3049187, 3053283, 40771922) AND
    value_source_value REGEXP "^[0-9\\.<>=]+$" AND value_source_value != '.' AND
    CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) > 0 AND
    CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) < 60
