SELECT DISTINCT pat_mrn_id
FROM (
    -- From OMOP table (SNOMED)
    SELECT DISTINCT pat_mrn_id
    FROM concept_ancestor
    INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE ancestor_concept_id = 201820

    UNION ALL

    -- From COVID table (ICD10)
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_patients_noname
    WHERE date_retrieved = @date AND (
        icd10_code LIKE "E08%" OR icd10_code LIKE "E09%" OR
        icd10_code LIKE "E10%" OR icd10_code LIKE "E11%" OR icd10_code LIKE "E13%"
    )

    UNION ALL

    -- From OMOP table (HbA1c >= 6.5)
    SELECT DISTINCT pat_mrn_id
    FROM measurement
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE measurement_concept_id IN (3004410, 3005673, 40758583) AND
        value_source_value REGEXP "^[<>%0-9\\.]+$" AND
        CAST(REPLACE(REPLACE(REPLACE(value_source_value, "<", ""), ">", ""), "%", "") AS DECIMAL(10, 5)) >= 6.5

    UNION ALL

    -- From COVID table (HbA1c >= 6.5)
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_measurements_noname
    WHERE date_retrieved = @date AND component_loinc_code IN (4548, 17856) AND
        ord_value REGEXP "^[<>%0-9\\.]+$" AND
        CAST(REPLACE(REPLACE(REPLACE(ord_value, "<", ""), ">", ""), "%", "") AS DECIMAL(10, 5)) >= 6.5
) AS dm_patients
