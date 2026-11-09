#' @describeIn simulate simulate ordered columns by sampling from unique
#'   combinations.
#'
#' @export
simulate.summary_ordered <- function(summary, output_length, seed = NULL, ...) {
  unique_combinations <- summary[["unique_combinations"]]
  set.seed(seed)
  idx <- sample(
    seq_len(nrow(unique_combinations)),
    size = output_length,
    replace = TRUE
  )
  syn_data <- unique_combinations[idx, ]

  return(syn_data)
}

#' @describeIn simulate simulate treatment and flag columns by preserving
#'   exact counts for each combination.
#'
#' @export
simulate.summary_treatment_flag <- function(summary, ...) {
  syn_data <- summary[["treatment_flag_counts"]] |>
    tidyr::uncount(n)

  return(syn_data)
}

#' @describeIn simulate simulate a stratified column (from
#'   [.glimpse_stratified()]) by drawing each row from its stratum's child
#'   summary, matched positionally against the stored levels (NA-safe).
#'
#' @param strata `vector` - stratum value per output row (e.g. PARAMCD). Every
#'   stratum was seen during glimpse, so each has a child summary.
#'
#' @export
simulate.summary_stratified <- function(summary, strata, seed = NULL, ...) {
  col_name <- summary[["col_name"]]
  idx <- match(strata, summary[["levels"]])
  n <- length(idx)

  # simulate each stratum in one shot, then scatter back to original positions
  out <- vector("list", length = n)
  for (i in seq_along(summary[["children"]])) {
    pos <- which(idx == i)
    child <- summary[["children"]][[i]]
    sim <- simulate(child, output_length = length(pos), seed = seed)
    out[pos] <- sim[[1]]
  }

  # value columns are only ever numeric/character, so unlist rebuilds the type
  vals <- unlist(out, use.names = FALSE)
  checkmate::assert_true(length(vals) == n)
  dplyr::tibble(!!col_name := vals)
}
