#' Simulate synthetic ADaM datasets for a study.
#'
#' Taking as input a yaml configuration that specifies the ADaM datasets
#' for a study of interest, this function will simulate synthetic versions of
#' each and save them as individual .rds files in a specified directory.
#'
#' @param config_path `character` - path to YAML configuration file.
#'
#' @return `NULL` (invisibly). Synthetic datasets are saved as individual
#'   `.rds` files named `syn_{key}.rds` in the `output_dir` directory, where
#'   `{key}` is the dataset name from the YAML config. Each dataset has a
#'   `synadam_version` attribute containing the package version.
#'
#' @details
#' The YAML configuration file should have the following structure:
#' ```yaml
#' output_dir: "/path/to/output_directory"
#' seed: 32
#'
#' datasets:
#'   adsl:
#'     dataset_type: "adsl"
#'     path: "/path/to/adsl.sas7bdat"
#'     id_cols: ["USUBJID", "SUBJID"]
#'     treatment_cols: ["TRT01A", "TRT01AN"]
#'     flag_cols: ["SAFFL", "ITTFL"]
#'     ordered_col_sets:
#'       - ["REGION1", "REGION1N"]
#'
#'   adlb:
#'     dataset_type: "bds"
#'     path: "/path/to/adlb.sas7bdat"
#'     id_cols: ["USUBJID"]
#'     param_cols: ["PARAM", "PARAMCD"]
#'     visit_cols: ["AVISIT", "AVISITN"]
#'     flag_cols: ["ANL01FL"]
#'
#'   adtte:
#'     dataset_type: "tte"
#'     path: "/path/to/adtte.sas7bdat"
#'     param_cols: ["PARAM", "PARAMCD"]
#'     censor_cols: ["CNSR", "EVNTDESC", "CNSDTDSC"]
#'     flag_cols: ["ANL01FL"]
#'     ordered_col_sets:
#'       - ["SRCDOM", "SRCVAR"]
#'
#'   adae:
#'     dataset_type: "occds"
#'     path: "/path/to/adae.sas7bdat"
#'     id_cols: ["USUBJID"]
#'     seq_col: "AESEQ"
#'     flag_cols: ["AOCCFL", "TRTEMFL"]
#'     ordered_col_sets:
#'       - ["AEBODSYS", "AEDECOD"]
#' ```
#'
#' Dataset names in the output files are determined by the YAML keys under
#' `datasets:` (e.g., `syn_adsl.rds`, `syn_adlb.rds`). Exactly one dataset
#' must have `dataset_type: "adsl"`. The `output_dir` directory will be
#' created automatically if it doesn't exist.
#'
#' @templateVar adam_dir_name adam_dir
#' @templateVar datasets adsl,adae
#' @template setup_adam_datasets
#' @examples
#'
#' out_dir <- file.path(tempdir(), "syn_study")
#' yaml_path <- generate_study_config(adam_dir, output_dir = out_dir)
#'
#' # Simulate the whole study; synthetic syn_*.rds files land in out_dir.
#' simulate_study(yaml_path)
#' list.files(out_dir, pattern = "\\.rds$")
#'
#' @export
simulate_study <- function(config_path) {
  checkmate::assert_character(config_path, len = 1)
  checkmate::assert_file_exists(config_path, extension = c("yaml", "yml"))

  config <- yaml::read_yaml(config_path)
  .validate_config(config)

  study_summary_path <- tempfile(fileext = ".rds")
  on.exit(unlink(study_summary_path), add = TRUE)
  glimpse_study(config_path, study_summary_path)

  simulate_study_from_summary(
    study_summary_path = study_summary_path,
    output_dir = config[["output_dir"]]
  )
}

