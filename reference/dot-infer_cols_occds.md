# Infer OCCDS glimpse arguments from column names.

Infer OCCDS glimpse arguments from column names.

## Usage

``` r
.infer_cols_occds(cols, adsl_cols = character())
```

## Arguments

- cols:

  `character` - column names of the OCCDS dataset.

- adsl_cols:

  `character` - column names of the chosen ADSL. Excluded from
  `ordered_col_sets` since the ADSL spine contributes them at simulation
  time; listing them again would duplicate the column.

## Value

`list(args, confidence)` - args ready for the YAML emitter and per-field
REVIEW notes for low-confidence inferences.
