# Simulate synthetic ADaM datasets for a study.

Taking as input a yaml configuration that specifies the ADaM datasets
for a study of interest, this function will simulate synthetic versions
of each and save them as individual .rds files in a specified directory.

## Usage

``` r
simulate_study(config_path)
```

## Arguments

- config_path:

  `character` - path to YAML configuration file.

## Value

`NULL` (invisibly). Synthetic datasets are saved as individual `.rds`
files named `syn_{key}.rds` in the `output_dir` directory, where `{key}`
is the dataset name from the YAML config. Each dataset has a
`synadam_version` attribute containing the package version.

## Details

The YAML configuration file should have the following structure:

    output_dir: "/path/to/output_directory"
    seed: 32

    datasets:
      adsl:
        dataset_type: "adsl"
        path: "/path/to/adsl.sas7bdat"
        id_cols: ["USUBJID", "SUBJID"]
        treatment_cols: ["TRT01A", "TRT01AN"]
        flag_cols: ["SAFFL", "ITTFL"]
        ordered_col_sets:
          - ["REGION1", "REGION1N"]

      adlb:
        dataset_type: "bds"
        path: "/path/to/adlb.sas7bdat"
        id_cols: ["USUBJID"]
        param_cols: ["PARAM", "PARAMCD"]
        visit_cols: ["AVISIT", "AVISITN"]
        flag_cols: ["ANL01FL"]

      adtte:
        dataset_type: "tte"
        path: "/path/to/adtte.sas7bdat"
        param_cols: ["PARAM", "PARAMCD"]
        censor_cols: ["CNSR", "EVNTDESC", "CNSDTDSC"]
        flag_cols: ["ANL01FL"]
        ordered_col_sets:
          - ["SRCDOM", "SRCVAR"]

      adae:
        dataset_type: "occds"
        path: "/path/to/adae.sas7bdat"
        id_cols: ["USUBJID"]
        seq_col: "AESEQ"
        flag_cols: ["AOCCFL", "TRTEMFL"]
        ordered_col_sets:
          - ["AEBODSYS", "AEDECOD"]

Dataset names in the output files are determined by the YAML keys under
`datasets:` (e.g., `syn_adsl.rds`, `syn_adlb.rds`). Exactly one dataset
must have `dataset_type: "adsl"`. The `output_dir` directory will be
created automatically if it doesn't exist.

## Examples

``` r

out_dir <- file.path(tempdir(), "syn_study")
yaml_path <- generate_study_config(adam_dir, output_dir = out_dir)

# Simulate the whole study; synthetic syn_*.rds files land in out_dir.
simulate_study(yaml_path)
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
#> Saving study summary to /tmp/RtmpS9mnbx/file468365dd7fb1.rds...
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
#> Saving adsl to /tmp/RtmpS9mnbx/syn_study/syn_adsl.rds...
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
#> Saving adae to /tmp/RtmpS9mnbx/syn_study/syn_adae.rds...
list.files(out_dir, pattern = "\\.rds$")
#> [1] "syn_adae.rds" "syn_adsl.rds"
```
