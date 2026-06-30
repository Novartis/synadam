# Validate input arguments for `glimpse_adsl()`.

Validate input arguments for
[`glimpse_adsl()`](https://novartis.github.io/synadam/reference/glimpse_adsl.md).

## Usage

``` r
.validate_input_glimpse_adsl(
  adsl,
  id_cols,
  treatment_cols,
  flag_cols,
  ordered_col_sets
)
```

## Arguments

- adsl:

  `data.frame` - input ADSL dataset.

- id_cols:

  `character` - ID columns e.g. "USUBJID".

- treatment_cols:

  `character` - treatment columns e.g. "TRT01A".

- flag_cols:

  `character` - flag columns e.g. "SAFFL". Default is an empty character
  vector (no flag columns).

- ordered_col_sets:

  `list<character>` - each element is a character vector naming columns
  whose combinations should be preserved e.g.
  `list(c("REGION1", "REGION1N"))`. Default is an empty list.

## Value

None.
