## Proteinuria

Descendants of [SNOMED 29738008 (Proteinuria)](https://athena.ohdsi.org/search-terms/terms/75650) or protein urine tests with results: [>14 mg/dl for random/point-of-care urine test](https://medlineplus.gov/ency/article/003580.htm) or >150 mg/dl for 24 tests where the reference value is <= 150 mg/dl or [results listed as 1+, 2+, or 3+](https://pedclerk.uchicago.edu/page/urinalysis-what-does-it-all-mean) on a dipstick test

Note: the `component_id` is not a one-to-one map with `component_loinc_code`, so we defined using `component_id` and [LOINC 2890-2 (Protein/Creatinine [Mass Ratio] in Urine)](https://athena.ohdsi.org/search-terms/terms/3001582)

| component_id|component_name              |
|------------:|:---------------------------|
|        22285|URINE PROTEIN POC {{NYP}}     |
|        58040|URINE PROTEIN {{NYP}}         |
|        28886|URINE PROTEIN RANDOM {{NYP}}  |
|        28894|URINE PROTEIN 24 HOUR {{NYP}} |

<!---
```SQL
{}
```
-->
