SELECT DISTINCT person_id
FROM (
    -- From OMOP table (descendants of OMOP 46271022)
    SELECT DISTINCT person_id
    FROM concept_ancestor
    INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
    WHERE ancestor_concept_id = 46271022

    UNION ALL

    -- Albuminuria (>= 2 elevated measurements)
    SELECT DISTINCT person_id
    FROM measurement
    WHERE measurement_concept_id IN (3005577, 3000034, 3002827) AND (
        -- > 30 mg/dL
        (unit_concept_id = 8840 AND value_as_number > 30) OR
        -- equivalent to > 300 ug/mL
        (unit_concept_id = 8859 AND value_as_number > 300)
    )
    GROUP BY person_id
    HAVING COUNT(DISTINCT measurement_date) >= 2;

    UNION ALL

    -- Reduced eGFR (< 60)
    SELECT DISTINCT person_id
    FROM measurement
    WHERE measurement_concept_id IN (3029859, 3049187, 3053283, 40771922) AND
        value_source_value REGEXP "^[0-9\\.<>=]+$" AND value_source_value != '.' AND
        CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) > 0 AND
        CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) < 60
) AS chronic_kidney_disease_patients
