SELECT DISTINCT pat_mrn_id
FROM (
    -- From COVID table (descendants of OMOP 46271022 mapped to ICD-10 CM)
    SELECT DISTINCT pat_mrn_id
    FROM concept_ancestor
    INNER JOIN concept_relationship ON descendant_concept_id = concept_id_1
    INNER JOIN concept ON concept_id_2 = concept_id
    INNER JOIN 1_covid_patients_noname ON concept_code = REPLACE(icd10_code, ",", "")
    WHERE ancestor_concept_id = 46271022 AND
        relationship_id IN ("Included in map from", "Mapped from") AND
        vocabulary_id = "ICD10CM" AND date_retrieved = @date

    UNION ALL

    -- From OMOP table (descendants of OMOP 46271022)
    SELECT DISTINCT pat_mrn_id
    FROM concept_ancestor
    INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
    INNER JOIN 1_covid_patient2person using (person_id)
    WHERE ancestor_concept_id = 46271022

    UNION ALL

    -- Albuminuria (>= 2 elevated measurements)
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_measurements_noname
    WHERE date_retrieved = @date AND component_loinc_code IN (14956, 14957, 14958) AND
        ord_value REGEXP "^[<>=0-9\\.]+$" AND (
        (reference_unit IN ("mg/dL", "mg/24hr", "mcg/mg creat") AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 30) OR
        (reference_unit = "mg/L" AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 300)
    )
    GROUP BY pat_mrn_id
    HAVING COUNT(DISTINCT result_date) >= 2

    UNION ALL

    -- Reduced eGFR (< 60)
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_measurements_noname
    WHERE date_retrieved = @date AND
        (component_loinc_code IN (48642, 48643, 88294, 50210) OR component_id = 10237) AND
        ord_num_value < 60
) AS chronic_kidney_disease_patients
