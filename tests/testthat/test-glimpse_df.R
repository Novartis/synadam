test_that("glimpse_ordered works correctly", {
  # Test with repeated combinations (no rare ones to mask)
  df <- data.frame(
    test_col_1 = c(1, 1, 2, 2, 3, 3),
    test_col_2 = c("A", "A", "B", "B", "A", "A")
  )
  expect_silent(df_summary <- glimpse_ordered(df))

  expect_equal(df_summary[["col_names"]], c("test_col_1", "test_col_2"))
  expect_equal(nrow(df_summary[["unique_combinations"]]), 3)
  expect_s3_class(df_summary, c("summary_ordered", "summary"))

  # Multiple rows with same combinations
  df <- data.frame(a = rep(1:5, each = 2), b = rep(letters[1:5], each = 2))
  expect_silent(result <- glimpse_ordered(df))
  expect_equal(nrow(result[["unique_combinations"]]), 5)

  # Test masking: combinations with count=1 are filtered out
  # Input: (1,A), (1,A), (2,B), (2,B), (3,C) - one rare combination (3,C)
  # Output should have 2 combinations only
  df <- data.frame(
    col1 = c(1, 1, 2, 2, 3),
    col2 = c("A", "A", "B", "B", "C")
  )

  expect_message(
    result <- glimpse_ordered(df),
    "1 ordered column combination\\(s\\) with count = 1 were masked"
  )
  expect_equal(nrow(result[["unique_combinations"]]), 2)

  # Verify the rare combination is not in the output
  expect_false(any(result[["unique_combinations"]]$col1 == 3))

  # No count column in output
  expect_false("n" %in% colnames(result[["unique_combinations"]]))

  # Error when all combinations have count=1
  df <- data.frame(
    col1 = 1:5,
    col2 = letters[1:5]
  )

  expect_error(
    glimpse_ordered(df),
    "All ordered column combinations have count = 1"
  )
})

test_that("glimpse_treatment_flag works correctly", {
  # Basic functionality - no masking needed (no n=1 combinations)
  df <- data.frame(
    TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
    SAFFL = c("Y", "Y", "Y", "Y")
  )
  expect_silent(df_summary <- glimpse_treatment_flag(df))
  expect_equal(nrow(df_summary[["treatment_flag_counts"]]), 2)
  expect_equal(
    df_summary[["treatment_flag_counts"]],
    df |> dplyr::group_by(TRT01A, SAFFL) |> dplyr::count(),
    ignore_attr = TRUE
  )
  expect_s3_class(df_summary, c("summary_treatment_flag", "summary"))

  # Check count of combinations with n=1 are added to most common combination
  # Handles tied max counts correctly - adds to first combination only
  # Combinations: A/Y (n=2), B/N (n=2), C/Y (n=1) - tied max
  # After masking: A/Y (n=3), B/N (n=2) - first tied max gets the masked count
  df <- data.frame(
    TRT01A = c("A", "A", "B", "B", "C"),
    SAFFL = c("Y", "Y", "N", "N", "Y")
  )

  expect_message(
    df_summary <- glimpse_treatment_flag(df),
    "1 treatment/flag combination\\(s\\) with count = 1 were masked"
  )
  expect_equal(nrow(df_summary[["treatment_flag_counts"]]), 2)
  expect_equal(sum(df_summary[["treatment_flag_counts"]]$n), 5)

  first_max <- df_summary[["treatment_flag_counts"]] |>
    dplyr::filter(TRT01A == "A")
  expect_equal(first_max$n, 3)

  second_max <- df_summary[["treatment_flag_counts"]] |>
    dplyr::filter(TRT01A == "B")
  expect_equal(second_max$n, 2)

  # Error when all combinations have n=1
  df <- data.frame(
    TRT01A = c("A", "B", "C"),
    SAFFL = c("Y", "Y", "N")
  )
  expect_error(
    glimpse_treatment_flag(df),
    "All treatment/flag combinations have count = 1"
  )
})

test_that("glimpse_param_visits works correctly", {
  # S1 has ALT+AST at Wk1, S2 has ALT at Wk1, S3 has ALT at Wk1
  df <- data.frame(
    USUBJID = c("S1", "S1", "S2", "S3"),
    PARAM = c("ALT", "AST", "ALT", "ALT"),
    PARAMCD = c("ALT", "AST", "ALT", "ALT"),
    AVISIT = c("Week 1", "Week 1", "Week 1", "Week 1"),
    AVISITN = c(1, 1, 1, 1)
  )

  # AST/Week 1 has count=1 (only S1 has it), so it is masked
  expect_message(
    result <- glimpse_param_visits(
      df,
      id_cols = "USUBJID",
      param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
    ),
    "1 parameter/visit combination\\(s\\) with count = 1 were masked"
  )

  expect_s3_class(result, c("summary_param_visits", "summary"))

  # Only ALT/Week 1 survives masking (count=3)
  expect_equal(nrow(result[["unique_param_visits"]]), 1)
  expect_true("ALT" %in% result[["unique_param_visits"]]$PARAMCD)
  expect_false("AST" %in% result[["unique_param_visits"]]$PARAMCD)

  # No count column in unique_param_visits
  expect_false("n" %in% colnames(result[["unique_param_visits"]]))

  # Profiles: after masking AST, all 3 subjects share one profile (ALT/Week 1)
  expect_equal(length(result[["profiles"]]), 1)
  expect_equal(result[["profile_counts"]], 3)

  # The profile should contain only the surviving param/visit combo
  profile_df <- result[["profiles"]][[1]]
  expect_equal(nrow(profile_df), 1)
  expect_equal(profile_df$PARAMCD, "ALT")
})

