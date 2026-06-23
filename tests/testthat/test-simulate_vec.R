# Helper to test simulate methods for types using min/max approach.
test_simulate_helper <- function(as_class_fun) {
  x <- if (identical(as_class_fun, as.difftime)) {
    as_class_fun(c(1:9, NA), units = "secs")
  } else {
    as_class_fun(c(1:9, NA))
  }
  x_summary <- glimpse(x, col_name = "test_col")
  syn_data <- simulate(x_summary, output_length = 100)
  expect_s3_class(syn_data, "data.frame")
  expect_equal(nrow(syn_data), 100)
  # Check all values lie between min and max
  expect_true(all(
    na.omit(syn_data[["test_col"]]) >= x_summary[["min"]] &
      na.omit(syn_data[["test_col"]]) <= x_summary[["max"]]
  ))

  # Check NA input leads to all NA output
  if (identical(as_class_fun, as.difftime)) {
    x <- as_class_fun(rep(NA_real_, 10), units = "secs")
  } else {
    x <- as_class_fun(rep(NA, 10))
  }
  syn_data <- glimpse(x, col_name = "test_col") |> simulate(output_length = 100)

  expect_equal(nrow(syn_data), 100)
  expect_true(all(is.na(syn_data[["test_col"]])))
  expect_equal(class(x), class(syn_data[["test_col"]]))
}

test_that("simulate.summary_character works correctly", {
  x <- as.character(rep(1:9, each = 2), 10)
  x_summary <- glimpse(
    x,
    col_name = "test_col",
    min_occurrences = 0
  )
  syn_data <- simulate(x_summary, output_length = 100)

  expect_s3_class(syn_data, "data.frame")
  expect_equal(nrow(syn_data), 100)
  # Ensure "10" is dropped as it falls below min_occurences threshold
  expect_true(all(syn_data[["test_col"]] %in% as.character(1:9)))

  # Check NA input leads to all NA output
  x <- as.character(rep(NA, 10))
  syn_data <- glimpse(x, "test_col") |> simulate(output_length = 100)
  expect_equal(nrow(syn_data), 100)
  expect_true(all(is.na(syn_data[["test_col"]])))
  expect_equal(class(x), class(syn_data[["test_col"]]))
})

test_that("simulate.summary_POSIXct works correctly", {
  test_simulate_helper(as.POSIXct)
})

test_that("simulate.summary_Date works correctly", {
  test_simulate_helper(as.Date)
})

test_that("simulate.summary_difftime works correctly", {
  test_simulate_helper(as.difftime)
})

test_that("simulate.summary_integer/simulate.summary_double works correctly", {
  test_simulate_helper(as.numeric)
})

test_that("simulate.summary_id works correctly", {
  x_summary <- glimpse_id(c("ID1", "ID2"), "id_col")
  syn_data <- simulate(x_summary, output_length = 5)

  expect_s3_class(syn_data, "data.frame")
  expect_equal(nrow(syn_data), 5)
  expect_equal(syn_data[["id_col"]], paste0("id_col_", 1:5))
})

test_that("simulate.summary_flag works correctly", {
  x_summary <- glimpse_flag(c("Y", "N"), "flag_col")
  syn_data <- simulate(x_summary, output_length = 100, seed = 42)

  expect_s3_class(syn_data, "data.frame")
  expect_equal(nrow(syn_data), 100)
  expect_true(all(syn_data[["flag_col"]] %in% c("Y", "N")))

  # prop_y = 1 produces all Y
  all_y <- glimpse_flag(c("Y", "Y"), "f")
  expect_true(all(simulate(all_y, output_length = 50)[["f"]] == "Y"))

  # prop_y = 0 produces all N
  all_n <- glimpse_flag(c("N", "N"), "f")
  expect_true(all(simulate(all_n, output_length = 50)[["f"]] == "N"))

  # Seed reproducibility
  expect_equal(
    simulate(x_summary, output_length = 50, seed = 1),
    simulate(x_summary, output_length = 50, seed = 1)
  )
})
