# Glimpse a TTE dataset.

Summarizes a TTE (Time-to-Event) dataset for synthetic simulation by
extracting parameter combinations, preserving censoring column
relationships, and extracting summaries of all other variables.

## Usage

``` r
glimpse_tte(
  tte,
  syn_adsl,
  param_cols,
  censor_cols = character(),
  flag_cols = character(),
  ordered_col_sets = list(),
  seed = NULL
)
```

## Arguments

- tte:

  `data.frame` - input TTE dataset e.g. ADTTE.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- param_cols:

  `character` - parameter columns e.g. c("PARAM", "PARAMCD").

- censor_cols:

  `character` - censoring columns e.g. c("CNSR", "EVNTDESC",
  "CNSDTDSC"). These columns are treated as an ordered set to preserve
  co-occurrence patterns. Only needed when multiple censor columns
  should be kept together. Default is an empty character vector (censor
  columns are treated as regular columns).

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

`summary_tte` - summary object for TTE simulation.

## Examples

``` r
# TTE simulation needs a synthetic ADSL to provide the subject spine.
syn_adsl <- data.frame(
  USUBJID = as.character(1:5),
  TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
  TRT01AN = c(1, 1, 2, 2, 2)
)
tte <- data.frame(
  USUBJID = as.character(rep(1:3, each = 2)),
  PARAM = rep(c("Overall Survival", "Progression Free Survival"), 3),
  PARAMCD = rep(c("OS", "PFS"), 3),
  CNSR = c(0, 1, 0, 1, 1, 0),
  EVNTDESC = c(
    "DEATH", "COMPLETED", "DEATH", "COMPLETED", "COMPLETED", "PROGRESSION"
  ),
  AVAL = c(365, 500, 180, 250, 600, 120)
)

tte_summary <- glimpse_tte(
  tte,
  syn_adsl,
  param_cols = c("PARAM", "PARAMCD"),
  censor_cols = c("CNSR", "EVNTDESC")
)
#> Glimpsing PARAM columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing censor column(s): CNSR, EVNTDESC
#> 1 ordered column combination(s) with count = 1 were masked and added to the most common combination.
#> Glimpsing column(s): AVAL
syn_tte <- simulate_tte(tte_summary, seed = 42)
#> Simulating PARAM and ADSL columns
#> Simulating column(s): censor
#> Simulating column(s): AVAL
head(syn_tte)
#>     USUBJID                     PARAM PARAMCD CNSR  EVNTDESC AVAL
#> 1         1          Overall Survival      OS    0     DEATH  559
#> 1.1       2          Overall Survival      OS    0     DEATH  570
#> 1.2       3          Overall Survival      OS    0     DEATH  257
#> 1.3       4          Overall Survival      OS    0     DEATH  519
#> 2         5          Overall Survival      OS    1 COMPLETED  428
#> 2.1       1 Progression Free Survival     PFS    1 COMPLETED  369
```
