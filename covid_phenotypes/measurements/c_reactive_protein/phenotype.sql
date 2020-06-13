SELECT pat_mrn_id,
    CASE
        WHEN reference_unit = "mg/L" THEN CAST(REPLACE(REPLACE(ord_value, ">", ""), "<", "") AS DECIMAL(10, 5))
        WHEN reference_unit = "mg/dL" THEN 10 * CAST(REPLACE(REPLACE(ord_value, ">", ""), "<", "") AS DECIMAL(10, 5))
    END AS ord_value
FROM 1_covid_measurements_noname
INNER JOIN (
    -- Only one measurement from the earliest time for that person (ensuring correct component again,
    --  since multiple measurements may come back at the same time)
    SELECT pat_mrn_id, MIN(order_proc_id) AS order_proc_id
    FROM 1_covid_measurements_noname
    INNER JOIN (
        -- Only measurements at the earliest time recorded (still possibly multiple)
        SELECT pat_mrn_id, MIN(result_time) AS result_time
        FROM 1_covid_measurements_noname
        WHERE date_retrieved = @date AND component_loinc_code IN (1988, 30522) AND
            result_date > "2020-03-01" AND ord_value REGEXP "^[<>0-9\\.]+$" AND
            reference_unit IN ("mg/L", "mg/dL")
        GROUP BY pat_mrn_id
    ) AS first_measurements USING (pat_mrn_id, result_time)
    WHERE date_retrieved = @date AND component_loinc_code IN (1988, 30522) AND
        ord_value REGEXP "^[<>0-9\\.]+$" AND reference_unit IN ("mg/L", "mg/dL")
    GROUP BY pat_mrn_id
) AS distinct_first_time_measurements USING (pat_mrn_id, order_proc_id)
WHERE date_retrieved = @date AND component_loinc_code IN (1988, 30522) AND
    ord_value REGEXP "^[<>0-9\\.]+$" AND reference_unit IN ("mg/L", "mg/dL")
