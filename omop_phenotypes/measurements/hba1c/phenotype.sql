SELECT measurement.person_id,
       CAST(REPLACE(REPLACE(REPLACE(value_source_value, "<", ""), ">", ""), "%", "") AS DECIMAL(20, 10)) AS measurement_value
FROM measurement
INNER JOIN (
    -- Only one measurement from the earliest time for that person
    SELECT measurement.person_id, MIN(measurement_id) AS measurement_id
    FROM measurement
    INNER JOIN (
        SELECT person_id, MIN(measurement_date) AS measurement_date
        FROM measurement
        WHERE measurement_concept_id IN (3005673, 3004410) AND value_source_value REGEXP "^[<>%0-9\\. ]+$" AND
              value_source_value REGEXP "[0-9]" AND measurement_date >= "2020-03-01"
        GROUP BY person_id
    ) AS first_measurements
    ON first_measurements.person_id = measurement.person_id AND
       first_measurements.measurement_date = measurement.measurement_date
    WHERE measurement_concept_id IN (3005673, 3004410) AND value_source_value REGEXP "^[<>%0-9\\. ]+$" AND
          value_source_value REGEXP "[0-9]"
    GROUP BY person_id
) AS distinct_first_time_measurements
ON distinct_first_time_measurements.person_id = measurement.person_id AND
   distinct_first_time_measurements.measurement_id = measurement.measurement_id
