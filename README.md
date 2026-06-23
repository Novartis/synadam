# synadam

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Generate synthetic ADaM (Analysis Data Model) datasets from real clinical trial data.
`synadam` preserves the structure of real ADaM datasets (column names, relationships,
ranges) while removing identifiable patient information — enabling development and
testing of analysis pipelines without access to real data.

## Key Features

- **Privacy-preserving**: Synthetic data maintains structure without exposing identifiable patient information.
- **Multiple dataset types**: Supports ADSL, BDS (e.g. ADLB), OCCDS (e.g. ADAE), and TTE (e.g. ADTTE).
- **Auto-configuration**: `generate_study_config()` scans your ADaM directory and infers dataset types and column roles automatically.
- **Reproducible**: Deterministic output via random seeds.

## Installation

Install from GitHub:

```r
# install.packages("remotes")
remotes::install_github("Novartis/synadam")
```

## Quick Start

```r
library(synadam)

# 1. Auto-generate a YAML config from your ADaM directory. The config is
#    written into output_dir, alongside where the synthetic data will land.
yaml_path <- generate_study_config(
 adam_dir   = "/path/to/adam_data/",
 output_dir = "./syn_data",
 seed       = 42
)

# 2. Review the generated YAML, then simulate
simulate_study(yaml_path)
```

Synthetic datasets are saved as individual `.rds` files (e.g., `syn_adsl.rds`,
`syn_adlb.rds`) in the output directory.

## Documentation

For a full walkthrough including manual configuration and per-dataset control:

```r
vignette("synadam", package = "synadam")
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on
[GitHub](https://github.com/Novartis/synadam).

## License

This package is licensed under the MIT License. See [LICENSE](LICENSE) for details.