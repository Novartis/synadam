test_that(".get_unique_values works correctly", {
  x <- c(as.character(rep(1:10, 2)), NA)
  x_summary <- .get_unique_values(
    x,
    "test_col"
  )

  expect_equal(x_summary[["col_name"]], "test_col")

  # Check that NAs are excluded from unique values
  expect_equal(sort(x_summary[["unique_values"]]), sort(as.character(1:10)))

  # Check min_occurrences filters out rare values
  x <- c("a", "a", "a", "b", "b", "c")
  x_summary <- .get_unique_values(
    x,
    "test_col"
  )
  expect_equal(
    sort(x_summary[["unique_values"]]),
    sort(c("a", "b"))
  )

  # Check all unique values are returned
  x <- as.character(rep(1:20, 2))
  expect_silent(x_summary <- .get_unique_values(x, "test_col"))
  expect_equal(sort(x_summary[["unique_values"]]), sort(as.character(1:20)))
})

test_that(".get_na_positions works correctly", {
  expect_equal(.get_na_positions(c(1, 2, 3), na_noise = 0), integer())
  expect_equal(.get_na_positions(c(NA, NA, NA), na_noise = 0), 1:3)
  expect_equal(.get_na_positions(c(NA, 1, 2, NA, 3), na_noise = 0), c(1, 4))

  #  na_mode param works as expected
  expect_equal(
    .get_na_positions(c(NA, 1, 2, NA, 3), na_mode = "none"),
    integer()
  )

  # Check correct proportion of na_noise is added
  # After flipping, NA count should differ from original <= n_expected_flips
  set.seed(42)
  x <- c(rep(NA, 10), rep(1, 90))
  na_positions <- .get_na_positions(x, na_noise = 0.1)
  n_expected_flips <- ceiling(length(x) * 0.1)
  original_na_count <- 10

  expect_true(abs(length(na_positions) - original_na_count) <= n_expected_flips)
})
