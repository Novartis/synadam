# Find X/XN/XL ordered column groups.

Detects groups where two or three of the variants exist together and
none of the members is already claimed by a more specific role. For a
base column X, the emitted group includes X plus whichever of XN and XL
exist (e.g. REGION1 plus REGION1N, SEX plus SEXL, or ETHNIC plus ETHNICN
plus ETHNICL).

## Usage

``` r
.find_ordered_sets(cols, exclude = character())
```

## Arguments

- cols:

  `character` - column names to scan.

- exclude:

  `character` - columns already claimed by a more specific role and
  therefore ineligible for grouping.

## Value

`list` of `character` vectors, one per detected group.
