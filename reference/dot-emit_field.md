# Emit YAML lines for one field of a dataset block.

Handles the special cases for `seq_col` (scalar) and `ordered_col_sets`
(block-style list of pairs); everything else is a flow-style list.

## Usage

``` r
.emit_field(field, value, confidence)
```

## Arguments

- field:

  `character(1)` - field name.

- value:

  the field value (`character` vector, scalar, or list of pairs
  depending on `field`).

- confidence:

  `character(1)` or `NULL` - REVIEW comment for this field, appended
  inline.

## Value

`character` - one or more YAML lines.
