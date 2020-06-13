SELECT DISTINCT pat_mrn_id
FROM 1_covid_measurements_noname
INNER JOIN 1_covid_persons_noname USING (pat_mrn_id)
WHERE date_retrieved = @date AND component_loinc_code = 2160 AND
    ord_value REGEXP "^[0-9\\.]+$" AND (
    (sex_desc = "Male" AND CAST(ord_value AS DECIMAL(10, 5)) > 1.3) OR
    (sex_desc = "Female" AND CAST(ord_value AS DECIMAL(10, 5)) > 1.2)
)
GROUP BY pat_mrn_id
HAVING COUNT(DISTINCT result_date) >= 2
