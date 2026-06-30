# Glimpse parameter and visit columns.

Extracts per-subject param/visit profiles from a BDS dataset. Rare
param/visit combinations (count = 1) are masked for privacy protection.
Subjects are grouped by their set of surviving param/visit combinations
to form profiles, which are used by
[`simulate_bds()`](https://novartis.github.io/synadam/reference/simulate_bds.md)
to construct the simulation spine.

## Usage

``` r
glimpse_param_visits(df, id_cols, param_visit_cols)
```

## Arguments

- df:

  `data.frame` - contains ID and parameter/visit columns.

- id_cols:

  `character` - ID column(s) to identify subjects e.g. c("USUBJID").

- param_visit_cols:

  `character` - parameter and visit column names e.g. c("PARAM",
  "PARAMCD", "AVISIT", "AVISITN").

## Value

`summary_param_visits` - contains deduplicated profiles with masked
counts and the unique param/visit combinations (after masking).

## Examples

``` r
# Build per-subject parameter/visit profiles (used within glimpse_bds()).
glimpse_param_visits(
  adlb,
  id_cols = "USUBJID",
  param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
)
#> $profiles
#> $profiles[[1]]
#> # A tibble: 6 × 4
#>   PARAM                      PARAMCD AVISIT   AVISITN
#>   <chr>                      <chr>   <chr>      <int>
#> 1 Albumin (g/L)              ALB     Baseline       0
#> 2 Albumin (g/L)              ALB     Week 2         2
#> 3 Albumin (g/L)              ALB     Week 4         4
#> 4 Alkaline Phosphatase (U/L) ALP     Baseline       0
#> 5 Alkaline Phosphatase (U/L) ALP     Week 2         2
#> 6 Alkaline Phosphatase (U/L) ALP     Week 4         4
#> 
#> 
#> $profile_counts
#> [1] 12
#> 
#> $unique_param_visits
#>                        PARAM PARAMCD   AVISIT AVISITN
#> 1              Albumin (g/L)     ALB Baseline       0
#> 2              Albumin (g/L)     ALB   Week 2       2
#> 3              Albumin (g/L)     ALB   Week 4       4
#> 4 Alkaline Phosphatase (U/L)     ALP Baseline       0
#> 5 Alkaline Phosphatase (U/L)     ALP   Week 2       2
#> 6 Alkaline Phosphatase (U/L)     ALP   Week 4       4
#> 
#> attr(,"class")
#> [1] "summary_param_visits" "summary"             
```
