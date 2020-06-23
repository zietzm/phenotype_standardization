SELECT DISTINCT person_id
FROM (
    -- From measurement table (BMI > 30 or BMI percentile > 95%)
    SELECT DISTINCT person_id
    FROM measurement
    WHERE (measurement_concept_id = 3038553 AND value_as_number >= 30) OR
          (measurement_concept_id = 40762636 AND value_as_number >= 95)

    UNION ALL

    -- From observation table (diagnosis code descendants of 4215968)
    SELECT DISTINCT person_id
    FROM observation
    INNER JOIN concept_ancestor ON observation_concept_id = descendant_concept_id
    WHERE ancestor_concept_id = 4215968
) AS ob_patients
