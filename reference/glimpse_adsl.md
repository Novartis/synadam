# Glimpse an ADSL dataset.

Summarizes an ADSL (subject-level) dataset for synthetic simulation by
preserving treatment-flag relationships, capturing ordered column
combinations and extracting summaries for all other variables.

## Usage

``` r
glimpse_adsl(
  adsl,
  id_cols,
  treatment_cols,
  flag_cols = character(),
  ordered_col_sets = list(),
  seed = NULL
)
```

## Arguments

- adsl:

  `data.frame` - input ADSL dataset.

- id_cols:

  `character` - ID columns e.g. "USUBJID".

- treatment_cols:

  `character` - treatment columns e.g. "TRT01A".

- flag_cols:

  `character` - flag columns e.g. "SAFFL". Default is an empty character
  vector (no flag columns).

- ordered_col_sets:

  `list<character>` - each element is a character vector naming columns
  whose combinations should be preserved e.g.
  `list(c("REGION1", "REGION1N"))`. Default is an empty list.

- seed:

  `integer` - random seed for reproducibility.

## Value

`summary_adsl` - list of summary objects, with each summarising a column
or set of columns in the input ADSL.

## Examples

``` r
# Glimpse the ADSL, then simulate a synthetic version from the summary.
adsl_summary <- glimpse_adsl(
  adsl,
  id_cols = c("USUBJID", "SUBJID"),
  treatment_cols = c("TRT01A", "TRT01AN"),
  flag_cols = c("SAFFL", "ITTFL", "EFFFL"),
  ordered_col_sets = list(c("REGION1", "REGION1N")),
  seed = 42
)
#> Glimpsing treatment/flag columns
#> 2 treatment/flag combination(s) with count = 1 were masked and added to the most common combination.
#> Glimpsing column(s): REGION1, REGION1N
#> Glimpsing column(s): STUDYID
#> Glimpsing column(s): USUBJID
#> Glimpsing column(s): SUBJID
#> Glimpsing column(s): SITEID
#> Glimpsing column(s): AGE
#> Glimpsing column(s): AGEU
#> Glimpsing column(s): SEX
#> Glimpsing column(s): RACE
#> Glimpsing column(s): ETHNIC
#> Glimpsing column(s): COUNTRY
#> Glimpsing column(s): HEIGHTBL
#> Glimpsing column(s): WEIGHTBL
#> Glimpsing column(s): BMIBL
#> Glimpsing column(s): TRTSDT
syn_adsl <- simulate_adsl(adsl_summary, seed = 42)
#> Simulating column(s): treatment, flag
#> Simulating column(s): REGION1, REGION1N
#> Simulating column(s): STUDYID
#> Simulating column(s): USUBJID
#> Simulating column(s): SUBJID
#> Simulating column(s): SITEID
#> Simulating column(s): AGE
#> Simulating column(s): AGEU
#> Simulating column(s): SEX
#> Simulating column(s): RACE
#> Simulating column(s): ETHNIC
#> Simulating column(s): COUNTRY
#> Simulating column(s): HEIGHTBL
#> Simulating column(s): WEIGHTBL
#> Simulating column(s): BMIBL
#> Simulating column(s): TRTSDT
head(syn_adsl)
#>          STUDYID   USUBJID   SUBJID SITEID               TRT01A TRT01AN AGE
#> 1   CDISCPILOT01 USUBJID_1 SUBJID_1    704              Placebo       0  75
#> 1.1 CDISCPILOT01 USUBJID_2 SUBJID_2    704              Placebo       0  76
#> 1.2 CDISCPILOT01 USUBJID_3 SUBJID_3    702              Placebo       0  61
#> 1.3 CDISCPILOT01 USUBJID_4 SUBJID_4    703 Xanomeline High Dose       2  73
#> 2   CDISCPILOT01 USUBJID_5 SUBJID_5    703 Xanomeline High Dose       2  69
#> 2.1 CDISCPILOT01 USUBJID_6 SUBJID_6    703 Xanomeline High Dose       2  66
#>      AGEU SEX                      RACE                 ETHNIC SAFFL ITTFL
#> 1   YEARS   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y
#> 1.1 YEARS   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y
#> 1.2 YEARS   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y
#> 1.3 YEARS   F BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO     Y     Y
#> 2   YEARS   M                     WHITE NOT HISPANIC OR LATINO     Y     Y
#> 2.1 YEARS   M                     WHITE NOT HISPANIC OR LATINO     Y     Y
#>     EFFFL       REGION1 REGION1N COUNTRY HEIGHTBL WEIGHTBL    BMIBL TRTSDT
#> 1       Y        Europe        2     GBR 180.8276 91.81557 27.82697 MASKED
#> 1.1     Y        Europe        2     GBR 181.3954 92.72638 28.00290 MASKED
#> 1.2     Y        Europe        2     GBR 164.7966 66.10311 22.86050 MASKED
#> 1.3     Y        Europe        2     GBR 178.6764 88.36531 27.16054 MASKED
#> 2       Y North America        1     USA 173.8645 80.64739 25.66979 MASKED
#> 2.1     Y North America        1     USA 170.7369 75.63102 24.70086 MASKED
```
