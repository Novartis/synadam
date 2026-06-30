# Simulate synthetic ADaM datasets from a previously-saved study summary.

Reads a study summary written by
[`glimpse_study()`](https://novartis.github.io/synadam/reference/glimpse_study.md)
and produces synthetic datasets, decoupling simulation from the original
`.sas7bdat` files.

## Usage

``` r
simulate_study_from_summary(study_summary_path, output_dir, seed = NULL)
```

## Arguments

- study_summary_path:

  `character` - path to the `.rds` study summary written by
  [`glimpse_study()`](https://novartis.github.io/synadam/reference/glimpse_study.md).

- output_dir:

  `character` - directory to write `syn_{key}.rds` files to. Created if
  missing.

- seed:

  `integer` or `NULL` - simulation seed. When `NULL` (default), the seed
  stored in the study summary is used; if the study summary has no seed,
  it falls back to `123`. Override to draw a different synthetic
  replicate from the same summaries.

## Value

`NULL` (invisibly). Synthetic datasets are saved as `syn_{key}.rds`
files in `output_dir`. Each dataset has a `synadam_version` attribute.

## See also

[`glimpse_study()`](https://novartis.github.io/synadam/reference/glimpse_study.md),
[`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md).

## Examples

``` r
# Generate a config and glimpse the datasets into a study summary.
yaml_path <- generate_study_config(
  adam_dir,
  output_dir = file.path(tempdir(), "syn_data")
)
study_summary_path <- tempfile(fileext = ".rds")
glimpse_study(yaml_path, study_summary_path)
#> ----- Glimpsing adsl (adsl) dataset -----
#> Loading dataset from /tmp/RtmpS9mnbx/adam_dir/adsl.sas7bdat
#> Glimpsing treatment/flag columns
#> 2 treatment/flag combination(s) with count = 1 were masked and added to the most common combination.
#> Glimpsing column(s): REGION1, REGION1N
#> Glimpsing column(s): STUDYID
#> Glimpsing column(s): USUBJID
#> Glimpsing column(s): SUBJID
#> Glimpsing column(s): SITEID
#> Glimpsing column(s): AGE
#> Glimpsing column(s): AGEU
#> Glimpsing column(s): SEX
#> Glimpsing column(s): RACE
#> Glimpsing column(s): ETHNIC
#> Glimpsing column(s): COUNTRY
#> Glimpsing column(s): HEIGHTBL
#> Glimpsing column(s): WEIGHTBL
#> Glimpsing column(s): BMIBL
#> Glimpsing column(s): TRTSDT
#> Simulating column(s): treatment, flag
#> Simulating column(s): REGION1, REGION1N
#> Simulating column(s): STUDYID
#> Simulating column(s): USUBJID
#> Simulating column(s): SUBJID
#> Simulating column(s): SITEID
#> Simulating column(s): AGE
#> Simulating column(s): AGEU
#> Simulating column(s): SEX
#> Simulating column(s): RACE
#> Simulating column(s): ETHNIC
#> Simulating column(s): COUNTRY
#> Simulating column(s): HEIGHTBL
#> Simulating column(s): WEIGHTBL
#> Simulating column(s): BMIBL
#> Simulating column(s): TRTSDT
#> ----- Glimpsing adae (occds) dataset -----
#> Loading dataset from /tmp/RtmpS9mnbx/adam_dir/adae.sas7bdat
#> Glimpsing occurrence counts, ID and sequence columns
#> Glimpsing ADSL columns from synthetic ADSL
#> Glimpsing column(s): AESEV, AESEVN
#> Glimpsing column(s): AEBODSYS
#> Glimpsing column(s): AEDECOD
#> Glimpsing column(s): AESER
#> Glimpsing column(s): AEREL
#> Glimpsing column(s): ASTDT
#> Glimpsing column(s): AENDT
#> Saving study summary to /tmp/RtmpS9mnbx/file468322a36c3.rds...

# Simulate synthetic datasets from the saved study summary.
out_dir <- file.path(tempdir(), "syn_data")
simulate_study_from_summary(study_summary_path, out_dir)
#> ----- Simulating adsl -----
#> Simulating column(s): treatment, flag
#> Simulating column(s): REGION1, REGION1N
#> Simulating column(s): STUDYID
#> Simulating column(s): USUBJID
#> Simulating column(s): SUBJID
#> Simulating column(s): SITEID
#> Simulating column(s): AGE
#> Simulating column(s): AGEU
#> Simulating column(s): SEX
#> Simulating column(s): RACE
#> Simulating column(s): ETHNIC
#> Simulating column(s): COUNTRY
#> Simulating column(s): HEIGHTBL
#> Simulating column(s): WEIGHTBL
#> Simulating column(s): BMIBL
#> Simulating column(s): TRTSDT
#> Saving adsl to /tmp/RtmpS9mnbx/syn_data/syn_adsl.rds...
#> ----- Simulating adae -----
#> Simulating occurrence counts
#> Simulating sequence column
#> Simulating column(s): AESEV, AESEVN
#> Simulating column(s): AEBODSYS
#> Simulating column(s): AEDECOD
#> Simulating column(s): AESER
#> Simulating column(s): AEREL
#> Simulating column(s): ASTDT
#> Simulating column(s): AENDT
#> Saving adae to /tmp/RtmpS9mnbx/syn_data/syn_adae.rds...
list.files(out_dir, pattern = "\\.rds$")
#> [1] "syn_adae.rds" "syn_adsl.rds"
```
