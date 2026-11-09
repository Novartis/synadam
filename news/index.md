# Changelog

## synadam 0.6.0

### New features

- **Parquet input.** ADaM datasets can now be read from `.parquet` files
  as well as `.sas7bdat` files. The new
  [`read_adam()`](https://novartis.github.io/synadam/reference/read_adam.md)
  picks the reader from the file extension and converts blank strings to
  `NA` for both.
  [`glimpse_study()`](https://novartis.github.io/synadam/reference/glimpse_study.md)
  and
  [`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md)
  use it, so a config `path` can point to either format, and
  [`generate_study_config()`](https://novartis.github.io/synadam/reference/generate_study_config.md)
  now also picks up `ad*.parquet` files. `arrow` is a new dependency.

## synadam 0.5.0

### New features

- **Per-PARAMCD stratified BDS simulation.**
  [`glimpse_bds()`](https://novartis.github.io/synadam/reference/glimpse_bds.md)/[`simulate_bds()`](https://novartis.github.io/synadam/reference/simulate_bds.md)
  now simulate the CDISC value columns conditional on `PARAMCD` rather
  than pooling them across all parameters. Stratification is applied
  automatically to `AVAL`, `AVALC`, toxicity grades (`*TOXGR`/`*TOXGRN`)
  and value categories (`AVALCATn`/`AVALCAnN`); columns named in
  `flag_cols` are never stratified. Previously every value column was
  drawn from one global distribution, so a parameter’s scale and
  codelist were lost (e.g. a relative-dose-intensity percentage blended
  with a cumulative dose in mg, and per-parameter category schemes
  leaked across parameters). A missing (`NA`) `PARAMCD` is treated as a
  stratum in its own right. Stratification applies to BDS only;
  [`glimpse_tte()`](https://novartis.github.io/synadam/reference/glimpse_tte.md)
  is unchanged.

- **New `summary_stratified` class.**
  [`glimpse_bds()`](https://novartis.github.io/synadam/reference/glimpse_bds.md)
  stores one child summary per stratum in a `summary_stratified` object,
  with a matching
  [`simulate()`](https://novartis.github.io/synadam/reference/simulate.md)
  method that draws each row from its own stratum’s summary.

## synadam 0.3.4

### Documentation

- Add CRAN installation instructions to the README
  (`install.packages("synadam")`), keeping the GitHub install as the
  development version.
- Add a documentation badge and link to the pkgdown site
  (<https://opensource.nibr.com/synadam/>) in the README.

## synadam 0.3.3

CRAN release: 2026-07-22

### Infrastructure

- Add pre-commit hooks for repository hygiene: `check-added-large-files`
  (2 MB cap, `--enforce-all`) and `detect-private-key` from
  `pre-commit/pre-commit-hooks` (v6.0.0), and `codespell` (v2.4.2) for
  spell-checking. `codespell` runs with `--write-changes` and an
  `--ignore-words-list` for domain terms (`acn`, `ths`); `renv.lock` and
  `release_github.sh` are excluded to avoid false positives on generated
  content and shell identifiers.
- Fix two spelling typos surfaced by `codespell`, in `NEWS.md` and a
  comment in `R/glimpse_utils.R`.

## synadam 0.3.2

### Bug fixes

- Fix
  [`generate_study_config()`](https://novartis.github.io/synadam/reference/generate_study_config.md)
  writing unparsable YAML on Windows. Paths were emitted as
  double-quoted scalars, so backslash sequences in Windows paths
  (e.g. `C:\Users\...`) were interpreted as YAML escapes and
  [`simulate_study()`](https://novartis.github.io/synadam/reference/simulate_study.md)
  failed to read the config. Paths are now single-quoted, which passes
  backslashes through verbatim.

## synadam 0.3.1

### Infrastructure

- Add a pkgdown GitHub Actions workflow
  (`.github/workflows/pkgdown.yaml`) that builds the documentation site
  and deploys it to the `gh-pages` branch, and set the site `url` in
  `_pkgdown.yml`.
- Add an R-hub v2 GitHub Actions workflow
  (`.github/workflows/rhub.yaml`) for multi-platform CRAN checks,
  dispatched via `rhub::rhub_check()`.

## synadam 0.3.0

### Summary

- Split the study workflow into a glimpse phase and a simulate phase:
  add
  [`glimpse_study()`](https://novartis.github.io/synadam/reference/glimpse_study.md)
  and
  [`simulate_study_from_summary()`](https://novartis.github.io/synadam/reference/simulate_study_from_summary.md),
  allowing the glimpse (which needs the real `.sas7bdat` files) to run
  independently from simulation.
- Fall back to a default seed of 123 when a seed is not set in the study
  config, and make the seed argument optional in
  [`generate_study_config()`](https://novartis.github.io/synadam/reference/generate_study_config.md)
  (also defaulting to 123).
- Add
  [`.assert_required_id_cols()`](https://novartis.github.io/synadam/reference/dot-assert_required_id_cols.md)
  to safeguard against ID leakage. It now errors if `USUBJID`/`SUBJID`
  are present in the data but missing from `id_cols`, ensuring subject
  IDs are regenerated synthetically rather than value-sampled from real
  data.
- Refactor
  [`generate_study_config()`](https://novartis.github.io/synadam/reference/generate_study_config.md)
  to take a required `output_dir` (with an optional `config_yaml_name`),
  writing the config into that directory alongside where synthetic data
  will be saved.
- Drop the `synadam::`/`synadam:::` syntax to avoid the CRAN self-`:::`
  NOTE.
- Add runnable roxygen `@examples` across the exported
  `glimpse_*`/`simulate_*` functions. Introduce a shared
  `man-roxygen/setup_adam_datasets.R` template that stages bundled
  fixtures.
- Relocate the MIT license text to `LICENSE.md` and switch `LICENSE` to
  the `YEAR`/`COPYRIGHT HOLDER` format, raise the minimum R version to
  4.1.0 (native pipe), and extend `.Rbuildignore`.

## synadam 0.2.0

### New features

- Keep all PARAMCDs in BDS simulation instead of requiring a
  `paramcd_filter` argument.
- Simulate flag columns based on the proportion of “Y”/“N” values rather
  than preserving exact positions.

## synadam 0.1.0

- Initial release.
