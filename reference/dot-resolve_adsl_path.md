# Resolve the canonical ADSL path from one or more candidates.

Errors if no ADSL was detected. When multiple candidates are present,
prefers a file named exactly `adsl.sas7bdat` (case-insensitive); else
falls back to the alphabetically-first candidate. The non-chosen
candidates are reported in a warning.

## Usage

``` r
.resolve_adsl_path(adsl_paths, all_paths)
```

## Arguments

- adsl_paths:

  `character` - paths classified as ADSL.

- all_paths:

  `character` - all scanned paths (for error messages).

## Value

`character(1)` - the chosen ADSL path. Errors if zero ADSL.
