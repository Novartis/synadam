# Test data setup
tte <- dplyr::tibble(
  # Shared cols with ADSL
  STUDYID = as.character(rep(1, 6)),
  USUBJID = as.character(rep(1:3, each = 2)),
  TRT01A = rep(c("Placebo", "Drug A"), 3),
  TRT01AN = rep(c(1, 2), 3),
  SAFFL = rep("Y", 6),
  # Param cols
  PARAM = rep(
    c("Overall Survival (days)", "Progression Free Survival (days)"), 3
  ),
  PARAMCD = rep(c("OS", "PFS"), 3),
  # Censor cols
  CNSR = c(0, 1, 0, 2, 1, 0),
  EVNTDESC = c(
    "DEATH", "COMPLETED STUDY", "DEATH", "NEW ANTI-CANCER THERAPY",
    "COMPLETED STUDY", "DOCUMENTED PROGRESSION"
  ),
  CNSDTDSC = c(NA, NA, NA, "LAST RADIOLOGIC ASSESSMENT", NA, NA),
  # Other columns
  AVAL = c(365.0, 500.0, 180.0, 250.0, 600.0, 120.0),
  STARTDT = as.Date(c(
    "2020-01-01", "2020-01-01", "2020-02-01",
    "2020-02-01", "2020-03-01", "2020-03-01"
  )),
  ADT = as.Date(c(
    "2021-01-01", "2021-05-15", "2020-07-01",
    "2020-09-07", "2021-09-16", "2020-06-29"
  )),
  # Optional columns
  ANL01FL = rep("Y", 6),
  SRCDOM = c("ADSL", "ADRS", "ADSL", "ADRS", "ADRS", "ADRS"),
  SRCVAR = c("DTHDT", "ADT", "DTHDT", "ADT", "ADT", "ADT")
)

syn_adsl <- dplyr::tibble(
  STUDYID = as.character(rep(1, 5)),
  USUBJID = as.character(1:5),
  TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
  TRT01AN = c(1, 1, 2, 2, 2),
  SAFFL = c(rep("Y", 4), "N"),
  AGE = as.numeric(55:59)
)

tte_summary <- suppressMessages(glimpse_tte(
  tte,
  syn_adsl,
  param_cols = c("PARAM", "PARAMCD"),
  censor_cols = c("CNSR", "EVNTDESC", "CNSDTDSC"),
  flag_cols = "ANL01FL",
  ordered_col_sets = list(c("SRCDOM", "SRCVAR"))
))

test_that("glimpse_tte works correctly with optional columns", {
  expected_names <- c(
    "params",
    "adsl_cols",
    "censor",
    "SRCDOM_SRCVAR",
    "AVAL",
    "STARTDT",
    "ADT",
    "ANL01FL"
  )
  expect_equal(names(tte_summary), expected_names)
  expect_s3_class(tte_summary, "summary_tte")
  expect_s3_class(tte_summary[["params"]], "summary_params")
  expect_s3_class(tte_summary[["censor"]], "summary_ordered")
  expect_s3_class(tte_summary[["SRCDOM_SRCVAR"]], "summary_ordered")
  expect_s3_class(tte_summary[["ANL01FL"]], "summary_flag")

  # Check that all PARAMCDs from input are captured (no filtering)
  unique_params <- tte_summary[["params"]][["unique_params"]]
  expect_equal(nrow(unique_params), 2) # OS and PFS
  expect_setequal(unique_params$PARAMCD, c("OS", "PFS"))
})

