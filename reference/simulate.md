# Simulate a vector from a summary object.

Simulate a vector from a summary object.

## Usage

``` r
# S3 method for class 'summary_ordered'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_treatment_flag'
simulate(summary, ...)

simulate(summary, ...)

# S3 method for class 'summary_character'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_Date'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_POSIXct'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_difftime'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_integer'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_double'
simulate(summary, output_length, seed = NULL, ...)

# S3 method for class 'summary_id'
simulate(summary, output_length, ...)

# S3 method for class 'summary_flag'
simulate(summary, output_length, seed = NULL, ...)
```

## Arguments

- summary:

  `summary` - output from a glimpse function.

- output_length:

  `integer` - number of rows to simulate.

- seed:

  `integer` - random seed for reproducibility.

- ...:

  additional arguments passed to methods.

## Value

`data.frame` - the simulated dataset.

## Methods (by class)

- `simulate(summary_ordered)`: simulate ordered columns by sampling from
  unique combinations.

- `simulate(summary_treatment_flag)`: simulate treatment and flag
  columns by preserving exact counts for each combination.

- `simulate(summary_character)`: simulate a character vector by sampling
  from unique values.

- `simulate(summary_Date)`: simulate a Date vector by sampling uniformly
  between min and max.

- `simulate(summary_POSIXct)`: simulate a POSIXct vector by sampling
  uniformly between min and max.

- `simulate(summary_difftime)`: simulate a difftime vector by sampling
  uniformly between min and max.

- `simulate(summary_integer)`: simulate an integerish vector by sampling
  uniformly between min and max and rounding.

- `simulate(summary_double)`: simulate a double vector by sampling
  uniformly between min and max.

- `simulate(summary_id)`: simulate an ID vector by generating sequential
  IDs.

- `simulate(summary_flag)`: simulate a flag vector by sampling Y/N in
  proportion to input.

## Examples

``` r
# Summarise a vector with glimpse().
summary <- glimpse(c("A", "B", "B", "C"), col_name = "column_name")
simulate(summary, output_length = 10, seed = 1)
#> # A tibble: 10 × 1
#>    column_name
#>    <chr>      
#>  1 B          
#>  2 B          
#>  3 B          
#>  4 B          
#>  5 B          
#>  6 B          
#>  7 B          
#>  8 B          
#>  9 B          
#> 10 B          
```
