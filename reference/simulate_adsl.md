# Simulate a synthetic ADSL.

Generates synthetic subject-level data from an ADSL summary, preserving
the structure of the original dataset.

## Usage

``` r
simulate_adsl(adsl_summary, seed = NULL)
```

## Arguments

- adsl_summary:

  `summary_adsl` - contains summary objects that describe an ADSL
  dataset. Created by
  [`glimpse_adsl()`](https://novartis.github.io/synadam/reference/glimpse_adsl.md).

- seed:

  `integer` - random seed for reproducibility.

## Value

`data.frame` - synthetic ADSL with the same columns (and column order)
as the dataset that was glimpsed, and one row per subject.

## Examples

``` r
adsl_summary <- glimpse_adsl(
  adsl,
  id_cols = c("USUBJID", "SUBJID"),
  treatment_cols = c("TRT01A", "TRT01AN"),
  flag_cols = "SAFFL"
)
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
#> Glimpsing column(s): ITTFL
#> Glimpsing column(s): EFFFL
#> Glimpsing column(s): REGION1
#> Glimpsing column(s): REGION1N
#> Glimpsing column(s): COUNTRY
#> Glimpsing column(s): HEIGHTBL
#> Glimpsing column(s): WEIGHTBL
#> Glimpsing column(s): BMIBL
#> Glimpsing column(s): TRTSDT
syn_adsl <- simulate_adsl(adsl_summary, seed = 42)
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
#> Simulating column(s): ITTFL
#> Simulating column(s): EFFFL
#> Simulating column(s): REGION1
#> Simulating column(s): REGION1N
#> Simulating column(s): COUNTRY
#> Simulating column(s): HEIGHTBL
#> Simulating column(s): WEIGHTBL
#> Simulating column(s): BMIBL
#> Simulating column(s): TRTSDT
head(syn_adsl)
#>        STUDYID   USUBJID   SUBJID SITEID               TRT01A TRT01AN AGE  AGEU
#> 1 CDISCPILOT01 USUBJID_1 SUBJID_1    704              Placebo       0  75 YEARS
#> 2 CDISCPILOT01 USUBJID_2 SUBJID_2    704              Placebo       0  76 YEARS
#> 3 CDISCPILOT01 USUBJID_3 SUBJID_3    702              Placebo       0  61 YEARS
#> 4 CDISCPILOT01 USUBJID_4 SUBJID_4    703              Placebo       0  73 YEARS
#> 5 CDISCPILOT01 USUBJID_5 SUBJID_5    703 Xanomeline High Dose       2  69 YEARS
#> 6 CDISCPILOT01 USUBJID_6 SUBJID_6    703 Xanomeline High Dose       2  66 YEARS
#>   SEX                      RACE                 ETHNIC SAFFL ITTFL EFFFL
#> 1   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y     N
#> 2   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y     N
#> 3   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y     N
#> 4   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y     N
#> 5   M                     WHITE NOT HISPANIC OR LATINO     Y     Y     Y
#> 6   M                     WHITE NOT HISPANIC OR LATINO     Y     Y     Y
#>         REGION1 REGION1N COUNTRY HEIGHTBL WEIGHTBL    BMIBL TRTSDT
#> 1        Europe        2     GBR 180.8276 91.81557 27.82697 MASKED
#> 2        Europe        2     GBR 181.3954 92.72638 28.00290 MASKED
#> 3        Europe        1     GBR 164.7966 66.10311 22.86050 MASKED
#> 4        Europe        2     GBR 178.6764 88.36531 27.16054 MASKED
#> 5 North America        2     USA 173.8645 80.64739 25.66979 MASKED
#> 6 North America        2     USA 170.7369 75.63102 24.70086 MASKED
```
