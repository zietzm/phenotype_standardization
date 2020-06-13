SELECT DISTINCT pat_mrn_id
FROM (
    -- From COVID table (descendants of OMOP 317009 mapped to ICD-10 CM)
    SELECT DISTINCT pat_mrn_id
    FROM concept_ancestor
    INNER JOIN concept_relationship ON descendant_concept_id = concept_id_1
    INNER JOIN concept ON concept_id_2 = concept_id
    INNER JOIN 1_covid_patients_noname ON concept_code = REPLACE(icd10_code, ",", "")
    WHERE ancestor_concept_id = 317009 AND
        relationship_id IN ("Included in map from", "Mapped from") AND
        vocabulary_id = "ICD10CM" AND date_retrieved = @date

    UNION ALL

    -- From OMOP table (descendants of OMOP 317009)
    SELECT DISTINCT pat_mrn_id
    FROM concept_ancestor
    INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
    INNER JOIN 1_covid_patient2person using (person_id)
    WHERE ancestor_concept_id = 317009
) AS asthma_patients
