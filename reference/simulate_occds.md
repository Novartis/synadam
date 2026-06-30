# Simulate a synthetic OCCDS dataset.

Generates synthetic OCCDS data from a summary created by
[`glimpse_occds()`](https://novartis.github.io/synadam/reference/glimpse_occds.md).

## Usage

``` r
simulate_occds(occds_summary, seed = NULL)
```

## Arguments

- occds_summary:

  `summary_occds` - summary object created by
  [`glimpse_occds()`](https://novartis.github.io/synadam/reference/glimpse_occds.md).

- seed:

  `integer` - random seed for reproducibility.

## Value

`data.frame` - synthetic OCCDS dataset.

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
occds_summary <- glimpse_occds(
  adae,
  syn_adsl,
  id_cols = "USUBJID",
  seq_col = "AESEQ"
)
#> Glimpsing occurrence counts, ID and sequence columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing column(s): AEBODSYS
#> Glimpsing column(s): AEDECOD
#> Glimpsing column(s): AESEV
#> Glimpsing column(s): AESEVN
#> Glimpsing column(s): AESER
#> Glimpsing column(s): AEREL
#> Glimpsing column(s): ASTDT
#> Glimpsing column(s): AENDT
syn_adae <- simulate_occds(occds_summary, seed = 42)
#> Simulating occurrence counts
#> Simulating sequence column
#> Simulating column(s): AEBODSYS
#> Simulating column(s): AEDECOD
#> Simulating column(s): AESEV
#> Simulating column(s): AESEVN
#> Simulating column(s): AESER
#> Simulating column(s): AEREL
#> Simulating column(s): ASTDT
#> Simulating column(s): AENDT
head(syn_adae)
#> # A tibble: 6 × 11
#>   STUDYID    USUBJID AESEQ AEBODSYS AEDECOD AESEV AESEVN AESER AEREL ASTDT AENDT
#>   <chr>      <chr>   <int> <chr>    <chr>   <chr>  <dbl> <chr> <chr> <chr> <chr>
#> 1 CDISCPILO… USUBJI…     1 GASTROI… DIARRH… MILD       2 N     NOT … 2014… MASK…
#> 2 CDISCPILO… USUBJI…     2 GASTROI… RASH    MILD       2 N     NOT … 2014… MASK…
#> 3 CDISCPILO… USUBJI…     1 GASTROI… DIARRH… MILD       1 N     NOT … 2014… MASK…
#> 4 CDISCPILO… USUBJI…     1 GASTROI… DIARRH… MILD       2 N     NOT … 2014… MASK…
#> 5 CDISCPILO… USUBJI…     2 GENERAL… DIZZIN… MODE…      2 N     POSS… 2014… MASK…
#> 6 CDISCPILO… USUBJI…     1 SKIN AN… NAUSEA  MODE…      2 N     POSS… 2014… MASK…
```
