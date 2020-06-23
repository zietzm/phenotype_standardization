## HbA1c

This finds each person's first HbA1c since February 01, 2020 (first date available in the tables from Epic) using either of the following measurements:

1. [LOINC 4548-4 (Hemoglobin A1c/Hemoglobin.total in Blood)](https://athena.ohdsi.org/search-terms/terms/3004410)
2. [LOINC 17856-6 (Hemoglobin A1c/Hemoglobin.total in Blood by HPLC)](https://athena.ohdsi.org/search-terms/terms/3005673)

This differs from the use of HbA1c in the definition for diabetes mellitus in that it looks exclusively at the first measurement in Epic (COVID) tables, rather than a single diabetic-range measurement in either OMOP or Epic (COVID) tables.

<!---
```SQL
{}
```
-->
