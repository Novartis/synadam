# Build the per-dataset summary list for a study config.

Walks the config in dataset-key order with ADSL first, runs the
appropriate glimpse function, and (for ADSL) simulates the synthetic
ADSL needed by downstream BDS / OCCDS / TTE glimpses.

## Usage

``` r
.glimpse_study_summaries(config)
```

## Arguments

- config:

  `list` - parsed YAML config (already validated).

## Value

Named list of summary objects keyed by dataset name.
