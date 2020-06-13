SELECT DISTINCT pat_mrn_id
FROM (
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_patients_noname
    WHERE date_retrieved = @date AND
        REPLACE(icd10_code, ",", "") REGEXP "^E(08|09|10|11|13).(51|52|59)$"

    UNION ALL

    SELECT DISTINCT pat_mrn_id
    FROM condition_occurrence
    INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
    INNER JOIN 1_covid_patient2person using (person_id)
    WHERE ancestor_concept_id = 321822
) AS diabetic_vasculopathy_patients
