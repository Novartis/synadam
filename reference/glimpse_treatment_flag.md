# Glimpse treatment and flag columns together.

Captures unique combinations of treatment and flag columns with their
counts, preserving the relationship between treatments and analysis
flags. Combinations with count = 1 are masked for privacy protection by
adding their counts to the most common combination.

## Usage

``` r
glimpse_treatment_flag(df)
```

## Arguments

- df:

  `data.frame` - contains treatment and flag columns.

## Value

`summary` - contains treatment-flag combinations with counts.

## Examples

``` r
df <- data.frame(
  TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
  SAFFL = c("Y", "Y", "Y", "N")
)
summary <- glimpse_treatment_flag(df)
#> 2 treatment/flag combination(s) with count = 1 were masked and added to the most common combination.
# simulate() preserves the exact treatment-flag counts (no output_length).
simulate(summary)
#>    TRT01A SAFFL
#> 1 Placebo     Y
#> 2 Placebo     Y
#> 3 Placebo     Y
#> 4 Placebo     Y
```
