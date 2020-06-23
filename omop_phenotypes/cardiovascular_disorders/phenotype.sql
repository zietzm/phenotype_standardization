SELECT DISTINCT person_id
FROM concept_ancestor
INNER JOIN condition_occurrence ON descendant_concept_id = condition_concept_id
WHERE ancestor_concept_id = 134057