#' Simulate synthetic ADaM datasets from a previously-saved study summary.
#'
#' Reads a study summary written by [glimpse_study()] and produces synthetic
#' datasets, decoupling simulation from the original `.sas7bdat` files.
#'
#' @param study_summary_path `character` - path to the `.rds` study summary
#'   written by [glimpse_study()].
#' @param output_dir `character` - directory to write `syn_{key}.rds` files
#'   to. Created if missing.
#' @param seed `integer` or `NULL` - simulation seed. When `NULL` (default), the
#'   seed stored in the study summary is used; if the study summary has no seed,
#'   it falls back to `123`. Override to draw a different synthetic replicate
#'   from the same summaries.
#'
#' @return `NULL` (invisibly). Synthetic datasets are saved as
#'   `syn_{key}.rds` files in `output_dir`. Each dataset has a
#'   `synadam_version` attribute.
#'
#' @seealso [glimpse_study()], [simulate_study()].
#'
#' @templateVar adam_dir_name adam_dir
#' @templateVar datasets adsl
#' @template setup_adam_datasets
#' @examples
#' # Generate a config and glimpse the datasets into a study summary.
#' yaml_path <- generate_study_config(
#'   adam_dir,
#'   output_dir = file.path(tempdir(), "syn_data")
#' )
#' study_summary_path <- tempfile(fileext = ".rds")
#' glimpse_study(yaml_path, study_summary_path)
#'
#' # Simulate synthetic datasets from the saved study summary.
#' out_dir <- file.path(tempdir(), "syn_data")
#' simulate_study_from_summary(study_summary_path, out_dir)
#' list.files(out_dir, pattern = "\\.rds$")
#'
#' @export
simulate_study_from_summary <- function(
    study_summary_path,
    output_dir,
    seed = NULL) {
  checkmate::assert_character(study_summary_path, len = 1)
  checkmate::assert_file_exists(study_summary_path, extension = "rds")
  checkmate::assert_character(output_dir, len = 1)

  study_summary <- readRDS(study_summary_path)
  .validate_study_summary(study_summary)

  if (is.null(seed)) {
    seed <- study_summary[["seed"]]
  }
  # Final fallback so simulation is reproducible even when the study summary
  # carries no seed (e.g. a hand-authored config that omits `seed:`).
  if (is.null(seed)) {
    seed <- 123
  }
  checkmate::assert_integerish(seed, len = 1, null.ok = TRUE)

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  summaries <- study_summary[["summaries"]]
  dataset_keys <- names(summaries)
  # Ensure ADSL is simulated first so BDS/OCCDS/TTE summaries (which embed
  # synthetic ADSL columns) align with the freshly simulated ADSL.
  adsl_key <- .find_adsl_key(summaries)
  dataset_keys <- c(adsl_key, setdiff(dataset_keys, adsl_key))

  synadam_version <- as.character(utils::packageVersion("synadam"))

  for (key in dataset_keys) {
    summary <- summaries[[key]]
    message(glue::glue("----- Simulating {key} -----"))

    syn_data <- .simulate_from_summary(summary, seed = seed)

    attr(syn_data, "synadam_version") <- synadam_version
    output_path <- file.path(output_dir, glue::glue("syn_{key}.rds"))
    message(glue::glue("Saving {key} to {output_path}..."))
    saveRDS(syn_data, output_path)
  }

  invisible(NULL)
}

#' Dispatch a single summary to its corresponding simulate_* function.
#'
#' @param summary classed summary object (`summary_adsl` / `summary_bds` /
#'   `summary_tte` / `summary_occds`).
#' @param seed `integer` or `NULL` - simulation seed.
#'
#' @return `data.frame` of synthetic data.
#' @keywords internal
.simulate_from_summary <- function(summary, seed) {
  if (inherits(summary, "summary_adsl")) {
    return(simulate_adsl(summary, seed = seed))
  }
  if (inherits(summary, "summary_bds")) {
    return(simulate_bds(summary, seed = seed))
  }
  if (inherits(summary, "summary_tte")) {
    return(simulate_tte(summary, seed = seed))
  }
  if (inherits(summary, "summary_occds")) {
    return(simulate_occds(summary, seed = seed))
  }
  stop(glue::glue(
    "Unsupported summary class: {paste(class(summary), collapse = '/')}"
  ))
}

#' Find the ADSL key in a summaries list.
#'
#' @param summaries named list of classed summary objects.
#'
#' @return `character(1)` - the name of the entry whose summary inherits
#'   from `summary_adsl`. Errors if absent or duplicated.
#' @keywords internal
.find_adsl_key <- function(summaries) {
  is_adsl <- vapply(
    summaries, inherits, logical(1),
    what = "summary_adsl"
  )
  checkmate::assert_true(
    sum(is_adsl) == 1,
    .var.name = "Study summary must contain exactly one summary_adsl entry"
  )
  names(summaries)[which(is_adsl)]
}

