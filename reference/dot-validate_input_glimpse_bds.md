# Validate input arguments for `glimpse_bds()`.

Validate input arguments for
[`glimpse_bds()`](https://novartis.github.io/synadam/reference/glimpse_bds.md).

## Usage

``` r
.validate_input_glimpse_bds(
  bds,
  syn_adsl,
  id_cols,
  param_cols,
  visit_cols,
  flag_cols,
  ordered_col_sets
)
```

## Arguments

- bds:

  `data.frame` - input BDS dataset e.g. ADLB.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- id_cols:

  `character` - ID column names that identify subjects e.g.
  c("USUBJID"). These columns must exist in `syn_adsl` and will be taken
  from there (never simulated).

- param_cols:

  `character` - parameter columns e.g. c("PARAM", "PARAMCD").

- visit_cols:

  `character` - visit columns e.g. c("AVISIT", "AVISITN"). Default is an
  empty character vector (no visit columns).

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
