# Render the full YAML config text from a list of dataset entries.

Render the full YAML config text from a list of dataset entries.

## Usage

``` r
.render_config_yaml(entries, output_dir, seed)
```

## Arguments

- entries:

  `list` - one entry per dataset, each holding `path`, `dataset_type`,
  `args`, `confidence`, and (for REVIEW) `cols`.

- output_dir:

  `character(1)` - value for the top-level `output_dir` field.

- seed:

  `numeric(1)` or `NULL` - value for the top-level `seed` field; `NULL`
  writes a REVIEW placeholder.

## Value

`character(1)` - the YAML document as a single newline-joined string.
