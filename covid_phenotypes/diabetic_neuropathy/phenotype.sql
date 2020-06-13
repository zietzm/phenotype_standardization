SELECT DISTINCT pat_mrn_id
FROM (
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_patients_noname
    WHERE date_retrieved = @date AND icd10_desc LIKE "%neuropathy%" AND
        (icd10_code LIKE "E08%" OR icd10_code LIKE "E09%" OR icd10_code LIKE "E10%" OR
         icd10_code LIKE "E11%" OR icd10_code LIKE "E13%")

    UNION ALL

    SELECT DISTINCT pat_mrn_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    INNER JOIN 1_covid_patient2person using (person_id)
    WHERE ancestor_concept_id = 443730
) AS diabetic_neuropathy_patients
