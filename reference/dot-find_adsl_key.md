# Find the ADSL key in a summaries list.

Find the ADSL key in a summaries list.

## Usage

``` r
.find_adsl_key(summaries)
```

## Arguments

- summaries:

  named list of classed summary objects.

## Value

`character(1)` - the name of the entry whose summary inherits from
`summary_adsl`. Errors if absent or duplicated.