test_that("glimpse_param_visits creates distinct profiles", {
  # S1-S2 have full profiles (ALT+AST), S3-S4 partial (ALT only)
  df <- data.frame(
    USUBJID = c("S1", "S1", "S2", "S2", "S3", "S4"),
    PARAM = c("ALT", "AST", "ALT", "AST", "ALT", "ALT"),
    PARAMCD = c("ALT", "AST", "ALT", "AST", "ALT", "ALT"),
    AVISIT = c("W1", "W1", "W1", "W1", "W1", "W1"),
    AVISITN = c(1, 1, 1, 1, 1, 1)
  )

  result <- suppressMessages(glimpse_param_visits(
    df,
    id_cols = "USUBJID",
    param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
  ))

  # Should have 2 deduplicated profiles: full (ALT+AST) and partial (ALT only)
  expect_equal(length(result[["profiles"]]), 2)
  expect_equal(result[["profile_counts"]], c(2, 2))
})

test_that("glimpse_param_visits keeps unique profile patterns", {
  # 6 subjects: S1-S3 have ALT+AST, S4-S5 have ALT only, S6 has AST only.
  # All param/visit combos have count >= 2 (ALT=5, AST=4), so none are
  # masked. Profile patterns: {ALT,AST} x3, {ALT} x2, {AST} x1 - the
  # row-level mask above already filtered rare cells, so we keep every
  # profile (no fingerprint-level masking).
  df <- data.frame(
    USUBJID = c(
      "S1", "S1", "S2", "S2", "S3", "S3", "S4", "S5", "S6"
    ),
    PARAM = c(
      "ALT", "AST", "ALT", "AST", "ALT", "AST", "ALT", "ALT", "AST"
    ),
    PARAMCD = c(
      "ALT", "AST", "ALT", "AST", "ALT", "AST", "ALT", "ALT", "AST"
    ),
    AVISIT = rep("W1", 9),
    AVISITN = rep(1, 9)
  )

  result <- glimpse_param_visits(
    df,
    id_cols = "USUBJID",
    param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
  )

  # All 3 distinct profiles survive: {ALT,AST} x3, {ALT} x2, {AST} x1
  expect_equal(length(result[["profiles"]]), 3)
  expect_equal(sum(result[["profile_counts"]]), 6)
  expect_setequal(result[["profile_counts"]], c(3, 2, 1))
})

test_that("glimpse_param_visits handles all-unique profile patterns", {
  # 3 subjects, each a different profile: ALT+AST, ALT, AST.
  # After param/visit masking: ALT count=2, AST count=2 (both survive).
  # Profile patterns are all unique - real longitudinal data commonly
  # looks like this and should glimpse without error.
  df <- data.frame(
    USUBJID = c("S1", "S1", "S2", "S3"),
    PARAM = c("ALT", "AST", "ALT", "AST"),
    PARAMCD = c("ALT", "AST", "ALT", "AST"),
    AVISIT = rep("W1", 4),
    AVISITN = rep(1, 4)
  )

  result <- glimpse_param_visits(
    df,
    id_cols = "USUBJID",
    param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
  )
  expect_equal(length(result[["profiles"]]), 3)
  expect_equal(result[["profile_counts"]], c(1, 1, 1))
})

test_that("glimpse_param_visits errors when all combos are singletons", {
  df <- data.frame(
    USUBJID = c("S1", "S2", "S3"),
    PARAM = c("ALT", "AST", "BILI"),
    PARAMCD = c("ALT", "AST", "BILI"),
    AVISIT = c("Week 1", "Week 1", "Week 1"),
    AVISITN = c(1, 1, 1)
  )

  expect_error(
    glimpse_param_visits(
      df,
      id_cols = "USUBJID",
      param_visit_cols = c("PARAM", "PARAMCD", "AVISIT", "AVISITN")
    ),
    "All parameter/visit combinations have count = 1"
  )
})

test_that("glimpse_params works correctly", {
  # Test with rare combinations - EVT1 appears twice, EVT2 and EVT3 once each
  df <- data.frame(
    PARAM = c("Event 1", "Event 1", "Event 2", "Event 3"),
    PARAMCD = c("EVT1", "EVT1", "EVT2", "EVT3")
  )

  # Masking: combinations with count=1 are filtered out
  expect_message(
    result <- glimpse_params(df),
    "2 parameter combination\\(s\\) with count = 1 were masked"
  )

  # Test basic functionality with the result
  expect_s3_class(result, c("summary_params", "summary"))
  expect_equal(nrow(result[["unique_params"]]), 1)
  expect_equal(result[["unique_params"]]$PARAMCD, "EVT1")

  # No count column in output
  expect_false("n" %in% colnames(result[["unique_params"]]))

  # Test with multiple columns (no rare combinations)
  df_multi <- data.frame(
    PARAM = c("A", "A", "B", "B"),
    PARAMCD = c("1", "1", "2", "2"),
    PARCAT1 = c("Cat1", "Cat1", "Cat2", "Cat2")
  )
  expect_silent(multi_result <- glimpse_params(df_multi))
  expect_equal(nrow(multi_result[["unique_params"]]), 2)
  expect_equal(
    colnames(multi_result[["unique_params"]]), c("PARAM", "PARAMCD", "PARCAT1")
  )

  # Error when all combinations have count=1
  df_all_rare <- data.frame(
    PARAM = c("Event 1", "Event 2", "Event 3"),
    PARAMCD = c("EVT1", "EVT2", "EVT3")
  )

  expect_error(
    glimpse_params(df_all_rare),
    "All parameter combinations have count = 1"
  )
})
