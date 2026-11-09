test_that("simulate.summary_ordered works correctly", {
  # Use data with repeated combinations
  df <- data.frame(
    a = c(1, 1, 2, 2, 3, 3),
    b = c("x", "x", "y", "y", "z", "z")
  )
  expect_silent(x_summary <- glimpse_ordered(df))
  syn_data <- simulate(x_summary, output_length = 100)

  expect_s3_class(syn_data, "data.frame")
  expect_equal(nrow(syn_data), 100)
  expect_equal(ncol(syn_data), 2)
  expect_true(all(syn_data[["a"]] %in% c(1, 2, 3)))
  expect_true(all(syn_data[["b"]] %in% c("x", "y", "z")))

  # Check that combinations are preserved
  expect_equal(
    df |> dplyr::distinct() |> dplyr::arrange(a, b),
    syn_data |> dplyr::distinct() |> dplyr::arrange(a, b),
    ignore_attr = TRUE
  )
})

test_that("simulate.summary_treatment_flag preserves exact counts", {
  # Use data with no n=1 combinations
  df <- data.frame(
    TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A", "Drug A"),
    SAFFL = c("Y", "Y", "Y", "Y", "N", "N")
  )
  df_summary <- suppressMessages(glimpse_treatment_flag(df))
  syn_data <- simulate(df_summary)

  expect_equal(nrow(syn_data), nrow(df))

  # Check exact counts are preserved (no masking occurs)
  original_counts <- df |>
    dplyr::count(TRT01A, SAFFL) |>
    dplyr::arrange(TRT01A, SAFFL)
  syn_counts <- syn_data |>
    dplyr::count(TRT01A, SAFFL) |>
    dplyr::arrange(TRT01A, SAFFL)
  expect_equal(original_counts, syn_counts)
})

test_that("simulate.summary_stratified keeps children aligned to levels", {
  # Regression guard for the children[[i]] <-> levels[i] invariant. Strata
  # appear in a scrambled first-appearance order and each stratum has a
  # disjoint value band (band k for stratum k: [k*1000, k*1000 + 100)). If
  # glimpse's seq_along(levels) and simulate's match() ever disagreed, a
  # simulated value would land in the wrong band.
  set.seed(1)
  strata_glimpse <- c("C", "A", "D", "B", "A", "C", "B", "D", "A", "B")
  band <- c(A = 1, B = 2, C = 3, D = 4)
  n <- length(strata_glimpse)
  x <- band[strata_glimpse] * 1000 + stats::runif(n, 0, 100)
  gs <- synadam:::.glimpse_stratified(x, "AVAL", strata_glimpse, seed = 1)

  # Simulate against a DIFFERENTLY ordered strata vector: the mapping must be
  # driven by the stored levels, not by position or by the glimpse-time order.
  strata_sim <- c("A", "A", "B", "C", "D", "D", "B", "C", "A", "B", "C", "D")
  sim <- simulate(gs, strata = strata_sim, seed = 1)

  expect_equal(nrow(sim), length(strata_sim))
  # Every value falls in its own stratum's band -> children aligned to levels.
  expect_equal(floor(sim$AVAL / 1000), unname(band[strata_sim]))
})

test_that("simulate.summary_stratified draws NA-stratum rows correctly", {
  # NA is matched (NA-safe) to its own child, so NA-stratum rows draw from the
  # NA stratum's own disjoint range and no row is left unfilled.
  set.seed(1)
  strata_glimpse <- rep(c("RDI", NA), 5)
  x <- ifelse(strata_glimpse == "RDI", 100, 500)
  x[is.na(strata_glimpse)] <- 500
  gs <- synadam:::.glimpse_stratified(x, "AVAL", strata_glimpse, seed = 1)

  strata_sim <- c("RDI", NA, NA, "RDI", NA)
  sim <- simulate(gs, strata = strata_sim, seed = 1)

  expect_equal(nrow(sim), length(strata_sim))
  expect_true(all(sim$AVAL[is.na(strata_sim)] == 500))
  expect_true(all(sim$AVAL[strata_sim %in% "RDI"] == 100))
})
