# Wrap a string in single quotes, escaping any embedded single quotes.

Single-quoted YAML scalars do not process backslash escapes, so Windows
paths (e.g. `C:\\Users\\...`) survive verbatim. Double quotes would
treat backslash sequences like `\\U` as escape sequences and fail to
parse.

## Usage

``` r
.yaml_quote(s)
```

## Arguments

- s:

  `character(1)` - string to quote.

## Value

`character(1)` - the YAML-quoted string.
