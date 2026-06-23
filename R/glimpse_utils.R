#' Glimpse a vector creating a summary of unique values.
#'
#' @inheritParams glimpse
#'
#' @return `summary` - contains unique values.
#' @keywords internal
.get_unique_values <- function(
    x,
    col_name) {
  # Only retain non-missing, unique values
  x_table <- table(x, useNA = "no")

  # Remove values with only 1 occurence
  x_unique <- names(x_table[x_table != 1])

  # If there are no unique values remaining, use "MASKED" as only unique value
  if (length(x_unique) == 0) {
    x_unique <- "MASKED"
  }

  summary <- list(
    col_name = col_name,
    unique_values = x_unique
  )

  return(summary)
}

#' Extract NA positions from a vector.
#'
#' @inheritParams glimpse
#' @param na_noise `numeric` - proportion of positions to flip.
#'
#' @return `integer` - indices of NA positions (with noise applied), or empty
#'   vector if na_mode is "none".
#' @keywords internal
.get_na_positions <- function(
    x,
    na_mode = "mirror",
    na_noise = 0.05,
    seed = NULL) {
  checkmate::assert_vector(x, min.len = 1)
  checkmate::assert_character(na_mode, len = 1)
  checkmate::assert_choice(na_mode, c("mirror", "none"))
  checkmate::assert_number(na_noise, lower = 0, upper = 1)

  if (na_mode == "none") {
    return(integer())
  }

  na_mask <- is.na(x)

  # Return early if there are no NAs
  if (!any(na_mask)) {
    return(integer())
  }

  # Flip a proportion of NA positions to avoid identical NA patterns
  n_flip <- ceiling(length(x) * na_noise)
  set.seed(seed)
  to_flip <- sample(seq_along(x), n_flip)
  na_mask[to_flip] <- !na_mask[to_flip]

  na_positions <- which(na_mask)

  return(na_positions)
}
