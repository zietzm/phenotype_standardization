SELECT DISTINCT person_id
FROM (
    SELECT DISTINCT person_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    WHERE ancestor_concept_id = 75650

    UNION ALL

    SELECT DISTINCT person_id
    FROM measurement
    WHERE value_source_value REGEXP "^[0-9\\.<>+]+$" AND (
        -- Urine test strip
        measurement_concept_id = 3014051 AND (
        CAST(REPLACE(value_source_value, "+", "") AS DECIMAL(10, 5)) IN (1.0, 2.0, 3.0, 4.0) OR
        REPLACE(REPLACE(value_source_value, ">", ""), "=", "") LIKE "30%" OR
        REPLACE(REPLACE(value_source_value, ">", ""), "=", "") LIKE "100%" OR
        REPLACE(REPLACE(value_source_value, ">", ""), "=", "") LIKE "500%")
    ) OR (
        -- Protein/creatinine mass ratio in urine
        measurement_concept_id = 3001582 AND (
        (unit_source_value = "mg/mg creat" AND
         CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5)) > 0.2) OR
        (unit_source_value = "mg/g creat" AND value_as_number > 200))
    ) OR (
        -- 24 hour urine protein
        measurement_concept_id = 3020876 AND
        CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5)) > 150
    ) OR (
        -- Random urine test
        measurement_concept_id = 3037121 AND (
        value_source_value IN ("1+", "2+", "3+", "4+") OR
        CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5)) > 14)
    )
) AS proteinuria_patients
