SELECT measurement.person_id, CAST(REPLACE(REPLACE(value_source_value, ">", ""), "<", "") AS DECIMAL(10, 5)) AS measurement_value
FROM measurement
INNER JOIN (
    -- Only one measurement from the earliest time for that person (ensuring correct component again,
    --  since multiple measurements may come back at the same time)
    SELECT measurement.person_id, MIN(measurement_id) AS measurement_id
    FROM measurement
    INNER JOIN (
        SELECT person_id, MIN(measurement_date) AS measurement_date
        FROM measurement
        WHERE measurement_concept_id = 3023091 AND value_source_value REGEXP "^[<>0-9\\.]+$"
        GROUP BY person_id
    ) AS first_measurements
    ON first_measurements.person_id = measurement.person_id AND
       first_measurements.measurement_date = measurement.measurement_date
    WHERE measurement_concept_id = 3023091 AND value_source_value REGEXP "^[<>0-9\\.]+$"
    GROUP BY measurement.person_id
) AS distinct_first_time_measurements
ON distinct_first_time_measurements.person_id = measurement.person_id AND
   distinct_first_time_measurements.measurement_id = measurement.measurement_id
