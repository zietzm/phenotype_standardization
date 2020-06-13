SELECT DISTINCT pat_mrn_id, reduced_egfr AS risk_factor, @date AS date_retrieved
FROM 1_covid_measurements_noname
WHERE date_retrieved = @date AND ord_value REGEXP "^[0-9\\.]+$" AND
    (component_loinc_code IN (48642, 48643, 88294, 50210) OR component_id = 10237) AND
    ord_num_value < 60
