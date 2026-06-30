# Coerce a YAML-derived list field to a character vector.

Treats any length-0 input (NULL, list(), character()) as the default;
otherwise unlist to a character vector.

## Usage

``` r
.as_character_or_default(x, default = character())
```

## Arguments

- x:

  `list`/`character`/`NULL` - YAML field value.

- default:

  `character` - value to return when `x` is empty.

## Value

`character` vector.
