SELECT DISTINCT pat_mrn_id
FROM (
    -- Albuminuria
    SELECT DISTINCT pat_mrn_id
    FROM (
        SELECT DISTINCT pat_mrn_id
        FROM 1_covid_measurements_noname
        WHERE date_retrieved = @date AND component_loinc_code IN (14957, 14956, 14958) AND
        ord_value REGEXP "^[<>=0-9\\.]+$" AND (
            (reference_unit IN ("mg/dL", "mg/24hr", "mcg/mg creat") AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 30) OR
            (reference_unit = "mg/L" AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 300)
        )
        GROUP BY pat_mrn_id
        HAVING COUNT(DISTINCT result_date) >= 2
    ) AS albuminuria_patients
    INNER JOIN (
        -- Increased plasma creatinine
        SELECT DISTINCT pat_mrn_id
        FROM 1_covid_measurements_noname
        INNER JOIN 1_covid_persons_noname USING (pat_mrn_id)
        WHERE date_retrieved = @date AND component_loinc_code = 2160 AND
            ord_value REGEXP "^[0-9\\.]+$" AND (
            (sex_desc = "Male" AND CAST(ord_value AS DECIMAL(10, 5)) > 1.3) OR
            (sex_desc = "Female" AND CAST(ord_value AS DECIMAL(10, 5)) > 1.2)
        )
        GROUP BY pat_mrn_id
        HAVING COUNT(DISTINCT result_date) >= 2

        UNION ALL

        -- Reduced eGFR
        SELECT DISTINCT pat_mrn_id
        FROM 1_covid_measurements_noname
        WHERE date_retrieved = @date AND ord_value REGEXP "^[0-9\\.]+$" AND
            (component_loinc_code IN (48642, 48643, 88294, 50210) OR component_id = 10237) AND
            ord_num_value < 60
    ) AS plasma_creatinine_egfr_patients USING (pat_mrn_id)

    UNION ALL

    -- Diagnosis codes of nephropathy
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_patients_noname
    WHERE date_retrieved = @date AND
        REPLACE(icd10_code, ",", "") IN ("E08.21", "E09.21", "E10.21", "E11.21", "E13.21")

    UNION ALL

    -- From OMOP table (descendants of 192279)
    SELECT DISTINCT pat_mrn_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    INNER JOIN 1_covid_patient2person using (person_id)
    WHERE ancestor_concept_id = 192279
) as diabetic_nephropathy_patients
