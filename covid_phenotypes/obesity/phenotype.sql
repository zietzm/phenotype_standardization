SELECT DISTINCT pat_mrn_id
FROM (
    -- From COVID table (BMI > 30)
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_vitals_noname
    WHERE date_retrieved=@date AND bmi >= 30

    UNION ALL

    -- From OMOP table (BMI > 30)
    SELECT DISTINCT pat_mrn_id
    FROM measurement
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE measurement_concept_id = 3038553 AND measurement_date >= "2019-01-01" AND
        value_as_number >= 30

    UNION ALL

    -- From OMOP table (diagnosis code descendant of 4215968)
    SELECT DISTINCT pat_mrn_id
    FROM observation
    INNER JOIN concept_ancestor ON observation_concept_id = descendant_concept_id
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE ancestor_concept_id = 4215968

    UNION ALL

    -- From OMOP table (BMI percentile > 95%)
    SELECT DISTINCT pat_mrn_id
    FROM measurement
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE measurement_concept_id = 40762636 AND measurement_date >= "2019-01-01" AND
        value_as_number >= 95
) AS ob_patients
