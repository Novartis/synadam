#' Glimpse an ADSL dataset.
#'
#' Summarizes an ADSL (subject-level) dataset for synthetic simulation by
#' preserving treatment-flag relationships, capturing ordered column
#' combinations and extracting summaries for all other variables.
#'
#' @param adsl `data.frame` - input ADSL dataset.
#' @param id_cols `character` - ID columns e.g. "USUBJID".
#' @param treatment_cols `character` - treatment columns e.g. "TRT01A".
#' @param flag_cols `character` - flag columns e.g. "SAFFL". Default is an
#'   empty character vector (no flag columns).
#' @param ordered_col_sets `list<character>` - each element is a character
#'   vector naming columns whose combinations should be preserved e.g.
#'   `list(c("REGION1", "REGION1N"))`. Default is an empty list.
#' @param seed `integer` - random seed for reproducibility.
#'
#' @return `summary_adsl` - list of summary objects, with each summarising a
#'   column or set of columns in the input ADSL.
#'
#' @examples
#' \dontshow{
#' # Load a bundled ADSL fixture so the example can run.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#' # Glimpse the ADSL, then simulate a synthetic version from the summary.
#' adsl_summary <- glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN"),
#'   flag_cols = c("SAFFL", "ITTFL", "EFFFL"),
#'   ordered_col_sets = list(c("REGION1", "REGION1N")),
#'   seed = 42
#' )
#' syn_adsl <- simulate_adsl(adsl_summary, seed = 42)
#' head(syn_adsl)
#'
#' @export
glimpse_adsl <- function(
    adsl,
    id_cols,
    treatment_cols,
    flag_cols = character(),
    ordered_col_sets = list(),
    seed = NULL) {
  .validate_input_glimpse_adsl(
    adsl,
    id_cols,
    treatment_cols,
    flag_cols,
    ordered_col_sets
  )
  cols_to_summarise <- colnames(adsl)
  adsl_summary <- list()

  # Glimpse treatment and flag columns
  message("Glimpsing treatment/flag columns")
  treatment_flag_cols <- c(treatment_cols, flag_cols)
  adsl_summary[["treatment_flag"]] <- glimpse_treatment_flag(
    adsl[c(treatment_cols, flag_cols)]
  )
  cols_to_summarise <- setdiff(cols_to_summarise, treatment_flag_cols)

  # Glimpse ordered columns
  for (col_set in ordered_col_sets) {
    message(
      glue::glue("Glimpsing column(s): {paste(col_set, collapse = ', ')}")
    )
    adsl_summary[[paste(col_set, collapse = "_")]] <- glimpse_ordered(adsl[
      col_set
    ])
    cols_to_summarise <- setdiff(cols_to_summarise, col_set)
  }

  # Glimpse each remaining column
  for (col in cols_to_summarise) {
    message(glue::glue("Glimpsing column(s): {col}"))
    adsl_summary[[col]] <- if (col %in% id_cols) {
      glimpse_id(adsl[[col]], col)
    } else {
      glimpse(adsl[[col]], col, seed = seed)
    }
  }

  attr(adsl_summary, "col_order") <- colnames(adsl)
  attr(adsl_summary, "output_length") <- nrow(adsl)

  adsl_summary <- .add_summary_class(adsl_summary, "adsl")

  return(adsl_summary)
}

#' Simulate a synthetic ADSL.
#'
#' Generates synthetic subject-level data from an ADSL summary, preserving
#' the structure of the original dataset.
#'
#' @inheritParams simulate
#'
#' @param adsl_summary `summary_adsl` - contains summary objects that describe
#'   an ADSL dataset. Created by [glimpse_adsl()].
#'
#' @return `data.frame` - synthetic ADSL with the same columns (and column
#'   order) as the dataset that was glimpsed, and one row per subject.
#'
#' @examples
#' \dontshow{
#' # Load a bundled ADSL fixture so the example can run.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#' adsl_summary <- glimpse_adsl(
#'   adsl,
#'   id_cols = c("USUBJID", "SUBJID"),
#'   treatment_cols = c("TRT01A", "TRT01AN"),
#'   flag_cols = "SAFFL"
#' )
#' syn_adsl <- simulate_adsl(adsl_summary, seed = 42)
#' head(syn_adsl)
#'
#' @export
simulate_adsl <- function(adsl_summary, seed = NULL) {
  checkmate::assert_class(adsl_summary, "summary_adsl")

  output_length <- attr(adsl_summary, "output_length")

  syn_adam <- vector("list", length = length(adsl_summary))

  for (i in seq_along(adsl_summary)) {
    message(
      glue::glue(
        "Simulating column(s): ",
        "{.format_columns(names(adsl_summary)[i])}"
      )
    )

    syn_adam[[i]] <- simulate(
      adsl_summary[[i]],
      output_length = output_length,
      seed = seed
    )
  }
  syn_adam <- syn_adam |> dplyr::bind_cols()

  # Match order of output columns to input ADSL.
  syn_adam <- dplyr::select(
    syn_adam,
    dplyr::all_of(attr(adsl_summary, "col_order"))
  )

  return(syn_adam)
}

#' Validate input arguments for `glimpse_adsl()`.
#'
#' @inheritParams glimpse_adsl
#'
#' @return None.
#' @keywords internal
.validate_input_glimpse_adsl <- function(
    adsl,
    id_cols,
    treatment_cols,
    flag_cols,
    ordered_col_sets) {
  checkmate::assert_data_frame(adsl)
  checkmate::assert_character(
    id_cols,
    min.len = 1,
    any.missing = FALSE,
    unique = TRUE
  )
  checkmate::assert_character(
    treatment_cols,
    min.len = 1,
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
    treatment_cols,
    flag_cols,
    unlist(ordered_col_sets)
  )
  checkmate::assert_character(special_cols, unique = TRUE)

  # Check all special columns exist in adsl
  .assert_subset(special_cols, colnames(adsl), "adsl")

  # Subject-ID columns present in the data must be declared as id_cols
  .assert_required_id_cols(adsl, id_cols, "adsl")
}
