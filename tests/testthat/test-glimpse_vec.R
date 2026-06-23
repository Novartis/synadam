# Helper to test glimpse methods for types using min/max approach.
test_glimpse_helper <- function(as_class_fun, difftime = FALSE) {
  x <- if (identical(as_class_fun, as.difftime)) {
    as_class_fun(c(1:9, NA), units = "secs")
  } else {
    as_class_fun(c(1:10, NA))
  }
  x_summary <- glimpse(x, col_name = "test_col")

  expect_equal(x_summary[["col_name"]], "test_col")
  expect_equal(x_summary[["min"]], min(x, na.rm = TRUE))
  expect_equal(x_summary[["max"]], max(x, na.rm = TRUE))
  expect_true("na_positions" %in% names(x_summary))

  # Check seed ensures reproducibility
  expect_equal(
    glimpse(x, col_name = "test", seed = 32),
    glimpse(x, col_name = "test", seed = 32)
  )

  # Check all NA input leads to all_na = TRUE
  if (identical(as_class_fun, as.difftime)) {
    x <- as_class_fun(rep(NA_real_, 10), units = "secs")
  } else {
    x <- as_class_fun(rep(NA, 10))
  }

  expect_equal(
    unclass(glimpse(x, col_name = "test_col")),
    list(col_name = "test_col", all_na = TRUE)
  )
}

test_that("glimpse.character works correctly", {
  x <- as.character(rep(1:9, each = 2), 10)
  x_summary <- glimpse(x, col_name = "test_col")

  expect_equal(x_summary[["col_name"]], "test_col")
  expect_equal(length(x_summary[["unique_values"]]), 9)
  expect_true("na_positions" %in% names(x_summary))
  expect_s3_class(x_summary, c("summary_character", "summary"))

  # Check seed ensures reproducibility
  expect_equal(
    glimpse(
      as.character(rep(1:100, each = 2)),
      col_name = "test_col",
      seed = 32
    ),
    glimpse(
      as.character(rep(1:100, each = 2)),
      col_name = "test_col",
      seed = 32
    )
  )

  # Check all NA input leads to all_na = TRUE
  expect_equal(
    unclass(glimpse(as.character(rep(NA, 10)), col_name = "test_col")),
    list(col_name = "test_col", all_na = TRUE)
  )

  # Unique values with count = 1 are dropped
  x <- c("A", "A", "A", "A", "B", "C", "D", "E")
  x_summary <- glimpse(x, col_name = "test")
  expect_equal(x_summary[["unique_values"]], "A")

  # If all values have count == 1, values are "MASKED"
  x <- c("A", "B", "C")
  expect_equal(
    glimpse(x, col_name = "test")[["unique_values"]],
    "MASKED"
  )

  # All unique values are returned by default
  x <- as.character(rep(1:20, each = 2))
  expect_silent(x_summary <- glimpse(x, col_name = "test_col"))
  expect_equal(length(x_summary[["unique_values"]]), 20)
})

test_that("glimpse.POSIXct works correctly", {
  test_glimpse_helper(as.POSIXct)
})

test_that("glimpse.Date works correctly", {
  test_glimpse_helper(as.Date)
})

test_that("glimpse.difftime works correctly", {
  test_glimpse_helper(as.difftime)
})

test_that("glimpse.numeric works correctly", {
  test_glimpse_helper(as.numeric)

  # Check glimpse differentiates between double and integers
  expect_s3_class(
    glimpse(c(1.0, 1.5, 2.5), "test_col"),
    "summary_double"
  )
  expect_s3_class(
    glimpse(c(1.0, 2.0, 3.0), "test_col"),
    "summary_integer"
  )
})

test_that("glimpse_id works correctly", {
  x_summary <- glimpse_id(c("ID1", "ID2"), "USUBJID")

  expect_s3_class(x_summary, "summary_id")
  expect_equal(x_summary[["col_name"]], "USUBJID")
})

test_that("glimpse_flag works correctly", {
  x_summary <- glimpse_flag(c("Y", "N", "Y"), "flag_col")

  expect_s3_class(x_summary, "summary_flag")
  expect_equal(x_summary[["col_name"]], "flag_col")
  expect_equal(x_summary[["prop_y"]], 2 / 3)

  # NAs are excluded from proportion calculation
  expect_equal(glimpse_flag(c("Y", NA, "N", "Y"), "f")[["prop_y"]], 2 / 3)

  # All NA defaults to prop_y = 1
  expect_equal(glimpse_flag(c(NA, NA), "f")[["prop_y"]], 1)

  # All Y -> prop_y = 1

  expect_equal(glimpse_flag(c("Y", "Y"), "f")[["prop_y"]], 1)

  # All N -> prop_y = 0
  expect_equal(glimpse_flag(c("N", "N"), "f")[["prop_y"]], 0)
})
