# Glimpse a column stratified by another column.

Produces one child summary (via
[`glimpse()`](https://novartis.github.io/synadam/reference/glimpse.md))
per stratum value, so
[`simulate()`](https://novartis.github.io/synadam/reference/simulate.md)
can draw the column conditional on the stratum (e.g. a value per
PARAMCD). NA is a legitimate stratum with its own child; strata are
matched positionally (NA-safe) rather than by name.

## Usage

``` r
.glimpse_stratified(x, col_name, strata, seed = NULL)
```

## Arguments

- x:

  `vector` - the column values.

- col_name:

  `character` - the column name.

- strata:

  `vector` - stratum value per element of `x` (e.g. PARAMCD).

- seed:

  `integer` - random seed.

## Value

`summary_stratified` - stratum levels and per-stratum children.
