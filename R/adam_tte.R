#' Glimpse a TTE dataset.
#'
#' Summarizes a TTE (Time-to-Event) dataset for synthetic simulation by
#' extracting parameter combinations, preserving censoring column relationships,
#' and extracting summaries of all other variables.
#'
#' @param tte `data.frame` - input TTE dataset e.g. ADTTE.
#' @param syn_adsl `data.frame` - synthetic ADSL to obtain subject-level data
#'   from. Should be created by [simulate_adsl()].
#' @param param_cols `character` - parameter columns e.g. c("PARAM", "PARAMCD").
#' @param censor_cols `character` - censoring columns e.g.
#'   c("CNSR", "EVNTDESC", "CNSDTDSC"). These columns are treated as an ordered
#'   set to preserve co-occurrence patterns. Only needed when multiple censor
#'   columns should be kept together. Default is an empty character vector
#'   (censor columns are treated as regular columns).
#' @param flag_cols `character` - flag columns that will be sampled as Y/N in
#'   proportion to input e.g. c("ANL01FL"). Default is an empty character vector
#'   (no flag columns).
#'
#' @inheritParams glimpse_adsl
#'
#' @return `summary_tte` - summary object for TTE simulation.
#'
#' @examples
#' # TTE simulation needs a synthetic ADSL to provide the subject spine.
#' syn_adsl <- data.frame(
#'   USUBJID = as.character(1:5),
#'   TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
#'   TRT01AN = c(1, 1, 2, 2, 2)
#' )
#' tte <- data.frame(
#'   USUBJID = as.character(rep(1:3, each = 2)),
#'   PARAM = rep(c("Overall Survival", "Progression Free Survival"), 3),
#'   PARAMCD = rep(c("OS", "PFS"), 3),
#'   CNSR = c(0, 1, 0, 1, 1, 0),
#'   EVNTDESC = c(
#'     "DEATH", "COMPLETED", "DEATH", "COMPLETED", "COMPLETED", "PROGRESSION"
#'   ),
#'   AVAL = c(365, 500, 180, 250, 600, 120)
#' )
#'
#' tte_summary <- glimpse_tte(
#'   tte,
#'   syn_adsl,
#'   param_cols = c("PARAM", "PARAMCD"),
#'   censor_cols = c("CNSR", "EVNTDESC")
#' )
#' syn_tte <- simulate_tte(tte_summary, seed = 42)
#' head(syn_tte)
#'
#' @export
glimpse_tte <- function(
    tte,
    syn_adsl,
    param_cols,
    censor_cols = character(),
    flag_cols = character(),
    ordered_col_sets = list(),
    seed = NULL) {
  .validate_input_glimpse_tte(
    tte,
    syn_adsl,
    param_cols,
    censor_cols,
    flag_cols,
    ordered_col_sets
  )
  cols_to_summarise <- colnames(tte)
  tte_summary <- list()

  # Glimpse param columns (all PARAMCDs, no filtering)
  message("Glimpsing PARAM columns")
  tte_summary[["params"]] <- glimpse_params(tte[param_cols])
  cols_to_summarise <- setdiff(cols_to_summarise, param_cols)

  # Obtain subject-level data from the synthetic ADSL
  message("Glimpsing ADSL columns from synthetic ADSL")
  shared_cols <- intersect(colnames(tte), colnames(syn_adsl))
  tte_summary[["adsl_cols"]] <- syn_adsl[shared_cols]
  cols_to_summarise <- setdiff(cols_to_summarise, shared_cols)

  # Glimpse censor columns as an ordered set (if multiple provided)
  if (length(censor_cols) > 0) {
    message(
      glue::glue(
        "Glimpsing censor column(s): {paste(censor_cols, collapse = ', ')}"
      )
    )
    tte_summary[["censor"]] <- glimpse_ordered(tte[censor_cols])
    cols_to_summarise <- setdiff(cols_to_summarise, censor_cols)
  }

  # Glimpse ordered columns
  for (col_set in ordered_col_sets) {
    message(
      glue::glue("Glimpsing column(s): {paste(col_set, collapse = ', ')}")
    )
    tte_summary[[paste(col_set, collapse = "_")]] <- glimpse_ordered(
      tte[col_set]
    )
    cols_to_summarise <- setdiff(cols_to_summarise, col_set)
  }

  # Glimpse each remaining column
  for (col in cols_to_summarise) {
    message(glue::glue("Glimpsing column(s): {col}"))
    tte_summary[[col]] <- if (col %in% flag_cols) {
      glimpse_flag(tte[[col]], col)
    } else {
      glimpse(tte[[col]], col, na_mode = "none", seed = seed)
    }
  }

  attr(tte_summary, "col_order") <- colnames(tte)
  tte_summary <- .add_summary_class(tte_summary, "tte")

  return(tte_summary)
}

