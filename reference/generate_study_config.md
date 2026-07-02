# Generate a draft study config YAML from a directory of ADaM files.

Scans a directory of `.sas7bdat` files, infers `dataset_type` and
per-dataset glimpse arguments using CDISC filename and column-name
conventions, and writes a draft YAML config suitable for
[`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md).
Inferred fields are tagged with inline `# REVIEW` comments where the
signal is weak so users know what to verify before running the
simulation.

## Usage

``` r
generate_study_config(
  adam_dir,
  output_dir,
  config_yaml_name = "synadam_config.yaml",
  seed = 123
)
```

## Arguments

- adam_dir:

  `character(1)` - directory containing `.sas7bdat` files.

- output_dir:

  `character(1)` - directory that both the generated config YAML and the
  synthetic `.rds` outputs are written to. Created recursively if it
  does not exist. This same path is recorded as the top-level
  `output_dir` field in the YAML, so
  [`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md)
  writes its `syn_*.rds` files alongside the config.

- config_yaml_name:

  `character(1)` - filename for the generated config within
  `output_dir`. Defaults to `"synadam_config.yaml"`. If the file already
  exists, it is silently overwritten.

- seed:

  `integer(1)` / `numeric(1)` or `NULL` - value to write for the
  top-level `seed` field in the YAML. Defaults to `123`. If `NULL`, a
  `"REVIEW: ..."` placeholder is written instead.

## Value

`character(1)` - the path the YAML was written to
(`file.path(output_dir, config_yaml_name)`).

## Details

Only files whose basename matches `ad*.sas7bdat` (case-insensitive) are
considered. Any other files in `adam_dir` are skipped with a single
warning listing them.

## Detection rules

Filename match (case-insensitive, basename without extension):

- starts with `adsl` -\> `adsl`

- starts with `adae`/`adcm`/`admh`/`addv` -\> `occds`

- starts with `adtte` -\> `tte`

- any other name (including `ad*`) -\> fall through to column inspection

Column inspection rules (checked in order; `USUBJID` is required in
every ADaM dataset, so it is not used as a discriminator). ADSL is
classified from the filename only - any non-`adsl*` file that lacks
BDS/TTE/OCCDS column signatures falls through to `"REVIEW"`:

- has `PARAM` -\> `bds` (checked before CNSR so oncology hybrid datasets
  like ADRECIST that carry TTE-derived parameters inline classify as the
  longitudinal BDS they actually are)

- has `CNSR` -\> `tte` (CNSR is the only structurally required TTE
  variable in ADaM; `EVNTDESC` is conventional but not universal)

- has any `*SEQ` column -\> `occds`

- otherwise -\> `"REVIEW"` placeholder + warning

Errors if no ADSL file is detected;
[`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md)
requires exactly one. If multiple ADSL candidates are detected, a file
named exactly `adsl.sas7bdat` (case-insensitive) is preferred; otherwise
the alphabetically-first candidate is used. The picked file is kept and
the rest are dropped with a warning.

## Column-role detection

Within a classified dataset, the column-role inference picks up:

- `id_cols`: `USUBJID` and `SUBJID` when present.

- `treatment_cols` (ADSL): `ACTARM`, `ACTARMCD`, `ARM`, `ARMCD`,
  `TRTSEQP`, `TRTSEQA` and any
  `TRT##A`/`TRT##AN`/`TRT##AL`/`TRT##P`/`TRT##PN`/`TRT##PL` matches,
  plus `TRT##(A|P)GR\d*` and `TRT##(A|P)GR\d*N` group variants.

- `visit_cols` (BDS): `AVISIT`, `AVISITN`, `VISIT`, `VISITNUM`, `ATPT`,
  `ATPTN` when present.

- `param_cols` (BDS, TTE): `PARAM`, `PARAMCD`, and any `PARCAT*`
  columns.

- `seq_col` (OCCDS): the first known domain-coded `*SEQ` column
  (`AESEQ`, `CMSEQ`, `MHSEQ`, `PRSEQ`, `EXSEQ`, `DSSEQ`); falls back to
  the first `*SEQ` column if none of those are present.

- `censor_cols` (TTE): `CNSR`, `EVNTDESC`, `CNSDTDSC` - only emitted
  when two or more of these are detected. A single `CNSR` flows through
  as a regular column and `censor_cols` is omitted.

- `ordered_col_sets`: X/XN/XL groups where two or three variants of a
  base column name co-exist.

## What is NOT auto-inferred

Some config decisions are opinionated and intended to be pruned or
extended by the user after generation:

- `flag_cols` emits every `*FL` column found. The user is expected to
  trim this list down to the flags they want to preserve.

- Non-FL flag-like indicators (e.g. `AESER`) are not detected.

- Ordered column sets that share semantics but not naming (e.g.
  `AEBODSYS`/`AEDECOD`) are not auto-paired; add them by hand.

- For BDS and TTE datasets `param_cols` auto-includes `PARAM`,
  `PARAMCD`, and any `PARCAT*` columns present, but NOT `PARAMTYP` or
  `PARAMN`; add these manually if relevant.

- For BDS, OCCDS, and TTE datasets `ordered_col_sets` excludes any
  column also present in the chosen ADSL. ADSL-shared columns are pulled
  in via the ADSL spine at simulation time, so listing them here would
  duplicate the column.

## Examples

``` r

yaml_path <- generate_study_config(
  adam_dir,
  output_dir = file.path(tempdir(), "syn_out")
)
yaml_path
#> [1] "/tmp/RtmpzuRk4P/syn_out/synadam_config.yaml"
```
