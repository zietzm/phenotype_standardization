SELECT DISTINCT person_id
FROM measurement
WHERE measurement_concept_id IN (3005577, 3000034, 3002827) AND (
	-- > 30 mg/dL
	(unit_concept_id = 8840 AND value_as_number > 30) OR
	-- equivalent to > 300 ug/mL
	(unit_concept_id = 8859 AND value_as_number > 300)
)
GROUP BY person_id
HAVING COUNT(DISTINCT measurement_date) >= 2;