# Validate input arguments for `glimpse_tte()`.

Validate input arguments for
[`glimpse_tte()`](https://novartis.github.io/synadam/reference/glimpse_tte.md).

## Usage

``` r
.validate_input_glimpse_tte(
  tte,
  syn_adsl,
  param_cols,
  censor_cols,
  flag_cols,
  ordered_col_sets
)
```

## Arguments

- tte:

  `data.frame` - input TTE dataset e.g. ADTTE.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- param_cols:

  `character` - parameter columns e.g. c("PARAM", "PARAMCD").

- censor_cols:

  `character` - censoring columns e.g. c("CNSR", "EVNTDESC",
  "CNSDTDSC"). These columns are treated as an ordered set to preserve
  co-occurrence patterns. Only needed when multiple censor columns
  should be kept together. Default is an empty character vector (censor
  columns are treated as regular columns).

- flag_cols:

  `character` - flag columns that will be sampled as Y/N in proportion
  to input e.g. c("ANL01FL"). Default is an empty character vector (no
  flag columns).

- ordered_col_sets:

  `list<character>` - each element is a character vector naming columns
  whose combinations should be preserved e.g.
  `list(c("REGION1", "REGION1N"))`. Default is an empty list.

## Value

None.
