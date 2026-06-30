# Infer ADSL glimpse arguments from column names.

Infer ADSL glimpse arguments from column names.

## Usage

``` r
.infer_cols_adsl(cols)
```

## Arguments

- cols:

  `character` - column names of the ADSL dataset.

## Value

`list(args, confidence)` - args ready for the YAML emitter and per-field
REVIEW notes for low-confidence inferences.
