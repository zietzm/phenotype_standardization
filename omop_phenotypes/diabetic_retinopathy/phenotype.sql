SELECT DISTINCT person_id
FROM ondition_occurrence
INNER JOIN concept_ancestor ON condition_concept_id = descendant_concept_id
WHERE ancestor_concept_id = 4174977
