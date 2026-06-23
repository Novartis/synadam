# Test data: 5 subjects, 2 params (ALT, AST), 2 visits (Week 1, Week 2)
# Subjects 1-3 have full profiles (4 rows each)
# Subjects 4-5 have partial profiles (2 rows each, only ALT)
bds <- dplyr::tibble(
  STUDYID = "TEST001",
  USUBJID = c(
    rep("1", 4), rep("2", 4), rep("3", 4),
    rep("4", 2), rep("5", 2)
  ),
  TRT01A = c(
    rep("Drug A", 4), rep("Drug A", 4), rep("Drug B", 4),
    rep("Drug B", 2), rep("Drug A", 2)
  ),
  TRT01AN = c(
    rep(1, 4), rep(1, 4), rep(2, 4),
    rep(2, 2), rep(1, 2)
  ),
  SAFFL = "Y",
  PARAM = c(
    rep(c("ALT", "ALT", "AST", "AST"), 3),
    rep(c("ALT", "ALT"), 2)
  ),
  PARAMCD = c(
    rep(c("ALT", "ALT", "AST", "AST"), 3),
    rep(c("ALT", "ALT"), 2)
  ),
  AVISIT = c(
    rep(c("Week 1", "Week 2", "Week 1", "Week 2"), 3),
    rep(c("Week 1", "Week 2"), 2)
  ),
  AVISITN = c(
    rep(c(1, 2, 1, 2), 3),
    rep(c(1, 2), 2)
  ),
  AVAL = runif(16),
  ANL01FL = "Y"
)

syn_adsl <- dplyr::tibble(
  STUDYID = "TEST001",
  USUBJID = paste0("SYN_", 1:4),
  TRT01A = c("Drug A", "Drug A", "Drug B", "Drug B"),
  TRT01AN = c(1, 1, 2, 2),
  SAFFL = "Y",
  AGE = c(50, 55, 60, 65)
)

bds_summary <- suppressMessages(glimpse_bds(
  bds,
  syn_adsl,
  id_cols = "USUBJID",
  param_cols = c("PARAM", "PARAMCD"),
  visit_cols = c("AVISIT", "AVISITN"),
  flag_cols = "ANL01FL"
))

# BDS with ordered columns
bds_with_ordered <- dplyr::tibble(
  USUBJID = as.character(rep(1:4, each = 4)),
  PARAM = rep(c("A", "A", "B", "B"), 4),
  PARAMCD = rep(c("1", "1", "2", "2"), 4),
  VISIT = rep(c("V1", "V2"), 8),
  VISITN = rep(c(1, 2), 8),
  PARCAT1 = rep(c("Cat1", "Cat1", "Cat2", "Cat2"), 4),
  PARCAT1N = rep(c(1, 1, 2, 2), 4),
  ANL01FL = rep("Y", 16),
  AVAL = runif(16)
)

syn_adsl_simple <- dplyr::tibble(
  USUBJID = as.character(1:4)
)

bds_summary_with_ordered <- suppressMessages(glimpse_bds(
  bds_with_ordered,
  syn_adsl_simple,
  id_cols = "USUBJID",
  param_cols = c("PARAM", "PARAMCD"),
  visit_cols = c("VISIT", "VISITN"),
  flag_cols = "ANL01FL",
  ordered_col_sets = list(c("PARCAT1", "PARCAT1N"))
))

test_that("glimpse_bds works correctly with and without ordered_col_sets", {
  # Without ordered columns
  expected_names <- c(
    "param_visits",
    "adsl_cols",
    "AVAL",
    "ANL01FL"
  )
  expect_equal(names(bds_summary), expected_names)
  expect_s3_class(bds_summary, "summary_bds")

  # param_visits should contain profiles and unique_param_visits
  expect_true("profiles" %in% names(bds_summary[["param_visits"]]))
  expect_true("unique_param_visits" %in% names(bds_summary[["param_visits"]]))

  # Should have 2 deduplicated profiles (full x3, partial x2)
  expect_equal(length(bds_summary[["param_visits"]][["profiles"]]), 2)
  expect_equal(sum(bds_summary[["param_visits"]][["profile_counts"]]), 5)

  # With ordered columns
  expect_s3_class(bds_summary_with_ordered, "summary_bds")
  expect_s3_class(
    bds_summary_with_ordered[["PARCAT1_PARCAT1N"]],
    "summary_ordered"
  )
  expect_true("param_visits" %in% names(bds_summary_with_ordered))
  expect_true("adsl_cols" %in% names(bds_summary_with_ordered))
})

