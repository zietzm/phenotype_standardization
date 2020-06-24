SELECT DISTINCT person_id
FROM (
    -- From condition table (SNOMED)
    SELECT DISTINCT person_id
    FROM concept_ancestor
    INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
    WHERE ancestor_concept_id = 201820

    UNION ALL

    -- From measurement table (HbA1c >= 6.5)
    SELECT DISTINCT person_id
    FROM measurement
    WHERE measurement_concept_id IN (3004410, 3005673, 40758583) AND
          value_source_value REGEXP "^[<>%0-9\\.]+$" AND value_source_value REGEXP "[0-9]" AND
          CAST(REPLACE(REPLACE(REPLACE(value_source_value, "<", ""), ">", ""), "%", "") AS DECIMAL(10, 5)) >= 6.5
) AS dm_patients
