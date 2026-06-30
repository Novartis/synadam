# Mask rare combinations for privacy protection.

Internal helper that filters out combinations with count = 1 and
redistributes their counts to the most common combination.

## Usage

``` r
.mask_combinations(counts, context_name = "combination")
```

## Arguments

- counts:

  `data.frame` - contains combinations, with a column named `n`
  containing counts for each combination.

- context_name:

  `character` - descriptive name for the type of combination being
  masked (e.g., "treatment/flag", "ordered column"). Used in messages.

## Value

`data.frame` - combinations with count = 1 have been removed and their
counts have been added to the most common combination.
