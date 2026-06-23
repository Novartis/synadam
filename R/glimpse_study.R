#' Glimpse all ADaM datasets for a study.
#'
#' Reads the YAML configuration used by [simulate_study()], runs the
#' appropriate `glimpse_*()` for each dataset, and saves the collected
#' summaries (plus seed and version metadata) to a single `.rds` file.
#'
#' The resulting study summary can later be passed to
#' [simulate_study_from_summary()] to generate the synthetic datasets,
#' decoupling the glimpse phase (which requires access to real `.sas7bdat`
#' files) from the simulate phase.
#'
#' @param config_path `character` - path to YAML configuration file. Has the
#'   same structure as the one consumed by [simulate_study()].
#' @param study_summary_path `character` - path to write the study summary
#'   `.rds` file. The parent directory will be created if it does not exist.
#'
#' @return `NULL` (invisibly). The study summary is a named list with elements
#'   `summaries` (named list of glimpse summary objects, keyed by dataset
#'   name from the YAML), `seed`, `synadam_version`, and `glimpsed_at`.
#'
#' @seealso [simulate_study_from_summary()], [simulate_study()].
#'
#' @templateVar adam_dir_name adam_dir
#' @templateVar datasets adsl
#' @template setup_adam_datasets
#' @examples
#' # Generate a config for the staged ADaM datasets.
#' yaml_path <- generate_study_config(
#'   adam_dir,
#'   output_dir = file.path(tempdir(), "syn_glimpse_out")
#' )
#'
#' # Glimpse phase: write the study summary (decoupled from the SAS files).
#' summary_path <- tempfile(fileext = ".rds")
#' glimpse_study(yaml_path, summary_path)
#'
#' # Simulate phase: generate synthetic datasets from the study summary.
#' out_dir <- file.path(tempdir(), "syn_glimpse_out")
#' simulate_study_from_summary(summary_path, out_dir)
#' list.files(out_dir, pattern = "\\.rds$")
#'
#' @export
glimpse_study <- function(config_path, study_summary_path) {
  checkmate::assert_character(config_path, len = 1)
  checkmate::assert_file_exists(config_path, extension = c("yaml", "yml"))
  checkmate::assert_character(study_summary_path, len = 1)

  config <- yaml::read_yaml(config_path)
  .validate_config(config)

  summaries <- .glimpse_study_summaries(config)

  parent_dir <- dirname(study_summary_path)
  if (!dir.exists(parent_dir)) {
    dir.create(parent_dir, recursive = TRUE)
  }

  study_summary <- list(
    summaries = summaries,
    seed = config[["seed"]],
    synadam_version = as.character(utils::packageVersion("synadam")),
    glimpsed_at = Sys.time()
  )

  message(glue::glue("Saving study summary to {study_summary_path}..."))
  saveRDS(study_summary, study_summary_path)

  invisible(NULL)
}

#' Build the per-dataset summary list for a study config.
#'
#' Walks the config in dataset-key order with ADSL first, runs the
#' appropriate glimpse function, and (for ADSL) simulates the synthetic
#' ADSL needed by downstream BDS / OCCDS / TTE glimpses.
#'
#' @param config `list` - parsed YAML config (already validated).
#'
#' @return Named list of summary objects keyed by dataset name.
#' @keywords internal
.glimpse_study_summaries <- function(config) {
  seed <- config[["seed"]]
  datasets <- config[["datasets"]]
  dataset_keys <- names(datasets)
  dataset_keys <- dataset_keys[order(dataset_keys != "adsl")]

  summaries <- list()
  syn_adsl <- NULL

  for (key in dataset_keys) {
    dataset_config <- datasets[[key]]
    dataset_type <- dataset_config[["dataset_type"]]

    message(glue::glue("----- Glimpsing {key} ({dataset_type}) dataset -----"))
    message(glue::glue("Loading dataset from {dataset_config[['path']]}"))

    flag_cols <- .as_character_or_default(
      dataset_config[["flag_cols"]]
    )
    visit_cols <- .as_character_or_default(
      dataset_config[["visit_cols"]]
    )
    censor_cols <- .as_character_or_default(
      dataset_config[["censor_cols"]]
    )
    ordered_col_sets <- if (length(dataset_config[["ordered_col_sets"]]) == 0) {
      list()
    } else {
      dataset_config[["ordered_col_sets"]]
    }

    summary <- switch(dataset_type,
      "adsl" = {
        adsl <- read_sas7bdat(dataset_config[["path"]])
        glimpse_adsl(
          adsl = adsl,
          id_cols = .as_character_or_default(
            dataset_config[["id_cols"]]
          ),
          treatment_cols = .as_character_or_default(
            dataset_config[["treatment_cols"]]
          ),
          flag_cols = flag_cols,
          ordered_col_sets = ordered_col_sets,
          seed = seed
        )
      },
      "bds" = {
        bds <- read_sas7bdat(dataset_config[["path"]])
        glimpse_bds(
          bds = bds,
          syn_adsl = syn_adsl,
          id_cols = .as_character_or_default(
            dataset_config[["id_cols"]]
          ),
          param_cols = .as_character_or_default(
            dataset_config[["param_cols"]]
          ),
          visit_cols = visit_cols,
          flag_cols = flag_cols,
          ordered_col_sets = ordered_col_sets,
          seed = seed
        )
      },
      "tte" = {
        tte <- read_sas7bdat(dataset_config[["path"]])
        glimpse_tte(
          tte = tte,
          syn_adsl = syn_adsl,
          param_cols = .as_character_or_default(
            dataset_config[["param_cols"]]
          ),
          censor_cols = censor_cols,
          flag_cols = flag_cols,
          ordered_col_sets = ordered_col_sets,
          seed = seed
        )
      },
      "occds" = {
        occds <- read_sas7bdat(dataset_config[["path"]])
        glimpse_occds(
          occds = occds,
          syn_adsl = syn_adsl,
          id_cols = .as_character_or_default(
            dataset_config[["id_cols"]]
          ),
          seq_col = dataset_config[["seq_col"]],
          flag_cols = flag_cols,
          ordered_col_sets = ordered_col_sets,
          seed = seed
        )
      }
    )

    summaries[[key]] <- summary

    # Simulate ADSL so downstream BDS/OCCDS/TTE glimpses can capture
    # synthetic IDs. simulate_study_from_summary() re-runs simulate_adsl
    # with the same seed, producing the same synthetic IDs.
    if (dataset_type == "adsl") {
      syn_adsl <- simulate_adsl(summary, seed = seed)
    }
  }

  summaries
}