test_that("simulate_tte works correctly", {
  syn_tte <- suppressMessages(simulate_tte(tte_summary))

  expect_s3_class(syn_tte, "data.frame")
  # Expected rows = n_params × n_subjects = 2 × 5 = 10
  expected_nrows <- nrow(tte_summary[["params"]][["unique_params"]]) *
    nrow(tte_summary[["adsl_cols"]])
  expect_equal(nrow(syn_tte), expected_nrows)
  expect_equal(colnames(syn_tte), colnames(tte))

  # Check all ADSL columns are taken from the ADSL
  shared_cols <- colnames(syn_adsl)[colnames(syn_adsl) %in% colnames(syn_tte)]
  suppressMessages(
    expect_equal(
      dplyr::anti_join(
        syn_adsl |>
          dplyr::select(dplyr::one_of(shared_cols)) |>
          dplyr::distinct(),
        syn_tte |>
          dplyr::select(dplyr::one_of(shared_cols)) |>
          dplyr::distinct()
      ) |>
        nrow(),
      0
    )
  )

  # Check optional columns are present
  expect_true("ANL01FL" %in% colnames(syn_tte))
  expect_true("SRCDOM" %in% colnames(syn_tte))
  expect_true("SRCVAR" %in% colnames(syn_tte))

  # Check one row per subject per parameter (defining TTE constraint)
  counts <- syn_tte |>
    dplyr::count(USUBJID, PARAMCD) |>
    dplyr::pull(n)
  expect_true(all(counts == 1))

  # Check censor column co-occurrence is preserved
  original_combos <- tte |>
    dplyr::select(CNSR, EVNTDESC, CNSDTDSC) |>
    dplyr::distinct()

  synthetic_combos <- syn_tte |>
    dplyr::select(CNSR, EVNTDESC, CNSDTDSC) |>
    dplyr::distinct()

  # Every synthetic combo should exist in original
  suppressMessages(
    expect_equal(
      dplyr::anti_join(synthetic_combos, original_combos) |>
        nrow(),
      0
    )
  )
})

test_that("simulate_tte is reproducible with seed", {
  suppressMessages({
    syn_tte_1 <- simulate_tte(tte_summary, seed = 123)
    syn_tte_2 <- simulate_tte(tte_summary, seed = 123)
    syn_tte_3 <- simulate_tte(tte_summary, seed = 456)
  })
  expect_equal(syn_tte_1, syn_tte_2)
  expect_false(isTRUE(all.equal(syn_tte_1, syn_tte_3)))
})

test_that("glimpse_tte works without censor_cols", {
  tte_summary_no_censor <- suppressMessages(glimpse_tte(
    tte,
    syn_adsl,
    param_cols = c("PARAM", "PARAMCD"),
    flag_cols = "ANL01FL",
    ordered_col_sets = list(c("SRCDOM", "SRCVAR"))
  ))

  expect_s3_class(tte_summary_no_censor, "summary_tte")
  # Censor columns should be glimpsed as regular columns, not as ordered set
  expect_null(tte_summary_no_censor[["censor"]])

  syn_tte <- suppressMessages(simulate_tte(tte_summary_no_censor))
  expect_s3_class(syn_tte, "data.frame")
  expect_equal(colnames(syn_tte), colnames(tte))
  # CNSR should still be present as a regular column
  expect_true("CNSR" %in% colnames(syn_tte))
})

test_that("glimpse_tte validates inputs correctly", {
  # Missing param_cols
  expect_error(
    glimpse_tte(
      tte,
      syn_adsl,
      param_cols = character(),
      censor_cols = c("CNSR", "EVNTDESC", "CNSDTDSC")
    ),
    "param_cols"
  )

  # param_cols not in dataset
  expect_error(
    glimpse_tte(
      tte,
      syn_adsl,
      param_cols = c("PARAM", "MISSING_COL"),
      censor_cols = c("CNSR", "EVNTDESC", "CNSDTDSC")
    ),
    "MISSING_COL"
  )

  # PARAMCD not in param_cols
  expect_error(
    glimpse_tte(
      tte,
      syn_adsl,
      param_cols = c("PARAM"),
      censor_cols = c("CNSR", "EVNTDESC", "CNSDTDSC")
    ),
    "PARAMCD"
  )

  # No shared columns between tte and syn_adsl
  bad_adsl <- dplyr::tibble(NOTUSUBJID = 1:3)
  expect_error(
    glimpse_tte(
      tte,
      bad_adsl,
      param_cols = c("PARAM", "PARAMCD"),
      censor_cols = c("CNSR", "EVNTDESC", "CNSDTDSC")
    )
  )
})
