#' Glimpse a BDS dataset.
#'
#' Summarizes a BDS (Basic Data Structure) e.g. ADLB, ADVS dataset for synthetic
#' simulation by extracting per-subject parameter/visit profiles, preserving
#' relationships with ADSL columns, and extracting summaries of all other
#' variables. All PARAMCDs in the dataset are included.
#'
#' @param bds `data.frame` - input BDS dataset e.g. ADLB.
#' @param id_cols `character` - ID column names that identify subjects e.g.
#'   c("USUBJID"). These columns must exist in `syn_adsl` and will be taken
#'   from there (never simulated).
#' @param visit_cols `character` - visit columns e.g. c("AVISIT", "AVISITN").
#'   Default is an empty character vector (no visit columns).
#'
#' @inheritParams glimpse_tte
#' @inheritParams glimpse_adsl
#'
#' @return `summary_bds` - summary object for BDS simulation.
#'
#' @examples
#' \dontshow{
#' # Load bundled ADSL/ADLB fixtures so the example can run.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' adlb <- read.csv(
#'   system.file("extdata", "adlb.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#'
#' # BDS simulation needs a synthetic ADSL first to provide the subject spine.
#' syn_adsl <- simulate_adsl(glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN")
#' ))
#'
#' bds_summary <- glimpse_bds(
#'   adlb,
#'   syn_adsl,
#'   id_cols = "USUBJID",
#'   param_cols = c("PARAM", "PARAMCD"),
#'   visit_cols = c("AVISIT", "AVISITN"),
#'   flag_cols = "ANL01FL"
#' )
#' syn_adlb <- simulate_bds(bds_summary, seed = 42)
#' head(syn_adlb)
#'
#' @export
glimpse_bds <- function(
    bds,
    syn_adsl,
    id_cols,
    param_cols,
    visit_cols = character(),
    flag_cols = character(),
    ordered_col_sets = list(),
    seed = NULL) {
  .validate_input_glimpse_bds(
    bds,
    syn_adsl,
    id_cols,
    param_cols,
    visit_cols,
    flag_cols,
    ordered_col_sets
  )
  cols_to_summarise <- colnames(bds)
  bds_summary <- list()

  # Glimpse param and visit columns with per-subject profiles
  message("Glimpsing PARAM/VISIT columns")
  param_visit_cols <- c(param_cols, visit_cols)
  bds_summary[["param_visits"]] <- glimpse_param_visits(
    bds[c(id_cols, param_visit_cols)],
    id_cols,
    param_visit_cols
  )
  cols_to_summarise <- setdiff(cols_to_summarise, param_visit_cols)

  # Obtain subject-level data from the synthetic ADSL
  message("Glimpsing ADSL columns from synthetic ADSL")
  shared_cols <- intersect(colnames(bds), colnames(syn_adsl))
  bds_summary[["adsl_cols"]] <- syn_adsl[shared_cols]
  cols_to_summarise <- setdiff(cols_to_summarise, shared_cols)

  # Glimpse ordered columns
  for (col_set in ordered_col_sets) {
    message(
      glue::glue("Glimpsing column(s): {paste(col_set, collapse = ', ')}")
    )
    bds_summary[[paste(col_set, collapse = "_")]] <- glimpse_ordered(bds[
      col_set
    ])
    cols_to_summarise <- setdiff(cols_to_summarise, col_set)
  }

  # Glimpse each remaining column
  for (col in cols_to_summarise) {
    message(glue::glue("Glimpsing column(s): {col}"))
    bds_summary[[col]] <- if (col %in% flag_cols) {
      glimpse_flag(bds[[col]], col)
    } else {
      glimpse(bds[[col]], col, na_mode = "none", seed = seed)
    }
  }

  attr(bds_summary, "col_order") <- colnames(bds)

  bds_summary <- .add_summary_class(bds_summary, "bds")

  return(bds_summary)
}

