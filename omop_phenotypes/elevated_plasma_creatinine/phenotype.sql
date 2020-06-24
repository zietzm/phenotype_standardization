SELECT DISTINCT measurement.person_id
FROM measurement
INNER JOIN person on measurement.person_id = person.person_id
WHERE measurement_concept_id = 3016723 AND unit_source_value = "mg/dl" AND
    value_source_value REGEXP "^[0-9\\.<]+$" AND value_source_value REGEXP "[0-9]" AND (
        -- Female
        (gender_concept_id = 8532 AND CAST(REPLACE(value_source_value, '<', '') AS DECIMAL(20, 10)) > 1.2) OR
        -- Male
        (gender_concept_id = 8507 AND CAST(REPLACE(value_source_value, '<', '') AS DECIMAL(20, 10)) > 1.3)
    )
GROUP BY measurement.person_id
HAVING COUNT(DISTINCT measurement_date) >= 2
