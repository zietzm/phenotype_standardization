SELECT DISTINCT person_id
FROM measurement
WHERE measurement_concept_id IN (3029829, 3029859, 3030104, 3030354, 3049187, 3053283, 36303797,
                                 36306178, 40764999, 40771922, 42869913, 46235172, 46236952) AND
    value_source_value REGEXP "^[0-9\\.<>=]+$" AND value_source_value != '.' AND
    CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(20, 10)) > 0 AND
    CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(20, 10)) < 60
