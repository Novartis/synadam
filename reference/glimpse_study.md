# Glimpse all ADaM datasets for a study.

Reads the YAML configuration used by
[`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md),
runs the appropriate `glimpse_*()` for each dataset, and saves the
collected summaries (plus seed and version metadata) to a single `.rds`
file.

## Usage

``` r
glimpse_study(config_path, study_summary_path)
```

## Arguments

- config_path:

  `character` - path to YAML configuration file. Has the same structure
  as the one consumed by
  [`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md).

- study_summary_path:

  `character` - path to write the study summary `.rds` file. The parent
  directory will be created if it does not exist.

## Value

`NULL` (invisibly). The study summary is a named list with elements
`summaries` (named list of glimpse summary objects, keyed by dataset
name from the YAML), `seed`, `synadam_version`, and `glimpsed_at`.

## Details

The resulting study summary can later be passed to
[`simulate_study_from_summary()`](https://novartis.github.io/synadam/reference/simulate_study_from_summary.md)
to generate the synthetic datasets, decoupling the glimpse phase (which
requires access to real `.sas7bdat` files) from the simulate phase.

## See also

[`simulate_study_from_summary()`](https://novartis.github.io/synadam/reference/simulate_study_from_summary.md),
[`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md).

## Examples

``` r
# Generate a config for the staged ADaM datasets.
yaml_path <- generate_study_config(
  adam_dir,
  output_dir = file.path(tempdir(), "syn_glimpse_out")
)

# Glimpse phase: write the study summary (decoupled from the SAS files).
summary_path <- tempfile(fileext = ".rds")
glimpse_study(yaml_path, summary_path)
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
#> Saving study summary to /tmp/RtmpS9mnbx/file46831b65237a.rds...

# Simulate phase: generate synthetic datasets from the study summary.
out_dir <- file.path(tempdir(), "syn_glimpse_out")
simulate_study_from_summary(summary_path, out_dir)
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
#> Saving adsl to /tmp/RtmpS9mnbx/syn_glimpse_out/syn_adsl.rds...
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
#> Saving adae to /tmp/RtmpS9mnbx/syn_glimpse_out/syn_adae.rds...
list.files(out_dir, pattern = "\\.rds$")
#> [1] "syn_adae.rds" "syn_adsl.rds"
```
