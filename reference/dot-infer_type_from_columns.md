# Classify a dataset by column presence.

Classify a dataset by column presence.

## Usage

``` r
.infer_type_from_columns(cols)
```

## Arguments

- cols:

  `character` - column names of the dataset.

## Value

`character(1)` - one of `"adsl"`, `"bds"`, `"occds"`, `"tte"`, or
`"REVIEW"` when no rule matches.
