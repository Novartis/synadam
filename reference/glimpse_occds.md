# Glimpse an OCCDS dataset.

Summarizes an OCCDS (Occurrence Data Structure) dataset for simulation.
Works with ADAE, ADCM, ADMH, ADDV and other occurrence-based datasets.

## Usage

``` r
glimpse_occds(
  occds,
  syn_adsl,
  id_cols,
  seq_col,
  flag_cols = character(0),
  ordered_col_sets = list(),
  seed = NULL
)
```

## Arguments

- occds:

  `data.frame` - input OCCDS dataset e.g. ADAE, ADCM.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- id_cols:

  `character` - ID column names that identify subjects e.g.
  c("USUBJID"). These columns must exist in `syn_adsl` and will be taken
  from there (never simulated).

- seq_col:

  `character` - sequence column name e.g. "AESEQ", "CMSEQ".

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

`summary_occds` - summary object for OCCDS simulation.

## Examples

``` r

# OCCDS simulation needs a synthetic ADSL first to provide the subject spine.
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
  seq_col = "AESEQ",
  ordered_col_sets = list(c("AEBODSYS", "AEDECOD"))
)
#> Glimpsing occurrence counts, ID and sequence columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing column(s): AEBODSYS, AEDECOD
#> 3 ordered column combination(s) with count = 1 were masked and added to the most common combination.
#> Glimpsing column(s): AESEV
#> Glimpsing column(s): AESEVN
#> Glimpsing column(s): AESER
#> Glimpsing column(s): AEREL
#> Glimpsing column(s): ASTDT
#> Glimpsing column(s): AENDT
syn_adae <- simulate_occds(occds_summary, seed = 42)
#> Simulating occurrence counts
#> Simulating sequence column
#> Simulating column(s): AEBODSYS, AEDECOD
#> Simulating column(s): AESEV
#> Simulating column(s): AESEVN
#> Simulating column(s): AESER
#> Simulating column(s): AEREL
#> Simulating column(s): ASTDT
#> Simulating column(s): AENDT
head(syn_adae)
#>          STUDYID   USUBJID AESEQ                               AEBODSYS
#> 1   CDISCPILOT01 USUBJID_1     1             GASTROINTESTINAL DISORDERS
#> 5   CDISCPILOT01 USUBJID_1     2 SKIN AND SUBCUTANEOUS TISSUE DISORDERS
#> 1.1 CDISCPILOT01 USUBJID_2     1             GASTROINTESTINAL DISORDERS
#> 1.2 CDISCPILOT01 USUBJID_3     1             GASTROINTESTINAL DISORDERS
#> 2   CDISCPILOT01 USUBJID_3     2             GASTROINTESTINAL DISORDERS
#> 4   CDISCPILOT01 USUBJID_4     1               NERVOUS SYSTEM DISORDERS
#>       AEDECOD    AESEV AESEVN AESER            AEREL      ASTDT  AENDT
#> 1   DIARRHOEA     MILD      2     N      NOT RELATED 2014-01-25 MASKED
#> 5        RASH     MILD      2     N      NOT RELATED 2014-01-25 MASKED
#> 1.1 DIARRHOEA     MILD      1     N      NOT RELATED 2014-01-25 MASKED
#> 1.2 DIARRHOEA     MILD      2     N      NOT RELATED 2014-01-25 MASKED
#> 2      NAUSEA MODERATE      2     N POSSIBLY RELATED 2014-01-25 MASKED
#> 4    HEADACHE MODERATE      2     N POSSIBLY RELATED 2014-01-25 MASKED
```
