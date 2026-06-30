# Glimpse an ID vector.

Glimpse an ID vector.

## Usage

``` r
glimpse_id(x, col_name)
```

## Arguments

- x:

  `vector` - contains ID values.

- col_name:

  `character` - column name corresponding to the input vector.

## Value

`summary` - contains column name for ID generation.

## Examples

``` r
# Glimpse an ID column, then simulate fresh sequential IDs.
summary <- glimpse_id(c("S1", "S2", "S3"), col_name = "USUBJID")
simulate(summary, output_length = 5)
#> # A tibble: 5 × 1
#>   USUBJID  
#>   <chr>    
#> 1 USUBJID_1
#> 2 USUBJID_2
#> 3 USUBJID_3
#> 4 USUBJID_4
#> 5 USUBJID_5
```