#' Simulate a synthetic TTE dataset.
#'
#' Generates synthetic TTE data by creating a spine from parameter
#' combinations and ADSL subject records, then populating remaining columns,
#' preserving the original data structure. Produces exactly one record per
#' subject per parameter (the defining TTE constraint).
#'
#' @inheritParams simulate
#'
#' @param tte_summary `summary_tte` - summary object created by [glimpse_tte()].
#'
#' @return `data.frame` - synthetic TTE dataset.
#'
#' @examples
#' syn_adsl <- data.frame(
#'   USUBJID = as.character(1:5),
#'   TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
#'   TRT01AN = c(1, 1, 2, 2, 2)
#' )
#' tte <- data.frame(
#'   USUBJID = as.character(rep(1:3, each = 2)),
#'   PARAM = rep(c("Overall Survival", "Progression Free Survival"), 3),
#'   PARAMCD = rep(c("OS", "PFS"), 3),
#'   CNSR = c(0, 1, 0, 1, 1, 0),
#'   AVAL = c(365, 500, 180, 250, 600, 120)
#' )
#'
#' tte_summary <- glimpse_tte(
#'   tte,
#'   syn_adsl,
#'   param_cols = c("PARAM", "PARAMCD")
#' )
#' syn_tte <- simulate_tte(tte_summary, seed = 42)
#' head(syn_tte)
#'
#' @export
simulate_tte <- function(tte_summary, seed = NULL) {
  checkmate::assert_class(tte_summary, "summary_tte")

  # The ADSL subject levels and param cols form the "spine" of a TTE
  # (one row per subject per parameter)
  message("Simulating PARAM and ADSL columns")
  tte_spine <- tidyr::expand_grid(
    tte_summary[["params"]][["unique_params"]],
    tte_summary[["adsl_cols"]]
  )

  # Simulate the remaining cols
  tte_summary_remaining <- tte_summary[
    !(names(tte_summary) %in% c("params", "adsl_cols"))
  ]

  syn_tte <- vector("list", length = length(tte_summary_remaining))
  for (i in seq_along(tte_summary_remaining)) {
    message(
      glue::glue(
        "Simulating column(s): ",
        "{.format_columns(names(tte_summary_remaining)[i])}"
      )
    )
    syn_tte[[i]] <- simulate(
      tte_summary_remaining[[i]],
      output_length = nrow(tte_spine),
      seed = seed
    )
  }
  syn_tte <- syn_tte |> dplyr::bind_cols(tte_spine)

  # Match order of output columns to input TTE
  syn_tte <- dplyr::select(
    syn_tte,
    dplyr::all_of(attr(tte_summary, "col_order"))
  )

  return(syn_tte)
}

#' Validate input arguments for `glimpse_tte()`.
#'
#' @inheritParams glimpse_tte
#'
#' @return None.
#' @keywords internal
.validate_input_glimpse_tte <- function(
    tte,
    syn_adsl,
    param_cols,
    censor_cols,
    flag_cols,
    ordered_col_sets) {
  checkmate::assert_data_frame(tte)
  checkmate::assert_data_frame(syn_adsl)
  checkmate::assert_character(
    param_cols,
    min.len = 1,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_character(
    censor_cols,
    min.len = 0,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_character(
    flag_cols,
    min.len = 0,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_list(
    ordered_col_sets,
    types = "character",
    min.len = 0
  )

  # Check all special columns are unique
  special_cols <- c(
    param_cols,
    censor_cols,
    flag_cols,
    unlist(ordered_col_sets)
  )
  checkmate::assert_character(special_cols, unique = TRUE)

  # Check all provided columns exist in tte
  .assert_subset(
    c(param_cols, censor_cols, flag_cols, unlist(ordered_col_sets)),
    colnames(tte),
    "tte"
  )

  # Check tte and syn_adsl share columns
  checkmate::assert_true(sum(colnames(tte) %in% colnames(syn_adsl)) > 0)

  # Any subject-ID column in the TTE data must come from syn_adsl (synthetic),
  # never be value-sampled from the real TTE data.
  id_like <- intersect(c("USUBJID", "SUBJID"), colnames(tte))
  .assert_subset(id_like, colnames(syn_adsl), "syn_adsl", col_type = "ID")

  # Check PARAMCD col is found in param_cols
  checkmate::assert_true(
    "PARAMCD" %in% param_cols,
    .var.name = "PARAMCD must be included in param_cols"
  )
}
