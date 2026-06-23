#' Glimpse ordered columns.
#'
#' Ordered columns are those which should be simulated together, such as
#' PARAM/PARAMCD or REGION1/REGION1N/REGION2/REGION2N. Rare combinations
#' (count = 1) are masked for privacy protection.
#'
#' @param df `data.frame` - contains ordered columns.
#'
#' @return `summary` - contains column names, unique combinations, and
#'   NA positions.
#'
#' @examples
#' df <- data.frame(
#'   REGION1 = c("North America", "North America", "Europe", "Europe"),
#'   REGION1N = c(1, 1, 2, 2)
#' )
#' summary <- glimpse_ordered(df)
#' simulate(summary, output_length = 6, seed = 1)
#'
#' @export
glimpse_ordered <- function(df) {
  checkmate::assert_data_frame(df, min.cols = 2, all.missing = FALSE)

  # Count combinations from original data
  unique_combinations_counts <- df |>
    dplyr::filter(!dplyr::if_all(dplyr::everything(), is.na)) |>
    dplyr::count(dplyr::across(dplyr::everything()), name = "n")

  # Mask combinations with count == 1 for privacy
  unique_combinations <- unique_combinations_counts |>
    .mask_combinations(context_name = "ordered column combination") |>
    dplyr::select(-n)

  col_names <- colnames(df)

  summary <- list(
    col_names = col_names,
    unique_combinations = unique_combinations
  )

  summary <- .add_summary_class(summary, "ordered")

  return(summary)
}

#' Glimpse treatment and flag columns together.
#'
#' Captures unique combinations of treatment and flag columns with their counts,
#' preserving the relationship between treatments and analysis flags.
#' Combinations with count = 1 are masked for privacy protection by adding their
#' counts to the most common combination.
#'
#' @param df `data.frame` - contains treatment and flag columns.
#'
#' @return `summary` - contains treatment-flag combinations with counts.
#'
#' @examples
#' df <- data.frame(
#'   TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
#'   SAFFL = c("Y", "Y", "Y", "N")
#' )
#' summary <- glimpse_treatment_flag(df)
#' # simulate() preserves the exact treatment-flag counts (no output_length).
#' simulate(summary)
#'
#' @export
glimpse_treatment_flag <- function(df) {
  checkmate::assert_data_frame(df, min.cols = 1)

  treatment_flag_counts <- df |>
    dplyr::count(dplyr::across(dplyr::everything()), name = "n")

  # Mask combinations with n == 1 (privacy protection)
  treatment_flag_counts <- .mask_combinations(
    treatment_flag_counts,
    context_name = "treatment/flag combination"
  )

  summary <- list(
    treatment_flag_counts = treatment_flag_counts
  )

  summary <- .add_summary_class(summary, "treatment_flag")

  return(summary)
}

#' Glimpse parameter and visit columns.
#'
#' Extracts per-subject param/visit profiles from a BDS dataset. Rare
#' param/visit combinations (count = 1) are masked for privacy protection.
#' Subjects are grouped by their set of surviving param/visit combinations
#' to form profiles, which are used by [simulate_bds()] to construct the
#' simulation spine.
#'
#' @param df `data.frame` - contains ID and parameter/visit columns.
#' @param id_cols `character` - ID column(s) to identify subjects
#'   e.g. c("USUBJID").
#' @param param_visit_cols `character` - parameter and visit column names
#'   e.g. c("PARAM", "PARAMCD", "AVISIT", "AVISITN").
#'
#' @return `summary_param_visits` - contains deduplicated profiles with masked
#'   counts and the unique param/visit combinations (after masking).
#'
#' @examples
#' \dontshow{
#' # Load a bundled ADLB fixture so the example can run.
#' adlb <- read.csv(
#'   system.file("extdata", "adlb.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#' # Build per-subject parameter/visit profiles (used within glimpse_bds()).
#' glimpse_param_visits(
#'   adlb,
#'   id_cols = "USUBJID",
#'   param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
#' )
#'
#' @export
glimpse_param_visits <- function(df, id_cols, param_visit_cols) {
  checkmate::assert_data_frame(df, min.cols = 1)
  checkmate::assert_character(id_cols, min.len = 1, any.missing = FALSE)
  checkmate::assert_character(
    param_visit_cols,
    min.len = 1,
    any.missing = FALSE
  )
  checkmate::assert_subset(c(id_cols, param_visit_cols), colnames(df))

  # Count distinct param/visit combinations across all subjects
  unique_param_visits_counts <- df |>
    dplyr::select(dplyr::all_of(param_visit_cols)) |>
    dplyr::count(dplyr::across(dplyr::everything()), name = "n")

  # Mask singleton combinations for privacy
  unique_param_visits <- unique_param_visits_counts |>
    .mask_combinations(
      context_name = "parameter/visit combination"
    ) |>
    dplyr::select(-n)

  # Filter subject records to only include non-masked param/visit combos
  df_filtered <- df |>
    dplyr::select(dplyr::all_of(c(id_cols, param_visit_cols))) |>
    dplyr::semi_join(unique_param_visits, by = param_visit_cols)

  # Build per-subject profiles: nest param/visit rows by subject,
  # then drop ID columns so no real subject identifiers are retained
  subject_profiles <- df_filtered |>
    dplyr::arrange(dplyr::across(dplyr::all_of(param_visit_cols))) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(id_cols))) |>
    tidyr::nest(.key = "param_visits") |>
    dplyr::ungroup()

  # Create a string key per profile to identify duplicates
  subject_profiles$.profile_key <- vapply(
    subject_profiles$param_visits,
    rlang::hash,
    character(1)
  )

  # Deduplicate: one row per distinct profile, with count.
  profile_groups <- subject_profiles |>
    dplyr::group_by(.profile_key) |>
    dplyr::summarise(
      n = dplyr::n(),
      param_visits = list(dplyr::first(param_visits)),
      .groups = "drop"
    )

  profiles <- profile_groups$param_visits
  profile_counts <- profile_groups$n

  summary <- list(
    profiles = profiles,
    profile_counts = profile_counts,
    unique_param_visits = unique_param_visits
  )

  summary <- .add_summary_class(summary, "param_visits")

  return(summary)
}

