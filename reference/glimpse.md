# Glimpse a vector.

Extracts a statistical summary from a vector that preserves its
structure while enabling synthetic data generation. The summary type
varies by vector class: character vectors output unique values, numeric
vectors output min/max values, and date/time vectors output
earliest/latest dates.

## Usage

``` r
glimpse(x, ...)

# S3 method for class 'character'
glimpse(x, col_name, na_mode = "mirror", seed = NULL, ...)

# S3 method for class 'Date'
glimpse(x, col_name, na_mode = "mirror", seed = NULL, ...)

# S3 method for class 'POSIXct'
glimpse(x, col_name, na_mode = "mirror", seed = NULL, ...)

# S3 method for class 'difftime'
glimpse(x, col_name, na_mode = "mirror", seed = NULL, ...)

# S3 method for class 'numeric'
glimpse(x, col_name, na_mode = "mirror", seed = NULL, ...)
```

## Arguments

- x:

  `vector` - input vector.

- ...:

  additional arguments passed to methods.

- col_name:

  `character` - column name corresponding to the input vector.

- na_mode:

  `character` - "mirror" to capture NA positions, "none" to ignore NAs
  in simulation.

- seed:

  `integer` - random seed for reproducibility.

## Value

`summary` - contains summary of the input vector.

## Methods (by class)

- `glimpse(character)`: glimpse a character vector using
  [`.get_unique_values()`](https://novartis.github.io/synadam/reference/dot-get_unique_values.md).

- `glimpse(Date)`: glimpse a Date vector into a summary containing the
  min, max, and NA positions.

- `glimpse(POSIXct)`: glimpse a POSIXct vector into a summary containing
  the min, max, and NA positions.

- `glimpse(difftime)`: glimpse a difftime vector into a summary
  containing the min, max, units, and NA positions.

- `glimpse(numeric)`: glimpse a numeric vector into a summary containing
  the min, max, and NA positions. Detects if values are integer or
  double.

## Examples

``` r
# Glimpse a character vector, then simulate synthetic values from it.
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
