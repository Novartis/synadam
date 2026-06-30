# Read in an ADaM dataset.

Loads in a ADaM dataset and and convert all missing values to NA.

## Usage

``` r
read_sas7bdat(adam_path)
```

## Arguments

- adam_path:

  `character` - path to the `.sas7bdat` file containing the ADaM
  dataset.

## Value

`data.frame` - ADaM dataset.

## Examples

``` r
adam <- read_sas7bdat(sas_path)
head(adam)
#> # A tibble: 6 × 21
#>   STUDYID    USUBJID SUBJID SITEID TRT01A TRT01AN   AGE AGEU  SEX   RACE  ETHNIC
#>   <chr>      <chr>    <dbl>  <dbl> <chr>    <dbl> <dbl> <chr> <chr> <chr> <chr> 
#> 1 CDISCPILO… CDISCP…      1    701 Place…       0    63 YEARS F     WHITE NOT H…
#> 2 CDISCPILO… CDISCP…      2    701 Place…       0    71 YEARS M     WHITE NOT H…
#> 3 CDISCPILO… CDISCP…      3    701 Xanom…       1    55 YEARS F     WHITE HISPA…
#> 4 CDISCPILO… CDISCP…      4    702 Xanom…       1    68 YEARS M     BLAC… NOT H…
#> 5 CDISCPILO… CDISCP…      5    702 Xanom…       2    74 YEARS F     WHITE NOT H…
#> 6 CDISCPILO… CDISCP…      6    702 Xanom…       2    59 YEARS M     WHITE NOT H…
#> # ℹ 10 more variables: SAFFL <chr>, ITTFL <chr>, EFFFL <chr>, REGION1 <chr>,
#> #   REGION1N <dbl>, COUNTRY <chr>, HEIGHTBL <dbl>, WEIGHTBL <dbl>, BMIBL <dbl>,
#> #   TRTSDT <chr>
```
