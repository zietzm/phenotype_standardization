<!-- This document is processed by GitHub actions to make the wiki. Edits to
the wiki should be made in this document. Because we use Python to process
this into the complete wiki, curly braces must be doubled.
 -->

### Table of Contents

[Usage](#usage-)<br/>

[SARS-CoV-2 infection test result](#sars-cov-2-infection-test-result-)<br/>
[COVID-19 diagnosis](#covid-19-diagnosis-)<br/>

{risk_factor_contents}

{measurement_contents}

[Drug exposures](#drug-exposures-)<br/>

## Usage

Queries contain a user-defined SQL variable for date, `@date`. I use the following function to make queries (eg. in R):

```R
date = '2020-06-02'

DBI::dbSendQuery(con, stringr::str_glue('SET @date = CAST("{{date}}" AS DATE)'))
```

```R
sql_to_tibble <- function(sql_code, .con = con) {{
    sql_code %>%
        sql %>%
        tbl(src = .con) %>%
        as_tibble
}}
```

For example:

```R
obese_by_bmi <- '
    SELECT DISTINCT pat_mrn_id
    FROM 1_covid_vitals_noname
    WHERE bmi > 30 AND date_retrieved = @date
    ' %>%
    sql_to_tibble
```

While this makes things easier in general, just remember that when you want to use the `{{` or `}}` characters (which are common in descriptions in the Epic tables), just double the character (eg. `{{NYP}}`).

---

## SARS-CoV-2 infection test result

RT-PCR tests for SARS-CoV-2 RNA

People receive multiple tests. The strategy here is to find the maximum test value for each person, then find the earliest date they received such a result.

```SQL
SELECT pat_mrn_id, MIN(result_date) AS cov_result_date, MAX(cov_pos) AS cov_pos
FROM (
    SELECT pat_mrn_id, result_date, CAST(ord_value LIKE "Detected%" AS DECIMAL(2, 0)) AS cov_pos
    FROM 1_covid_labs_noname
    WHERE date_retrieved = @date AND
        ord_value NOT IN ("Invalid", "Indeterminate", "Nasopharyngeal", "Not Given",
                          "Void", "See Comment", "Yes")
) AS all_test_patients
INNER JOIN (
    SELECT pat_mrn_id, MAX(CAST(ord_value LIKE "Detected%" AS DECIMAL(2, 0))) AS cov_pos
    FROM 1_covid_labs_noname
    WHERE date_retrieved = @date
    GROUP BY pat_mrn_id
) AS any_test_positive USING (pat_mrn_id, cov_pos)
GROUP BY pat_mrn_id
```

## COVID-19 diagnosis

Diagnosis codes for COVID-19

```SQL
SELECT pat_mrn_id, DATE(MIN(contact_date_string)) AS covid_diagnosis_date,
    CAST(1 AS DECIMAL(2, 0)) AS covid_diagnosed
FROM 1_covid_patients_noname
WHERE date_retrieved=@date AND covid_diagnosis = "Y"
GROUP BY pat_mrn_id
```

---

{risk_factors}

---

{measurements}

---

## Drug exposures

Reasonably fast query for drugs using descendants from ATC.

Showing an example for exposures to [ACEi](https://athena.ohdsi.org/search-terms/terms/21601784) or [ARB](https://athena.ohdsi.org/search-terms/terms/21601823). I use the following definitions:

| Name | ATC code | OMOP concept_id | Link |
| --- | --- | --- | ----- |
| ACE inhibitors, plain | C09AA | 21601784 | https://athena.ohdsi.org/search-terms/terms/21601784 |
| Angiotensin II receptor blockers (ARBs), plain | C09CA | 21601823 | https://athena.ohdsi.org/search-terms/terms/21601823 |
| CALCIUM CHANNEL BLOCKERS | C08 | 21601744 | https://athena.ohdsi.org/search-terms/terms/21601744 |
| BETA BLOCKING AGENTS | C07 | 21601664 | https://athena.ohdsi.org/search-terms/terms/21601664 |
| digoxin; systemic | C01AA05 | 21600234 | https://athena.ohdsi.org/search-terms/terms/21600234 |
| cetirizine; oral | R06AE07 | 21603497 | https://athena.ohdsi.org/search-terms/terms/21603497 |
| diphenhydramine; oral, rectal | R06AA02 | 21603448 | https://athena.ohdsi.org/search-terms/terms/21603448 |
| INSULINS AND ANALOGUES | A10A | 21600713 | https://athena.ohdsi.org/search-terms/terms/21600713 |

```SQL
SELECT DISTINCT pat_mrn_id, ancestor_concept_id AS drug_class_concept_id,
    descendant_concept_id AS drug_concept_id
FROM (
    # From OMOP table
    SELECT DISTINCT pat_mrn_id, ancestor_concept_id, descendant_concept_id
    FROM concept_ancestor
    INNER JOIN drug_era ON descendant_concept_id = drug_concept_id
    INNER JOIN 1_covid_patient2person USING (person_id)
    WHERE ancestor_concept_id in (21601784, 21601823) AND (
        YEAR(drug_era_start_datetime) >= 2019 OR YEAR(drug_era_end_datetime) >= 2019
    )

    UNION ALL

    # From COVID table
    SELECT DISTINCT pat_mrn_id, ancestor_concept_id, descendant_concept_id
    FROM concept_ancestor
    INNER JOIN concept ON descendant_concept_id = concept_id
    INNER JOIN 1_covid_med_id2rxnorm ON concept_code = rxnorm
    INNER JOIN 1_covid_meds_noname USING (med_id)
    WHERE date_retrieved = @date AND ancestor_concept_id IN (21601784, 21601823) AND
        vocabulary_id = "RxNorm"
) AS drug_exposures
```
