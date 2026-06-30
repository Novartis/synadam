# Glimpse ordered columns.

Ordered columns are those which should be simulated together, such as
PARAM/PARAMCD or REGION1/REGION1N/REGION2/REGION2N. Rare combinations
(count = 1) are masked for privacy protection.

## Usage

``` r
glimpse_ordered(df)
```

## Arguments

- df:

  `data.frame` - contains ordered columns.

## Value

`summary` - contains column names, unique combinations, and NA
positions.

## Examples

``` r
df <- data.frame(
  REGION1 = c("North America", "North America", "Europe", "Europe"),
  REGION1N = c(1, 1, 2, 2)
)
summary <- glimpse_ordered(df)
simulate(summary, output_length = 6, seed = 1)
#>           REGION1 REGION1N
#> 1          Europe        2
#> 2   North America        1
#> 1.1        Europe        2
#> 1.2        Europe        2
#> 2.1 North America        1
#> 1.3        Europe        2
```
