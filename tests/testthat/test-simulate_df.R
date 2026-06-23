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
