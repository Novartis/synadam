#' Glimpse a vector.
#'
#' Extracts a statistical summary from a vector that preserves its structure
#' while enabling synthetic data generation. The summary type varies by vector
#' class: character vectors output unique values, numeric vectors output min/max
#' values, and date/time vectors output earliest/latest dates.
#'
#' @param x `vector` - input vector.
#' @param col_name `character` - column name corresponding to the input vector.
#' @param na_mode `character` - "mirror" to capture NA positions, "none" to
#'   ignore NAs in simulation.
#' @param seed `integer` - random seed for reproducibility.
#' @param ... additional arguments passed to methods.
#'
#' @return `summary` - contains summary of the input vector.
#'
#' @examples
#' # Glimpse a character vector, then simulate synthetic values from it.
#' summary <- glimpse(c("A", "B", "B", "C"), col_name = "column_name")
#' simulate(summary, output_length = 10, seed = 1)
#'
#' @export
glimpse <- function(x, ...) {
  checkmate::assert_vector(x, min.len = 1)

  UseMethod("glimpse")
}

#' @describeIn glimpse glimpse a character vector using
#'   [.get_unique_values()].
#'
#' @export
glimpse.character <- function(
    x,
    col_name,
    na_mode = "mirror",
    seed = NULL,
    ...) {
  if (all(is.na(x))) {
    summary <- list(col_name = col_name, all_na = TRUE)
  } else {
    summary <- .get_unique_values(
      x,
      col_name
    )
    summary[["na_positions"]] <- .get_na_positions(
      x,
      na_mode = na_mode,
      seed = seed
    )
  }

  summary <- .add_summary_class(summary, class(x))

  return(summary)
}

#' @describeIn glimpse glimpse a Date vector into a summary containing
#'   the min, max, and NA positions.
#'
#' @export
glimpse.Date <- function(x, col_name, na_mode = "mirror", seed = NULL, ...) {
  if (all(is.na(x))) {
    summary <- list(col_name = col_name, all_na = TRUE)
  } else {
    summary <- list(
      col_name = col_name,
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      na_positions = .get_na_positions(x, na_mode = na_mode, seed = seed)
    )
  }
  summary <- .add_summary_class(summary, class(x))

  return(summary)
}

#' @describeIn glimpse glimpse a POSIXct vector into a summary containing
#'   the min, max, and NA positions.
#'
#' @export
glimpse.POSIXct <- function(x, col_name, na_mode = "mirror", seed = NULL, ...) {
  if (all(is.na(x))) {
    summary <- list(col_name = col_name, all_na = TRUE)
  } else {
    summary <- list(
      col_name = col_name,
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      na_positions = .get_na_positions(x, na_mode = na_mode, seed = seed)
    )
  }
  summary <- .add_summary_class(summary, class(x)[1])

  return(summary)
}

#' @describeIn glimpse glimpse a difftime vector into a summary containing
#'   the min, max, units, and NA positions.
#'
#' @export
glimpse.difftime <- function(
    x,
    col_name,
    na_mode = "mirror",
    seed = NULL,
    ...) {
  if (all(is.na(x))) {
    summary <- list(col_name = col_name, all_na = TRUE)
  } else {
    summary <- list(
      col_name = col_name,
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      units = units(x),
      na_positions = .get_na_positions(x, na_mode = na_mode, seed = seed)
    )
  }
  summary <- .add_summary_class(summary, class(x))

  return(summary)
}

#' @describeIn glimpse glimpse a numeric vector into a summary containing the
#'   min, max, and NA positions. Detects if values are integer or double.
#'
#' @export
glimpse.numeric <- function(x, col_name, na_mode = "mirror", seed = NULL, ...) {
  summary_class <- if (checkmate::test_integerish(x)) {
    "integer"
  } else {
    "double"
  }

  if (all(is.na(x))) {
    summary <- list(col_name = col_name, all_na = TRUE)
  } else {
    summary <- list(
      col_name = col_name,
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE),
      na_positions = .get_na_positions(x, na_mode = na_mode, seed = seed)
    )
  }

  summary <- .add_summary_class(summary, summary_class)

  return(summary)
}

#' Glimpse an ID vector.
#'
#' @inheritParams glimpse
#'
#' @param x `vector` - contains ID values.
#'
#' @return `summary` - contains column name for ID generation.
#'
#' @examples
#' # Glimpse an ID column, then simulate fresh sequential IDs.
#' summary <- glimpse_id(c("S1", "S2", "S3"), col_name = "USUBJID")
#' simulate(summary, output_length = 5)
#'
#' @export
glimpse_id <- function(x, col_name) {
  checkmate::assert_vector(x, any.missing = FALSE, unique = TRUE)

  summary <- list(col_name = col_name)
  summary <- .add_summary_class(summary, "id")

  return(summary)
}

glimpse_flag <- function(x, col_name) {
  checkmate::assert_character(x)
  checkmate::assert_subset(x, c("Y", "N", NA))

  x_non_na <- x[!is.na(x)]
  prop_y <- if (length(x_non_na) == 0) 1 else mean(x_non_na == "Y")

  summary <- list(col_name = col_name, prop_y = prop_y)
  summary <- .add_summary_class(summary, "flag")

  return(summary)
}
