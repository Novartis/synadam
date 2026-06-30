# Glimpse parameter columns.

Extracts unique combinations of parameter columns without filtering.
Used for TTE datasets where all PARAMCDs are simulated. Rare
combinations (count = 1) are masked for privacy protection.

## Usage

``` r
glimpse_params(df)
```

## Arguments

- df:

  `data.frame` - contains parameter columns.

## Value

`summary_params` - contains unique parameter combinations.

## Examples

``` r
df <- data.frame(
  PARAM = c("Overall Survival", "Overall Survival", "Progression Free"),
  PARAMCD = c("OS", "OS", "PFS")
)
glimpse_params(df)
#> 1 parameter combination(s) with count = 1 were masked and added to the most common combination.
#> $unique_params
#>              PARAM PARAMCD
#> 1 Overall Survival      OS
#> 
#> attr(,"class")
#> [1] "summary_params" "summary"       
```
