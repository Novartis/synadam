# List `ad*.sas7bdat` and `ad*.parquet` files in an ADaM directory.

Files whose basename does not match `ad*.sas7bdat` or `ad*.parquet`
(case-insensitive) are skipped with a single warning listing them.

## Usage

``` r
.scan_adam_dir(adam_dir)
```

## Arguments

- adam_dir:

  `character(1)` - directory to scan.

## Value

`character` - full paths to all matching `.sas7bdat` and `.parquet`
files; errors if none.
