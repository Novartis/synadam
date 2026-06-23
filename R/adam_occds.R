#' Glimpse an OCCDS dataset.
#'
#' Summarizes an OCCDS (Occurrence Data Structure) dataset for simulation.
#' Works with ADAE, ADCM, ADMH, ADDV and other occurrence-based datasets.
#'
#' @param occds `data.frame` - input OCCDS dataset e.g. ADAE, ADCM.
#' @param seq_col `character` - sequence column name e.g. "AESEQ", "CMSEQ".
#'
#' @inheritParams glimpse_bds
#' @inheritParams glimpse_tte
#' @inheritParams glimpse_adsl
#'
#' @return `summary_occds` - summary object for OCCDS simulation.
#'
#' @examples
#' \dontshow{
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' adae <- read.csv(
#'   system.file("extdata", "adae.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#'
#' # OCCDS simulation needs a synthetic ADSL first to provide the subject spine.
#' syn_adsl <- simulate_adsl(glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN")
#' ))
#'
#' occds_summary <- glimpse_occds(
#'   adae,
#'   syn_adsl,
#'   id_cols = "USUBJID",
#'   seq_col = "AESEQ",
#'   ordered_col_sets = list(c("AEBODSYS", "AEDECOD"))
#' )
#' syn_adae <- simulate_occds(occds_summary, seed = 42)
#' head(syn_adae)
#'
#' @export
glimpse_occds <- function(
    occds,
    syn_adsl,
    id_cols,
    seq_col,
    flag_cols = character(0),
    ordered_col_sets = list(),
    seed = NULL) {
  .validate_input_glimpse_occds(
    occds,
    syn_adsl,
    id_cols,
    seq_col,
    flag_cols,
    ordered_col_sets
  )

  cols_to_summarise <- colnames(occds)
  occds_summary <- list()

  # Glimpse occurrence counts, ID columns, and sequence column
  message("Glimpsing occurrence counts, ID and sequence columns")
  occds_summary[["occurrence_id_seq"]] <- glimpse_occurrence_id_seq(
    occds,
    id_cols,
    seq_col
  )
  cols_to_summarise <- setdiff(cols_to_summarise, c(seq_col, id_cols))

  # Glimpse ADSL columns
  message("Glimpsing ADSL columns from synthetic ADSL")
  shared_cols <- intersect(colnames(occds), colnames(syn_adsl))
  occds_summary[["adsl_cols"]] <- syn_adsl[shared_cols]
  cols_to_summarise <- setdiff(cols_to_summarise, shared_cols)

  # Glimpse ordered column sets
  for (col_set in ordered_col_sets) {
    message(
      glue::glue("Glimpsing column(s): {paste(col_set, collapse = ', ')}")
    )
    occds_summary[[paste(col_set, collapse = "_")]] <- glimpse_ordered(occds[
      col_set
    ])
    cols_to_summarise <- setdiff(cols_to_summarise, col_set)
  }

  # Glimpse each remaining column
  for (col in cols_to_summarise) {
    message(glue::glue("Glimpsing column(s): {col}"))
    occds_summary[[col]] <- if (col %in% flag_cols) {
      glimpse_flag(occds[[col]], col)
    } else {
      glimpse(occds[[col]], col, na_mode = "none", seed = seed)
    }
  }

  attr(occds_summary, "col_order") <- colnames(occds)
  occds_summary <- .add_summary_class(occds_summary, "occds")

  return(occds_summary)
}

