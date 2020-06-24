SELECT measurement.person_id,
    CASE
        WHEN unit_concept_id = 8751 THEN CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5))
        WHEN unit_concept_id = 8840 THEN 10 * CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5))
    END AS measurement_value
FROM measurement
INNER JOIN (
    -- Only one measurement from the earliest time for that person
    SELECT measurement.person_id, MIN(measurement_id) AS measurement_id
    FROM measurement
    INNER JOIN (
        -- Only measurements at the earliest time recorded (still possibly multiple)
        SELECT person_id, MIN(measurement_date) AS measurement_date
        FROM measurement
        WHERE measurement_concept_id IN (3020460, 3010156) AND unit_concept_id IN (8751, 8840) AND
              value_source_value REGEXP "^[<>0-9\\.]+$" AND value_source_value REGEXP "[0-9]" AND
              measurement_date >= "2020-03-01"
        GROUP BY person_id
    ) AS first_measurements
    ON first_measurements.person_id = measurement.person_id AND
       first_measurements.measurement_date = measurement.measurement_date
    WHERE measurement_concept_id IN (3020460, 3010156) AND unit_concept_id IN (8751, 8840) AND
          value_source_value REGEXP "^[<>0-9\\.]+$" AND value_source_value REGEXP "[0-9]"
    GROUP BY person_id
) AS distinct_first_time_measurements
ON measurement.person_id = distinct_first_time_measurements.person_id AND
   measurement.measurement_id = distinct_first_time_measurements.measurement_id
