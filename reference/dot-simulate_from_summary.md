# Dispatch a single summary to its corresponding simulate\_\* function.

Dispatch a single summary to its corresponding simulate\_\* function.

## Usage

``` r
.simulate_from_summary(summary, seed)
```

## Arguments

- summary:

  classed summary object (`summary_adsl` / `summary_bds` / `summary_tte`
  / `summary_occds`).

- seed:

  `integer` or `NULL` - simulation seed.

## Value

`data.frame` of synthetic data.
