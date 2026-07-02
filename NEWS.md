# synadam 0.3.1

## Infrastructure

- Add a pkgdown GitHub Actions workflow (`.github/workflows/pkgdown.yaml`) that builds the documentation site and deploys it to the `gh-pages` branch, and set the site `url` in `_pkgdown.yml`.
- Add an R-hub v2 GitHub Actions workflow (`.github/workflows/rhub.yaml`) for multi-platform CRAN checks, dispatched via `rhub::rhub_check()`.

# synadam 0.3.0

## Summary

- Split the study workflow into a glimpse phase and a simulate phase: add `glimpse_study()` and `simulate_study_from_summary()`, allowing the glimpse (which needs the real `.sas7bdat` files) to run independently from simulation.
- Fall back to a default seed of 123 when a seed is not set in the study config, and make the seed argument optional in `generate_study_config()` (also defaulting to 123).
- Add `.assert_required_id_cols()` to safeguard against ID leakage. It now errors if `USUBJID`/`SUBJID` are present in the data but missing from `id_cols`, ensuring subject IDs are regenerated synthetically rather than value-sampled from real data.
- Refactor `generate_study_config()` to take a required `output_dir` (with an optional `config_yaml_name`), writing the config into that directory alongside where synthetic data will be saved.
- Drop the `synadam::`/`synadam:::` syntax to avoid the CRAN self-`:::` NOTE.
- Add runnable roxygen `@examples` across the exported `glimpse_*`/`simulate_*` functions. Introduce a shared `man-roxygen/setup_adam_datasets.R` template that stages bundled fixtures.
- Relocate the MIT license text to `LICENSE.md` and switch `LICENSE` to the `YEAR`/`COPYRIGHT HOLDER` format, raise the minimum R version to 4.1.0 (native pipe), and extend `.Rbuildignore`.

# synadam 0.2.0

## New features

- Keep all PARAMCDs in BDS simulation instead of requiring a `paramcd_filter` argument.
- Simulate flag columns based on the proportion of "Y"/"N" values rather than preserving exact positions.

# synadam 0.1.0

- Initial release.
