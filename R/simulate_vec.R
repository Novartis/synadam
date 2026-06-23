#' Simulate a vector from a summary object.
#'
#' @param summary `summary` - output from a glimpse function.
#' @param output_length `integer` - number of rows to simulate.
#' @param seed `integer` - random seed for reproducibility.
#' @param ... additional arguments passed to methods.
#'
#' @return `data.frame` - the simulated dataset.
#'
#' @examples
#' # Summarise a vector with glimpse().
#' summary <- glimpse(c("A", "B", "B", "C"), col_name = "column_name")
#' simulate(summary, output_length = 10, seed = 1)
#'
#' @export
simulate <- function(summary, ...) {
  checkmate::assert_class(summary, "summary")

  UseMethod("simulate")
}

#' @describeIn simulate simulate a character vector by sampling from unique
#'   values.
#'
#' @export
simulate.summary_character <- function(
    summary,
    output_length,
    seed = NULL,
    ...) {
  if ("all_na" %in% names(summary) && summary[["all_na"]]) {
    syn_data <- as.character(rep(NA, output_length))
  } else {
    set.seed(seed)
    syn_data <- sample(
      summary[["unique_values"]],
      size = output_length,
      replace = TRUE
    )
    syn_data <- .inject_nas(syn_data, summary[["na_positions"]])
  }

  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate a Date vector by sampling uniformly
#'   between min and max.
#'
#' @export
simulate.summary_Date <- function(summary, output_length, seed = NULL, ...) {
  if ("all_na" %in% names(summary) && summary[["all_na"]]) {
    syn_data <- as.Date(rep(NA, output_length))
  } else {
    set.seed(seed)
    syn_data <- as.Date(
      round(stats::runif(
        output_length,
        min = summary[["min"]],
        max = summary[["max"]]
      )),
      origin = "1970-01-01"
    )
    syn_data <- .inject_nas(syn_data, summary[["na_positions"]])
  }

  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate a POSIXct vector by sampling uniformly
#'   between min and max.
#'
#' @export
simulate.summary_POSIXct <- function(summary, output_length, seed = NULL, ...) {
  if ("all_na" %in% names(summary) && summary[["all_na"]]) {
    syn_data <- as.POSIXct(rep(NA, output_length))
  } else {
    set.seed(seed)
    syn_data <- as.POSIXct(
      stats::runif(
        output_length,
        min = summary[["min"]],
        max = summary[["max"]]
      ),
      origin = "1970-01-01"
    )
    syn_data <- .inject_nas(syn_data, summary[["na_positions"]])
  }

  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate a difftime vector by sampling uniformly
#'   between min and max.
#'
#' @export
simulate.summary_difftime <- function(
    summary,
    output_length,
    seed = NULL,
    ...) {
  if ("all_na" %in% names(summary) && summary[["all_na"]]) {
    syn_data <- as.difftime(rep(NA_real_, output_length), units = "secs")
  } else {
    set.seed(seed)
    syn_data <- as.difftime(
      stats::runif(
        output_length,
        min = summary[["min"]],
        max = summary[["max"]]
      ),
      units = summary[["units"]]
    )
    syn_data <- .inject_nas(syn_data, summary[["na_positions"]])
  }

  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate an integerish vector by sampling uniformly
#'   between min and max and rounding.
#'
#' @export
simulate.summary_integer <- function(
    summary,
    output_length,
    seed = NULL,
    ...) {
  syn_data <- round(simulate.summary_double(summary, output_length, seed, ...))

  return(syn_data)
}

#' @describeIn simulate simulate a double vector by sampling uniformly
#'   between min and max.
#'
#' @export
simulate.summary_double <- function(summary, output_length, seed = NULL, ...) {
  if ("all_na" %in% names(summary) && summary[["all_na"]]) {
    syn_data <- as.numeric(rep(NA, output_length))
  } else {
    set.seed(seed)
    syn_data <- stats::runif(
      output_length,
      min = summary[["min"]],
      max = summary[["max"]]
    )
    syn_data <- .inject_nas(syn_data, summary[["na_positions"]])
  }

  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate an ID vector by generating sequential IDs.
#'
#' @export
simulate.summary_id <- function(summary, output_length, ...) {
  col_name <- summary[["col_name"]]
  syn_data <- paste0(col_name, "_", seq_len(output_length))
  syn_data <- dplyr::tibble(!!col_name := syn_data)

  return(syn_data)
}

#' @describeIn simulate simulate a flag vector by sampling Y/N in proportion
#'   to input.
#'
#' @export
simulate.summary_flag <- function(summary, output_length, seed = NULL, ...) {
  set.seed(seed)
  syn_data <- sample(
    c("Y", "N"),
    size = output_length,
    replace = TRUE,
    prob = c(summary[["prop_y"]], 1 - summary[["prop_y"]])
  )
  syn_data <- dplyr::tibble(!!summary[["col_name"]] := syn_data)
  return(syn_data)
}
