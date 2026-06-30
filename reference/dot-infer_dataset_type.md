# Infer the ADaM dataset type for a file.

Tries the filename rules first, then falls back to column-presence
rules.

## Usage

``` r
.infer_dataset_type(path, cols)
```

## Arguments

- path:

  `character(1)` - path to the dataset file.

- cols:

  `character` - column names of the dataset.

## Value

`character(1)` - one of `"adsl"`, `"bds"`, `"occds"`, `"tte"`, or
`"REVIEW"`.