#' Simulate a synthetic OCCDS dataset.
#'
#' Generates synthetic OCCDS data from a summary created by [glimpse_occds()].
#'
#' @inheritParams simulate
#'
#' @param occds_summary `summary_occds` - summary object created by
#'   [glimpse_occds()].
#'
#' @return `data.frame` - synthetic OCCDS dataset.
#'
#' @examples
#' \dontshow{
#' # Load bundled ADSL/ADAE fixtures so the example can run.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' adae <- read.csv(
#'   system.file("extdata", "adae.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#'
#' syn_adsl <- simulate_adsl(glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN")
#' ))
#' occds_summary <- glimpse_occds(
#'   adae,
#'   syn_adsl,
#'   id_cols = "USUBJID",
#'   seq_col = "AESEQ"
#' )
#' syn_adae <- simulate_occds(occds_summary, seed = 42)
#' head(syn_adae)
#'
#' @export
simulate_occds <- function(occds_summary, seed = NULL) {
  checkmate::assert_class(occds_summary, "summary_occds")

  occurrence_id_seq <- occds_summary[["occurrence_id_seq"]]

  # Replicate each subject's ADSL row by a sampled occurrence count
  message("Simulating occurrence counts")
  set.seed(seed)
  occds_spine <- occds_summary[["adsl_cols"]] |>
    dplyr::mutate(
      n_occurrences =
        sample(occurrence_id_seq[["counts"]], size = dplyr::n(), replace = TRUE)
    ) |>
    tidyr::uncount(n_occurrences)

  # Add sequence column
  message("Simulating sequence column")
  occds_spine <- occds_spine |>
    dplyr::group_by(
      dplyr::across(dplyr::all_of(occurrence_id_seq[["id_cols"]]))
    ) |>
    dplyr::mutate(!!occurrence_id_seq[["seq_col"]] := dplyr::row_number()) |>
    dplyr::ungroup()

  # Simulate the remaining columns (excluding spine components)
  remaining_summaries <- occds_summary[
    !(names(occds_summary) %in% c("occurrence_id_seq", "adsl_cols"))
  ]

  syn_occds <- vector("list", length = length(remaining_summaries))
  for (i in seq_along(remaining_summaries)) {
    col_name <- names(remaining_summaries)[i]
    message(
      glue::glue(
        "Simulating column(s): {.format_columns(col_name)}"
      )
    )
    syn_occds[[i]] <- simulate(
      remaining_summaries[[i]],
      output_length = nrow(occds_spine),
      seed = seed
    )
  }
  syn_occds <- syn_occds |> dplyr::bind_cols(occds_spine)

  # Match order of output columns to input OCCDS
  syn_occds <- dplyr::select(
    syn_occds,
    dplyr::all_of(attr(occds_summary, "col_order"))
  )

  return(syn_occds)
}

#' Validate input arguments for `glimpse_occds()`.
#'
#' @inheritParams glimpse_occds
#'
#' @return None.
#' @keywords internal
.validate_input_glimpse_occds <- function(
    occds,
    syn_adsl,
    id_cols,
    seq_col,
    flag_cols,
    ordered_col_sets) {
  checkmate::assert_data_frame(occds)
  checkmate::assert_data_frame(syn_adsl)
  checkmate::assert_character(id_cols, min.len = 1, any.missing = FALSE)
  checkmate::assert_character(seq_col, len = 1)
  checkmate::assert_character(flag_cols, any.missing = FALSE)
  checkmate::assert_list(ordered_col_sets, types = "character")

  # Check all id_cols exist in occds
  .assert_subset(id_cols, colnames(occds), "occds", col_type = "ID")

  # Check all id_cols exist in syn_adsl (they must come from there)
  .assert_subset(
    id_cols,
    colnames(syn_adsl),
    "syn_adsl",
    col_type = "ID"
  )

  # Check seq_col exists in occds
  checkmate::assert_choice(seq_col, colnames(occds))

  # Check all flag columns exist in occds
  .assert_subset(
    flag_cols,
    colnames(occds),
    "occds",
    col_type = "Flag"
  )

  # Check all ordered column sets exist in occds
  .assert_subset(
    unlist(ordered_col_sets),
    colnames(occds),
    "occds",
    col_type = "Ordered"
  )

  # Subject-ID columns present in the data must be declared as id_cols
  .assert_required_id_cols(occds, id_cols, "occds")
}
