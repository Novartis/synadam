# Simulate a synthetic BDS dataset.

Generates synthetic BDS data by creating a spine from parameter/visit
combinations and ADSL subject records, then populating remaining
columns, preserving the original data structure.

## Usage

``` r
simulate_bds(bds_summary, seed = NULL)
```

## Arguments

- bds_summary:

  `summary_bds` - summary object created by
  [`glimpse_bds()`](https://novartis.github.io/synadam/reference/glimpse_bds.md).

- seed:

  `integer` - random seed for reproducibility.

## Value

`data.frame` - synthetic BDS dataset.

## Examples

``` r

syn_adsl <- simulate_adsl(glimpse_adsl(
  adsl,
  id_cols = c("USUBJID", "SUBJID"),
  treatment_cols = c("TRT01A", "TRT01AN")
))
#> Glimpsing treatment/flag columns
#> Glimpsing column(s): STUDYID
#> Glimpsing column(s): USUBJID
#> Glimpsing column(s): SUBJID
#> Glimpsing column(s): SITEID
#> Glimpsing column(s): AGE
#> Glimpsing column(s): AGEU
#> Glimpsing column(s): SEX
#> Glimpsing column(s): RACE
#> Glimpsing column(s): ETHNIC
#> Glimpsing column(s): SAFFL
#> Glimpsing column(s): ITTFL
#> Glimpsing column(s): EFFFL
#> Glimpsing column(s): REGION1
#> Glimpsing column(s): REGION1N
#> Glimpsing column(s): COUNTRY
#> Glimpsing column(s): HEIGHTBL
#> Glimpsing column(s): WEIGHTBL
#> Glimpsing column(s): BMIBL
#> Glimpsing column(s): TRTSDT
#> Simulating column(s): treatment, flag
#> Simulating column(s): STUDYID
#> Simulating column(s): USUBJID
#> Simulating column(s): SUBJID
#> Simulating column(s): SITEID
#> Simulating column(s): AGE
#> Simulating column(s): AGEU
#> Simulating column(s): SEX
#> Simulating column(s): RACE
#> Simulating column(s): ETHNIC
#> Simulating column(s): SAFFL
#> Simulating column(s): ITTFL
#> Simulating column(s): EFFFL
#> Simulating column(s): REGION1
#> Simulating column(s): REGION1N
#> Simulating column(s): COUNTRY
#> Simulating column(s): HEIGHTBL
#> Simulating column(s): WEIGHTBL
#> Simulating column(s): BMIBL
#> Simulating column(s): TRTSDT
bds_summary <- glimpse_bds(
  adlb,
  syn_adsl,
  id_cols = "USUBJID",
  param_cols = c("PARAM", "PARAMCD"),
  visit_cols = c("AVISIT", "AVISITN")
)
#> Glimpsing PARAM/VISIT columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing column(s): AVAL
#> Glimpsing column(s): BASE
#> Glimpsing column(s): CHG
#> Glimpsing column(s): ANL01FL
#> Glimpsing column(s): TRTA
#> Glimpsing column(s): TRTAN
#> Glimpsing column(s): ADT
syn_adlb <- simulate_bds(bds_summary, seed = 42)
#> Simulating PARAM/VISIT and ADSL columns
#> Simulating column(s): param, visits
#> Simulating column(s): adsl, cols
#> Simulating column(s): AVAL
#> Simulating column(s): BASE
#> Simulating column(s): CHG
#> Simulating column(s): ANL01FL
#> Simulating column(s): TRTA
head(syn_adlb)
#> # A tibble: 6 × 13
#>   STUDYID  USUBJID PARAM PARAMCD AVISIT AVISITN  AVAL  BASE    CHG ANL01FL TRTA 
#>   <chr>    <chr>   <chr> <chr>   <chr>    <int> <dbl> <dbl>  <dbl> <chr>   <chr>
#> 1 CDISCPI… USUBJI… Albu… ALB     Basel…       0  87.1    85  2.49  Y       Plac…
#> 2 CDISCPI… USUBJI… Albu… ALB     Week 2       2  88.4    87  2.62  Y       Plac…
#> 3 CDISCPI… USUBJI… Albu… ALB     Week 4       4  50.6    51 -1.28  Y       Plac…
#> 4 CDISCPI… USUBJI… Alka… ALP     Basel…       0  82.2    81  1.98  Y       Plac…
#> 5 CDISCPI… USUBJI… Alka… ALP     Week 2       2  71.2    70  0.850 Y       Xano…
#> 6 CDISCPI… USUBJI… Alka… ALP     Week 4       4  64.1    64  0.115 Y       Xano…
#> # ℹ 2 more variables: TRTAN <dbl>, ADT <chr>
```
