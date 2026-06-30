# Simulate a synthetic TTE dataset.

Generates synthetic TTE data by creating a spine from parameter
combinations and ADSL subject records, then populating remaining
columns, preserving the original data structure. Produces exactly one
record per subject per parameter (the defining TTE constraint).

## Usage

``` r
simulate_tte(tte_summary, seed = NULL)
```

## Arguments

- tte_summary:

  `summary_tte` - summary object created by
  [`glimpse_tte()`](https://novartis.github.io/synadam/reference/glimpse_tte.md).

- seed:

  `integer` - random seed for reproducibility.

## Value

`data.frame` - synthetic TTE dataset.

## Examples

``` r
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
  AVAL = c(365, 500, 180, 250, 600, 120)
)

tte_summary <- glimpse_tte(
  tte,
  syn_adsl,
  param_cols = c("PARAM", "PARAMCD")
)
#> Glimpsing PARAM columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing column(s): CNSR
#> Glimpsing column(s): AVAL
syn_tte <- simulate_tte(tte_summary, seed = 42)
#> Simulating PARAM and ADSL columns
#> Simulating column(s): CNSR
#> Simulating column(s): AVAL
head(syn_tte)
#> # A tibble: 6 × 5
#>   USUBJID PARAM                     PARAMCD  CNSR  AVAL
#>   <chr>   <chr>                     <chr>   <dbl> <dbl>
#> 1 1       Overall Survival          OS          1   559
#> 2 2       Overall Survival          OS          1   570
#> 3 3       Overall Survival          OS          0   257
#> 4 4       Overall Survival          OS          1   519
#> 5 5       Overall Survival          OS          1   428
#> 6 1       Progression Free Survival PFS         1   369
```
