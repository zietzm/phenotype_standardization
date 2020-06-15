SELECT DISTINCT pat_mrn_id
FROM 1_covid_measurements_noname
WHERE date_retrieved = @date AND component_loinc_code IN (14956, 14957, 14958) AND
    ord_value REGEXP "^[<>=0-9\\.]+$" AND (
    (reference_unit IN ("mg/dL", "mg/24hr", "mcg/mg creat") AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 30) OR
    (reference_unit = "mg/L" AND CAST(REPLACE(REPLACE(REPLACE(ord_value, ">", ""), "<", ""), "=", "") AS DECIMAL(10, 5)) > 300)
)
GROUP BY pat_mrn_id
HAVING COUNT(DISTINCT result_date) >= 2
