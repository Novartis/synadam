# Validate input arguments for `glimpse_occds()`.

Validate input arguments for
[`glimpse_occds()`](https://novartis.github.io/synadam/reference/glimpse_occds.md).

## Usage

``` r
.validate_input_glimpse_occds(
  occds,
  syn_adsl,
  id_cols,
  seq_col,
  flag_cols,
  ordered_col_sets
)
```

## Arguments

- occds:

  `data.frame` - input OCCDS dataset e.g. ADAE, ADCM.

- syn_adsl:

  `data.frame` - synthetic ADSL to obtain subject-level data from.
  Should be created by
  [`simulate_adsl()`](https://novartis.github.io/synadam/reference/simulate_adsl.md).

- id_cols:

  `character` - ID column names that identify subjects e.g.
  c("USUBJID"). These columns must exist in `syn_adsl` and will be taken
  from there (never simulated).

- seq_col:

  `character` - sequence column name e.g. "AESEQ", "CMSEQ".

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