#' Glimpse parameter columns.
#'
#' Extracts unique combinations of parameter columns without filtering.
#' Used for TTE datasets where all PARAMCDs are simulated. Rare combinations
#' (count = 1) are masked for privacy protection.
#'
#' @param df `data.frame` - contains parameter columns.
#'
#' @return `summary_params` - contains unique parameter combinations.
#'
#' @examples
#' df <- data.frame(
#'   PARAM = c("Overall Survival", "Overall Survival", "Progression Free"),
#'   PARAMCD = c("OS", "OS", "PFS")
#' )
#' glimpse_params(df)
#'
#' @export
glimpse_params <- function(df) {
  checkmate::assert_data_frame(df, min.cols = 1)

  # Count combinations
  unique_params_counts <- df |>
    dplyr::count(dplyr::across(dplyr::everything()), name = "n")

  # Mask combinations with n == 1 (privacy protection)
  unique_params <- unique_params_counts |>
    .mask_combinations(context_name = "parameter combination") |>
    dplyr::select(-n)

  summary <- list(unique_params = unique_params)

  summary <- .add_summary_class(summary, "params")

  return(summary)
}

#' Glimpse occurrence counts, ID columns, and sequence column.
#'
#' Counts the number of occurrences (records) per subject in an OCCDS dataset
#' and captures the ID and sequence column names needed for spine construction.
#'
#' @param df `data.frame` - OCCDS dataset containing ID and sequence columns.
#' @param id_cols `character` - name(s) of ID column(s) to group by.
#' @param seq_col `character` - name of the sequence column.
#'
#' @return `summary_occurrence_id_seq` - contains occurrence counts per subject,
#'   ID column names, and sequence column name.
#'
#' @examples
#' \dontshow{
#' # Load a bundled ADAE fixture so the example can run.
#' adae <- read.csv(
#'   system.file("extdata", "adae.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' }
#' # Capture per-subject occurrence counts (used within glimpse_occds()).
#' glimpse_occurrence_id_seq(adae, id_cols = "USUBJID", seq_col = "AESEQ")
#'
#' @export
glimpse_occurrence_id_seq <- function(df, id_cols, seq_col) {
  checkmate::assert_data_frame(df, min.rows = 1)
  checkmate::assert_character(id_cols, min.len = 1, any.missing = FALSE)
  checkmate::assert_subset(id_cols, colnames(df))
  checkmate::assert_string(seq_col)
  checkmate::assert_choice(seq_col, colnames(df))

  counts <- df |>
    dplyr::count(
      dplyr::across(dplyr::all_of(id_cols)),
      name = "n_occurrences"
    ) |>
    dplyr::pull(n_occurrences)

  summary <- list(
    counts = counts,
    id_cols = id_cols,
    seq_col = seq_col
  )

  summary <- .add_summary_class(summary, "occurrence_id_seq")

  return(summary)
}

#' Mask rare combinations for privacy protection.
#'
#' Internal helper that filters out combinations with count = 1 and
#' redistributes their counts to the most common combination.
#'
#' @param counts `data.frame` - contains combinations, with a column named `n`
#'   containing counts for each combination.
#' @param context_name `character` - descriptive name for the type of
#'   combination being masked (e.g., "treatment/flag", "ordered column").
#'   Used in messages.
#'
#' @return `data.frame` - combinations with count = 1 have been
#'   removed and their counts have been added to the most common combination.
#' @keywords internal
.mask_combinations <- function(counts, context_name = "combination") {
  checkmate::assert_data_frame(counts)
  checkmate::assert_string(context_name)
  checkmate::assert_choice("n", colnames(counts))

  # Count how many combinations have n == 1
  n_masked <- counts |>
    dplyr::filter(n == 1) |>
    nrow()

  if (n_masked > 0) {
    checkmate::assert_true(
      any(counts$n > 1),
      .var.name = glue::glue("All {context_name}s have count = 1. Cannot mask")
    )

    # Add masked counts to first combination with max count
    counts <- counts |>
      dplyr::mutate(
        n = dplyr::if_else(
          n == max(n) & dplyr::row_number() == which.max(n),
          n + n_masked,
          n
        )
      ) |>
      # Remove masked rows
      dplyr::filter(n > 1)

    message(glue::glue(
      "{n_masked} {context_name}(s) with count = 1 were masked ",
      "and added to the most common combination."
    ))
  }

  return(counts)
}
