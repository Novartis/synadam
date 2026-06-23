adsl <- dplyr::tibble(
  USUBJID = as.character(1:6),
  TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A", "Drug A"),
  TRT01AN = c(1, 1, 2, 2, 2, 2),
  SAFFL = c(rep("Y", 4), "N", "N"),
  AGE = as.numeric(55:60),
  REGION1 = c(rep("USA", 4), rep("UK", 2)),
  REGION1N = c(rep(1, 4), rep(2, 2)),
  character = rep("A", 6),
  double = c(1.0, 1.5, 2.0, 2.5, 3.0, 3.5),
  integer = 1:6,
  date = as.Date(1:6),
  posixct = as.POSIXct(1:6),
  difftime = as.difftime(1:6, units = "secs"),
  character_na = as.character(rep(NA, 6)),
  difftime_na = as.difftime(rep(NA_real_, 6), units = "secs"),
)

adsl_summary <- suppressMessages(glimpse_adsl(
  adsl,
  id_cols = "USUBJID",
  treatment_cols = c("TRT01A", "TRT01AN"),
  flag_cols = "SAFFL",
  ordered_col_sets = list(c("REGION1", "REGION1N"))
))

test_that("glimpse_adsl works correctly", {
  expect_s3_class(adsl_summary, "summary_adsl")
  expect_s3_class(adsl_summary[["USUBJID"]], "summary_id")
  expect_s3_class(adsl_summary[["treatment_flag"]], "summary_treatment_flag")
  expect_s3_class(adsl_summary[["AGE"]], "summary_integer")
  expect_s3_class(adsl_summary[["REGION1_REGION1N"]], "summary_ordered")
  expect_s3_class(adsl_summary[["character"]], "summary_character")
  expect_s3_class(adsl_summary[["date"]], "summary_Date")
  expect_s3_class(adsl_summary[["posixct"]], "summary_POSIXct")
  expect_s3_class(adsl_summary[["difftime"]], "summary_difftime")
  expect_s3_class(adsl_summary[["integer"]], "summary_integer")
  expect_s3_class(adsl_summary[["double"]], "summary_double")
})

test_that("simulate_adsl works correctly", {
  syn_adsl <- suppressMessages(simulate_adsl(adsl_summary))

  expect_s3_class(syn_adsl, "data.frame")
  expect_equal(nrow(syn_adsl), nrow(adsl))
  expect_equal(colnames(syn_adsl), colnames(adsl))

  expect_true(all(grepl("^USUBJID_", syn_adsl[["USUBJID"]])))

  # Check treatment-flag combinations are preserved exactly
  original_counts <- adsl |>
    dplyr::count(TRT01A, TRT01AN, SAFFL) |>
    dplyr::arrange(TRT01A, TRT01AN, SAFFL)
  syn_counts <- syn_adsl |>
    dplyr::count(TRT01A, TRT01AN, SAFFL) |>
    dplyr::arrange(TRT01A, TRT01AN, SAFFL)
  expect_equal(original_counts, syn_counts)

  # Check ordered col combinations are preserved
  suppressMessages(
    expect_equal(
      dplyr::anti_join(
        syn_adsl |> dplyr::select(REGION1, REGION1N) |> dplyr::distinct(),
        adsl |> dplyr::select(REGION1, REGION1N) |> dplyr::distinct()
      ) |>
        nrow(),
      0
    )
  )
})

test_that("simulate_adsl is reproducible with seed", {
  suppressMessages({
    syn_adsl_1 <- simulate_adsl(adsl_summary, seed = 123)
    syn_adsl_2 <- simulate_adsl(adsl_summary, seed = 123)
    syn_adsl_3 <- simulate_adsl(adsl_summary, seed = 456)
  })

  expect_equal(syn_adsl_1, syn_adsl_2)
  expect_false(isTRUE(all.equal(syn_adsl_1, syn_adsl_3)))
})

test_that("glimpse_adsl works with no ordered_col_sets (default)", {
  # Create simple ADSL without ordered columns
  simple_adsl <- dplyr::tibble(
    USUBJID = as.character(1:4),
    TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
    TRT01AN = c(1, 1, 2, 2),
    SAFFL = c("Y", "Y", "Y", "N"),
    AGE = c(55, 60, 58, 62)
  )

  # Should work without specifying ordered_col_sets
  summary <- suppressMessages(glimpse_adsl(
    simple_adsl,
    id_cols = "USUBJID",
    treatment_cols = c("TRT01A", "TRT01AN"),
    flag_cols = "SAFFL"
  ))

  expect_s3_class(summary, "summary_adsl")
  expect_s3_class(summary[["USUBJID"]], "summary_id")
  expect_s3_class(summary[["treatment_flag"]], "summary_treatment_flag")
  expect_s3_class(summary[["AGE"]], "summary_integer")

  # Simulate should work
  syn_adsl <- suppressMessages(simulate_adsl(summary))
  expect_s3_class(syn_adsl, "data.frame")
  expect_equal(nrow(syn_adsl), nrow(simple_adsl))
  expect_equal(colnames(syn_adsl), colnames(simple_adsl))
})

test_that("glimpse_adsl errors when SUBJID in data is missing from id_cols", {
  adsl_with_subjid <- dplyr::tibble(
    USUBJID = as.character(1:4),
    SUBJID = as.character(1:4),
    TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
    TRT01AN = c(1, 1, 2, 2)
  )

  # SUBJID present in data but omitted from id_cols -> error
  expect_error(
    suppressMessages(glimpse_adsl(
      adsl_with_subjid,
      id_cols = "USUBJID",
      treatment_cols = c("TRT01A", "TRT01AN")
    )),
    "missing from"
  )
})

test_that("glimpse_adsl works with empty flag_cols", {
  adsl_no_flags <- dplyr::tibble(
    USUBJID = as.character(1:4),
    TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A"),
    TRT01AN = c(1, 1, 2, 2),
    AGE = c(25, 35, 45, 55)
  )

  # Should work without flag_cols
  summary <- suppressMessages(glimpse_adsl(
    adsl_no_flags,
    id_cols = "USUBJID",
    treatment_cols = c("TRT01A", "TRT01AN")
    # flag_cols defaults to character()
  ))

  expect_s3_class(summary, "summary_adsl")
  expect_equal(attr(summary, "output_length"), 4)
  expect_true("treatment_flag" %in% names(summary))

  # Should only have treatment columns in treatment_flag (no flag columns)
  treatment_flag_colnames <- colnames(
    summary[["treatment_flag"]][["treatment_flag_counts"]]
  )
  expect_setequal(treatment_flag_colnames, c("TRT01A", "TRT01AN", "n"))

  # Test simulation works
  syn_adsl <- suppressMessages(simulate_adsl(summary))
  expect_s3_class(syn_adsl, "data.frame")
  expect_equal(nrow(syn_adsl), 4)
  expect_equal(colnames(syn_adsl), colnames(adsl_no_flags))
  expect_false(any(grepl("FL$", colnames(syn_adsl)))) # No flag columns
})