#' Validate the structure of a study summary.
#'
#' @param study_summary `list` - object read from a glimpse_study() rds.
#'
#' @return None. Throws on malformed input.
#' @keywords internal
.validate_study_summary <- function(study_summary) {
  checkmate::assert_list(study_summary)
  required <- c("summaries", "seed", "synadam_version", "glimpsed_at")
  .assert_subset(required, names(study_summary), "study summary")
  checkmate::assert_list(
    study_summary[["summaries"]],
    min.len = 1,
    names = "named"
  )

  summary_version <- study_summary[["synadam_version"]]
  current_version <- as.character(utils::packageVersion("synadam"))
  if (!identical(summary_version, current_version)) {
    warning(glue::glue(
      "Study summary was produced under synadam {summary_version} but the ",
      "loaded package is {current_version}. Simulation may behave ",
      "unexpectedly."
    ))
  }
}

#' Coerce a YAML-derived list field to a character vector.
#'
#' Treats any length-0 input (NULL, list(), character()) as the default;
#' otherwise unlist to a character vector.
#'
#' @param x `list`/`character`/`NULL` - YAML field value.
#' @param default `character` - value to return when `x` is empty.
#'
#' @return `character` vector.
#' @keywords internal
.as_character_or_default <- function(x, default = character()) {
  if (length(x) == 0) {
    return(default)
  }
  return(unlist(x, use.names = FALSE))
}

#' Validate YAML configuration structure.
#'
#' @param config `list` - parsed YAML configuration.
#'
#' @return None. Throws error if validation fails.
#' @keywords internal
.validate_config <- function(config) {
  checkmate::assert_list(config)

  .assert_subset(
    c("output_dir", "datasets"),
    names(config),
    "config"
  )
  checkmate::assert_character(config[["output_dir"]], len = 1)
  checkmate::assert_list(config[["datasets"]], min.len = 1)

  # Get dataset entries
  datasets <- config[["datasets"]]
  dataset_keys <- names(datasets)

  # Count datasets by type and validate fields
  adsl_count <- 0

  for (key in dataset_keys) {
    dataset_config <- datasets[[key]]
    checkmate::assert_list(
      dataset_config,
      .var.name = glue::glue("Dataset '{key}'")
    )

    checkmate::assert(
      "dataset_type" %in% names(dataset_config),
      .var.name = glue::glue("'{key}' must contain 'dataset_type' field")
    )

    dataset_type <- dataset_config[["dataset_type"]]
    checkmate::assert(
      dataset_type %in% c("adsl", "bds", "tte", "occds"),
      .var.name = glue::glue(
        "'{key}' has invalid dataset_type: '{dataset_type}'. ",
        "Must be 'adsl', 'bds', 'tte', or 'occds'"
      )
    )

    switch(dataset_type,
      "adsl" = {
        required_fields <- c(
          "path", "id_cols", "treatment_cols"
        )
        .assert_subset(
          required_fields,
          names(dataset_config),
          glue::glue("ADSL dataset '{key}'"),
          col_type = "field"
        )
      },
      "bds" = {
        required_fields <- c(
          "path", "id_cols", "param_cols"
        )
        .assert_subset(
          required_fields,
          names(dataset_config),
          glue::glue("BDS dataset '{key}'"),
          col_type = "field"
        )
      },
      "tte" = {
        required_fields <- c(
          "path", "param_cols"
        )
        .assert_subset(
          required_fields,
          names(dataset_config),
          glue::glue("TTE dataset '{key}'"),
          col_type = "field"
        )
      },
      "occds" = {
        required_fields <- c(
          "path", "id_cols", "seq_col"
        )
        .assert_subset(
          required_fields,
          names(dataset_config),
          glue::glue("OCCDS dataset '{key}'"),
          col_type = "field"
        )
      }
    )

    # Increment ADSL count
    if (dataset_type == "adsl") {
      adsl_count <- adsl_count + 1
    }
  }

  # Ensure there is exactly 1 ADSL
  checkmate::assert(
    adsl_count == 1,
    .var.name = glue::glue(
      "Config must contain exactly one dataset with dataset_type = 'adsl')"
    )
  )

  # Now validate file paths (after structural validation)
  for (key in dataset_keys) {
    checkmate::assert_file_exists(
      datasets[[key]][["path"]],
      .var.name = glue::glue("Path given for dataset '{key}' does not exist")
    )
  }
}
