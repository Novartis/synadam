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
