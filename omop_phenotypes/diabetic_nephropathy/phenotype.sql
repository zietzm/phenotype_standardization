SELECT DISTINCT person_id
FROM (
    -- Albuminuria
    SELECT DISTINCT person_id
    FROM (
        SELECT DISTINCT person_id
        FROM measurement
        WHERE measurement_concept_id IN (3005577, 3000034, 3002827) AND (
            -- > 30 mg/dL
            (unit_concept_id = 8840 AND value_as_number > 30) OR
            -- equivalent to > 300 ug/mL
            (unit_concept_id = 8859 AND value_as_number > 300)
        )
        GROUP BY person_id
        HAVING COUNT(DISTINCT measurement_date) >= 2
    ) AS albuminuria_patients
    INNER JOIN (
        -- Increased plasma creatinine
        SELECT DISTINCT measurement.person_id
        FROM measurement
        INNER JOIN person ON measurement.person_id = person.person_id
        WHERE measurement_concept_id = 3016723 AND unit_source_value = "mg/dl" AND
            value_source_value REGEXP "^[0-9\\.<]+$" AND (
                -- Female
                (gender_concept_id = 8532 AND CAST(REPLACE(value_source_value, '<', '') AS DECIMAL(10, 5)) > 1.2) OR
                -- Male
                (gender_concept_id = 8507 AND CAST(REPLACE(value_source_value, '<', '') AS DECIMAL(10, 5)) > 1.3)
            )
        GROUP BY measurement.person_id
        HAVING COUNT(DISTINCT measurement_date) >= 2

        UNION ALL

        -- Reduced eGFR
        SELECT DISTINCT person_id
        FROM measurement
        WHERE measurement_concept_id IN (3029859, 3049187, 3053283, 40771922) AND
            value_source_value REGEXP "^[0-9\\.<>=]+$" AND value_source_value != '.' AND
            CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) > 0 AND
            CAST(REPLACE(REPLACE(REPLACE(value_source_value, '<', ''), '>', ''), '=', '') AS DECIMAL(10, 5)) < 60
    ) AS plasma_creatinine_egfr_patients ON albuminuria_patients.person_id = plasma_creatinine_egfr_patients.person_id

    UNION ALL

    -- From OMOP table (descendants of 192279)
    SELECT DISTINCT person_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    WHERE ancestor_concept_id = 192279
) as diabetic_nephropathy_patients
