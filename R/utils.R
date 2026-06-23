#' Read in an ADaM dataset.
#'
#' Loads in a ADaM dataset and and convert all missing values to NA.
#'
#' @param adam_path `character` - path to the `.sas7bdat` file containing the
#'   ADaM dataset.
#'
#' @return `data.frame` - ADaM dataset.
#'
#' @examples
#' \dontshow{
#' # Write a small SAS dataset to a temporary file.
#' adsl <- read.csv(
#'   system.file("extdata", "adsl.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' sas_path <- tempfile(fileext = ".sas7bdat")
#' suppressWarnings(haven::write_sas(adsl, sas_path))
#' }
#' adam <- read_sas7bdat(sas_path)
#' head(adam)
#'
#' @export
read_sas7bdat <- function(adam_path) {
  checkmate::assert_character(adam_path, len = 1, pattern = ".sas7bdat$")

  adam <- haven::read_sas(adam_path) |>
    # Convert all missing values to NA.
    dplyr::mutate(
      dplyr::across(dplyr::where(is.character), ~ dplyr::na_if(.x, ""))
    )

  return(adam)
}

#' Add S3 class to a summary object.
#'
#' @param summary `list` - contains the summary.
#' @param summary_class `character` - the summary object will have the class
#'   c("summary_<summary_class>", "summary").
#'
#' @return `summary` - summary object.
#' @keywords internal
.add_summary_class <- function(summary, summary_class) {
  class(summary) <- c(paste0("summary_", summary_class), "summary")

  return(summary)
}

#' Assert that required values are a subset of available values
#'
#' @param required_cols `character` - values to check for.
#' @param available_cols `character` - available values (e.g., from
#'   colnames()).
#' @param dataset_name `character` - name of the data object for error
#'   message.
#' @param col_type `character` - optional descriptor for value type
#'   (e.g., "ID", "Flag").
#'
#' @return `NULL` if assertion passes, otherwise throws an error.
#' @keywords internal
.assert_subset <- function(required_cols,
                           available_cols,
                           dataset_name,
                           col_type = NULL) {
  missing_cols <- setdiff(required_cols, available_cols)

  col_descriptor <- if (!is.null(col_type)) {
    paste0(col_type, " column(s)")
  } else {
    "Column(s)"
  }

  checkmate::assert(
    length(missing_cols) == 0,
    .var.name = glue::glue(
      "{col_descriptor} not found in {dataset_name}: ",
      "{paste(missing_cols, collapse = ', ')}"
    )
  )

  invisible(NULL)
}

#' Assert canonical subject-ID columns are declared in id_cols.
#'
#' If a canonical subject-ID column (USUBJID or SUBJID) is present in the data,
#' it must be listed in `id_cols` so it is regenerated as a synthetic ID rather
#' than value-sampled (which would leak real subject identifiers).
#'
#' @param data `data.frame` - the real ADaM dataset being glimpsed.
#' @param id_cols `character` - declared ID columns.
#' @param dataset_name `character` - name of the data object for error message.
#'
#' @return `NULL` if assertion passes, otherwise throws an error.
#' @keywords internal
.assert_required_id_cols <- function(data, id_cols, dataset_name) {
  required <- c("USUBJID", "SUBJID")
  present <- intersect(required, colnames(data))
  missing_cols <- setdiff(present, id_cols)

  checkmate::assert(
    length(missing_cols) == 0,
    .var.name = glue::glue(
      "Subject ID column(s) present in {dataset_name} but missing from ",
      "id_cols: {paste(missing_cols, collapse = ', ')}. Add them to id_cols ",
      "so they are regenerated as synthetic IDs (not sampled from real values)."
    )
  )

  invisible(NULL)
}

#' Format columns from 'col1_col2' to 'col1, col2'
#'
#' @param columns `character` - columns to format.
#'
#' @return `character` - formatted columns.
#' @keywords internal
.format_columns <- function(columns) {
  formatted_columns <- gsub(pattern = "_", replacement = ", ", x = columns)

  return(formatted_columns)
}
