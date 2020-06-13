SELECT pat_mrn_id, CAST(REPLACE(REPLACE(ord_value, ">", ""), "<", "") AS DECIMAL(10, 5)) AS ord_value
FROM 1_covid_measurements_noname
INNER JOIN (
    -- Only one measurement from the earliest time for that person (ensuring correct component again,
    --  since multiple measurements may come back at the same time)
    SELECT pat_mrn_id, MIN(order_proc_id) AS order_proc_id
    FROM 1_covid_measurements_noname
    INNER JOIN (
        SELECT pat_mrn_id, MIN(result_time) AS result_time
        FROM 1_covid_measurements_noname
        WHERE date_retrieved = @date AND component_loinc_code = 26881 AND
            ref_normal_vals IN ("<=5", "<=5.0") AND result_date > "2020-03-01" AND
            ord_value REGEXP "^[<>0-9\\.]+$"
        GROUP BY pat_mrn_id
    ) AS first_measurements USING (pat_mrn_id, result_time)
    WHERE date_retrieved = @date AND component_loinc_code = 26881 AND
        ref_normal_vals IN ("<=5", "<=5.0") AND ord_value REGEXP "^[<>0-9\\.]+$"
    GROUP BY pat_mrn_id
) AS distinct_first_time_measurements USING (pat_mrn_id, order_proc_id)
WHERE date_retrieved = @date AND component_loinc_code = 26881 AND
    ord_value REGEXP "^[<>0-9\\.]+$"
