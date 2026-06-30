# Glimpse a BDS dataset.

Summarizes a BDS (Basic Data Structure) e.g. ADLB, ADVS dataset for
synthetic simulation by extracting per-subject parameter/visit profiles,
preserving relationships with ADSL columns, and extracting summaries of
all other variables. All PARAMCDs in the dataset are included.

## Usage

``` r
glimpse_bds(
  bds,
  syn_adsl,
  id_cols,
  param_cols,
  visit_cols = character(),
  flag_cols = character(),
  ordered_col_sets = list(),
  seed = NULL
)
```

## Arguments

- bds:

  `data.frame` - input BDS dataset e.g. ADLB.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- id_cols:

  `character` - ID column names that identify subjects e.g.
  c("USUBJID"). These columns must exist in `syn_adsl` and will be taken
  from there (never simulated).

- param_cols:

  `character` - parameter columns e.g. c("PARAM", "PARAMCD").

- visit_cols:

  `character` - visit columns e.g. c("AVISIT", "AVISITN"). Default is an
  empty character vector (no visit columns).

- flag_cols:

  `character` - flag columns that will be sampled as Y/N in proportion
  to input e.g. c("ANL01FL"). Default is an empty character vector (no
  flag columns).

- ordered_col_sets:

  `list<character>` - each element is a character vector naming columns
  whose combinations should be preserved e.g.
  `list(c("REGION1", "REGION1N"))`. Default is an empty list.

- seed:

  `integer` - random seed for reproducibility.

## Value

`summary_bds` - summary object for BDS simulation.

## Examples

``` r

# BDS simulation needs a synthetic ADSL first to provide the subject spine.
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
  visit_cols = c("AVISIT", "AVISITN"),
  flag_cols = "ANL01FL"
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