test_that("simulate_bds produces profile-based output", {
  syn_bds <- suppressMessages(simulate_bds(bds_summary, seed = 42))

  expect_s3_class(syn_bds, "data.frame")
  expect_equal(colnames(syn_bds), colnames(bds))

  # Each synthetic subject should have a valid profile (either 4 or 2 rows)
  subject_row_counts <- syn_bds |>
    dplyr::count(USUBJID) |>
    dplyr::pull(n)
  expect_true(all(subject_row_counts %in% c(4, 2)))

  # Total rows should be sum of assigned profile sizes
  expect_equal(nrow(syn_bds), sum(subject_row_counts))

  # Check all ADSL columns are taken from syn_adsl
  shared_cols <- colnames(syn_adsl)[colnames(syn_adsl) %in% colnames(syn_bds)]
  suppressMessages(
    expect_equal(
      dplyr::anti_join(
        syn_adsl |>
          dplyr::select(dplyr::one_of(shared_cols)) |>
          dplyr::distinct(),
        syn_bds |>
          dplyr::select(dplyr::one_of(shared_cols)) |>
          dplyr::distinct()
      ) |>
        nrow(),
      0
    )
  )

  # All param/visit combos in output should be from the original unique combos
  unique_pv <- bds_summary[["param_visits"]][["unique_param_visits"]]
  syn_pv <- syn_bds |>
    dplyr::select(PARAM, PARAMCD, AVISIT, AVISITN) |>
    dplyr::distinct()
  suppressMessages(
    expect_equal(
      nrow(dplyr::anti_join(syn_pv, unique_pv)),
      0
    )
  )

  # With ordered columns
  syn_bds_ordered <- suppressMessages(simulate_bds(bds_summary_with_ordered))
  expect_s3_class(syn_bds_ordered, "data.frame")
  expect_true("PARCAT1" %in% colnames(syn_bds_ordered))
  expect_true("PARCAT1N" %in% colnames(syn_bds_ordered))
})

test_that("simulate_bds is reproducible with seed", {
  suppressMessages({
    syn_bds_1 <- simulate_bds(bds_summary, seed = 123)
    syn_bds_2 <- simulate_bds(bds_summary, seed = 123)
    syn_bds_3 <- simulate_bds(bds_summary, seed = 456)
  })
  expect_equal(syn_bds_1, syn_bds_2)
  expect_false(isTRUE(all.equal(syn_bds_1, syn_bds_3)))
})

test_that("glimpse_bds works without optional cols", {
  # Test dataset with no visits, no flags, minimal structure
  bds_minimal <- dplyr::tibble(
    USUBJID = as.character(rep(1:4, each = 2)),
    PARAM = rep(c("Height", "Weight"), 4),
    PARAMCD = rep(c("HEIGHT", "WEIGHT"), 4),
    AVAL = runif(8)
  )

  syn_adsl_simple <- dplyr::tibble(
    USUBJID = as.character(1:4)
  )

  summary_minimal <- suppressMessages(glimpse_bds(
    bds_minimal,
    syn_adsl_simple,
    id_cols = "USUBJID",
    param_cols = c("PARAM", "PARAMCD")
    # visit_cols defaults to character()
    # flag_cols defaults to character()
    # ordered_col_sets defaults to list()
  ))

  expect_s3_class(summary_minimal, "summary_bds")
  expect_true("param_visits" %in% names(summary_minimal))

  # All 4 subjects share one profile → 1 deduplicated profile, count = 4
  expect_equal(length(summary_minimal[["param_visits"]][["profiles"]]), 1)
  expect_equal(summary_minimal[["param_visits"]][["profile_counts"]], 4)

  # AVAL should be treated as regular column, not flag
  expect_true("AVAL" %in% names(summary_minimal))
  expect_s3_class(summary_minimal[["AVAL"]], "summary_double")

  # Test simulation works for minimal case
  syn_bds_minimal <- suppressMessages(simulate_bds(summary_minimal))
  expect_s3_class(syn_bds_minimal, "data.frame")
  expect_equal(nrow(syn_bds_minimal), 8) # 4 subjects × 2 params
  expect_equal(colnames(syn_bds_minimal), colnames(bds_minimal))
  expect_false(any(grepl("VISIT", colnames(syn_bds_minimal))))
  expect_false(any(grepl("FL$", colnames(syn_bds_minimal))))
})

test_that("glimpse_bds errors when SUBJID in data is missing from id_cols", {
  bds_with_subjid <- dplyr::tibble(
    USUBJID = as.character(rep(1:4, each = 2)),
    SUBJID = as.character(rep(1:4, each = 2)),
    PARAM = rep(c("A", "B"), 4),
    PARAMCD = rep(c("A", "B"), 4),
    AVAL = runif(8)
  )
  syn_adsl_ids <- dplyr::tibble(
    USUBJID = as.character(1:4),
    SUBJID = as.character(1:4)
  )

  # SUBJID present in data but omitted from id_cols -> error
  expect_error(
    suppressMessages(glimpse_bds(
      bds_with_subjid,
      syn_adsl_ids,
      id_cols = "USUBJID",
      param_cols = c("PARAM", "PARAMCD")
    )),
    "missing from"
  )
})
