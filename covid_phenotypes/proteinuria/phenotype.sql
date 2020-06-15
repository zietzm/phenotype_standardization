SELECT DISTINCT pat_mrn_id
FROM (
    SELECT DISTINCT pat_mrn_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE ancestor_concept_id = 75650

    UNION ALL

    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_measurements_noname
    WHERE date_retrieved = @date AND (
        -- Dipstick urine protein test
        (component_id = 22285 AND ord_value IN ("1+", "2+", "3+")) OR
        -- Point-of-care protein urine test strip
        (component_id = 58040 AND ord_value IN ("30", "100", "300", ">300", ">=300", ">=500", ">=1000")) OR
        -- Random urine protein test (> 14 mg/dl)
        (component_id = 28886 AND ord_value REGEXP "^[<>0-9\\.]+$" AND CAST(REPLACE(REPLACE(ord_value, "<", ""), ">", "") AS DECIMAL(10, 5)) > 14) OR
        -- 24 hour urine protein (> 150 mg/24hr is the listed reference)
        (component_id = 28894 AND ord_value REGEXP "^[0-9\\.]+$" AND CAST(ord_value AS DECIMAL(10, 5)) > 150) OR
        -- Protein/creatinine ratio (reference is <=0.2 mg/mg or <=200 mg/g)
        (component_loinc_code = 2890 AND component_name != "PROTEIN TOTAL, URINE {{EXT}}" AND
         ord_value NOT IN ("NCAL", "NOTE", "Cannot Calculate") AND (
             (reference_unit = "mg/g creat" AND ord_num_value > 200) OR
             (reference_unit = "mg/mg creat" AND ord_value REGEXP "^[0-9\\.]+$" AND CAST(ord_value AS DECIMAL(10, 5)) > 0.2)
         )
        )
    )
) AS proteinuria_patients