#' Simulate a synthetic BDS dataset.
#'
#' Generates synthetic BDS data by creating a spine from parameter/visit
#' combinations and ADSL subject records, then populating remaining columns,
#' preserving the original data structure.
#'
#' @inheritParams simulate
#'
#' @param bds_summary `summary_bds` - summary object created by [glimpse_bds()].
#'
#' @return `data.frame` - synthetic BDS dataset.
#'
#' @examples
#' \dontshow{
#' # Load bundled ADSL/ADLB fixtures so the example can run.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' adlb <- read.csv(
#'   system.file("extdata", "adlb.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#'
#' syn_adsl <- simulate_adsl(glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN")
#' ))
#' bds_summary <- glimpse_bds(
#'   adlb,
#'   syn_adsl,
#'   id_cols = "USUBJID",
#'   param_cols = c("PARAM", "PARAMCD"),
#'   visit_cols = c("AVISIT", "AVISITN")
#' )
#' syn_adlb <- simulate_bds(bds_summary, seed = 42)
#' head(syn_adlb)
#'
#' @export
simulate_bds <- function(bds_summary, seed = NULL) {
  checkmate::assert_class(bds_summary, "summary_bds")

  # The ADSL subject levels and param/visit profiles form the "spine" of a BDS
  message("Simulating PARAM/VISIT and ADSL columns")
  param_visits <- bds_summary[["param_visits"]]
  adsl_cols <- bds_summary[["adsl_cols"]]

  # Sample profiles weighted by masked counts, one per synthetic ADSL subject
  set.seed(seed)
  profile_indices <- sample(
    seq_along(param_visits[["profiles"]]),
    size = nrow(adsl_cols),
    replace = TRUE,
    prob = param_visits[["profile_counts"]] /
      sum(param_visits[["profile_counts"]])
  )

  bds_spine <- adsl_cols |>
    dplyr::mutate(
      .profile_idx = profile_indices,
      .profile_data = param_visits[["profiles"]][.profile_idx]
    ) |>
    tidyr::unnest(.profile_data) |>
    dplyr::select(-.profile_idx)

  # Simulate the remaining cols
  bds_summary_remaining <- bds_summary[
    !(names(bds_summary) %in% c("param_visits", "adsl_cols"))
  ]

  syn_bds <- vector("list", length = length(bds_summary_remaining))
  for (i in seq_along(bds_summary_remaining)) {
    message(
      glue::glue(
        "Simulating column(s): ",
        "{.format_columns(names(bds_summary)[i])}"
      )
    )
    syn_bds[[i]] <- simulate(
      bds_summary_remaining[[i]],
      output_length = nrow(bds_spine),
      seed = seed
    )
  }
  syn_bds <- syn_bds |> dplyr::bind_cols(bds_spine)

  # Match order of output columns to input BDS
  syn_bds <- dplyr::select(
    syn_bds,
    dplyr::all_of(attr(bds_summary, "col_order"))
  )

  return(syn_bds)
}

#' Validate input arguments for `glimpse_bds()`.
#'
#' @inheritParams glimpse_bds
#'
#' @return None.
#' @keywords internal
.validate_input_glimpse_bds <- function(
    bds,
    syn_adsl,
    id_cols,
    param_cols,
    visit_cols,
    flag_cols,
    ordered_col_sets) {
  checkmate::assert_data_frame(bds)
  checkmate::assert_data_frame(syn_adsl)
  checkmate::assert_character(
    id_cols,
    min.len = 1,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_character(
    param_cols,
    min.len = 1,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_character(
    visit_cols,
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
    id_cols,
    param_cols,
    visit_cols,
    flag_cols,
    unlist(ordered_col_sets)
  )
  checkmate::assert_character(special_cols, unique = TRUE)

  # Check bds and syn_adsl share columns
  checkmate::assert_true(sum(colnames(bds) %in% colnames(syn_adsl)) > 0)

  # Check PARAMCD col is found in param_cols
  checkmate::assert_true("PARAMCD" %in% param_cols)

  # Check id_cols exist in both bds and syn_adsl
  .assert_subset(id_cols, colnames(bds), "bds")
  .assert_subset(id_cols, colnames(syn_adsl), "syn_adsl")

  # Check all provided columns exist in bds
  .assert_subset(
    c(param_cols, visit_cols, flag_cols, unlist(ordered_col_sets)),
    colnames(bds),
    "bds"
  )

  # Subject-ID columns present in the data must be declared as id_cols
  .assert_required_id_cols(bds, id_cols, "bds")
}
