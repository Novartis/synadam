# Infer BDS glimpse arguments from column names.

Infer BDS glimpse arguments from column names.

## Usage

``` r
.infer_cols_bds(cols, adsl_cols = character())
```

## Arguments

- cols:

  `character` - column names of the BDS dataset.

- adsl_cols:

  `character` - column names of the chosen ADSL. Excluded from
  `ordered_col_sets` since the ADSL spine contributes them at simulation
  time; listing them again would duplicate the column.

## Value

`list(args, confidence)` - args ready for the YAML emitter and per-field
REVIEW notes for low-confidence inferences.
