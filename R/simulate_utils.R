#' Inject NAs into a vector.
#'
#' @param x `vector` - simulated vector.
#' @param na_positions `integer` - indices where NAs should be injected.
#'
#' @return `vector` - with NAs injected.
#' @keywords internal
.inject_nas <- function(x, na_positions) {
  if (length(na_positions) > 0) {
    x[na_positions] <- NA
  }

  return(x)
}
