# List `ad*.sas7bdat` files in an ADaM directory.

Files whose basename does not match `ad*.sas7bdat` (case-insensitive)
are skipped with a single warning listing them.

## Usage

``` r
.scan_adam_dir(adam_dir)
```

## Arguments

- adam_dir:

  `character(1)` - directory to scan.

## Value

`character` - full paths to all matching `.sas7bdat` files; errors if
none.
