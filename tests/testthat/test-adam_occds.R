# Test data setup - ADAE-like structure
syn_adsl <- dplyr::tibble(
  STUDYID = rep("STUDY01", 5),
  USUBJID = as.character(1:5),
  TRT01A = c("Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
  TRT01AN = c(1, 1, 2, 2, 2),
  SAFFL = c(rep("Y", 4), "N"),
  AGE = as.numeric(55:59)
)

# ADAE with variable occurrences per subject
adae <- dplyr::tibble(
  # Shared cols with ADSL
  STUDYID = rep("STUDY01", 10),
  USUBJID = c("1", "1", "2", "3", "3", "3", "4", "4", "5", "5"),
  TRT01A = c(
    "Placebo", "Placebo", "Placebo",
    "Drug A", "Drug A", "Drug A",
    "Drug A", "Drug A",
    "Drug A", "Drug A"
  ),
  TRT01AN = c(1, 1, 1, 2, 2, 2, 2, 2, 2, 2),
  SAFFL = c(rep("Y", 8), "N", "N"),
  # Sequence column

  AESEQ = c(1, 2, 1, 1, 2, 3, 1, 2, 1, 2),
  # Dictionary columns (MedDRA hierarchy)
  AEBODSYS = c(
    "Gastrointestinal disorders", "Nervous system disorders",
    "Gastrointestinal disorders",
    "Nervous system disorders", "Nervous system disorders",
    "Gastrointestinal disorders",
    "Skin disorders", "Skin disorders",
    "Gastrointestinal disorders", "Nervous system disorders"
  ),
  AEDECOD = c(
    "Nausea", "Headache",
    "Vomiting",
    "Headache", "Dizziness", "Nausea",
    "Rash", "Pruritus",
    "Nausea", "Headache"
  ),
  # Derived flags (should all become "Y" in output)
  AOCCFL = c("Y", NA, "Y", "Y", NA, NA, "Y", NA, "Y", NA),
  AOCCSFL = c("Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y"),
  TRTEMFL = c("Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y", "Y"),
  # Regular flag (should be simulated)
  AESER = c("N", "N", "N", "Y", "N", "N", "N", "N", "N", "N"),
  # Regular columns
  ASTDT = as.Date("2024-01-01") + 1:10,
  AENDT = as.Date("2024-01-01") + 11:20,
  ASEV = c(
    "MILD", "MILD", "MODERATE", "SEVERE", "MILD",
    "MILD", "MILD", "MILD", "MODERATE", "MILD"
  )
)

# Create OCCDS summary for testing
occds_summary <- suppressMessages(glimpse_occds(
  adae,
  syn_adsl,
  id_cols = "USUBJID",
  seq_col = "AESEQ",
  flag_cols = c("AOCCFL", "AOCCSFL", "TRTEMFL", "AESER"),
  ordered_col_sets = list(c("AEBODSYS", "AEDECOD"))
))

test_that("glimpse_occds works correctly", {
  # Returns correct summary structure
  expected_names <- c(
    "occurrence_id_seq",
    "adsl_cols",
    "AEBODSYS_AEDECOD",
    "AOCCFL",
    "AOCCSFL",
    "TRTEMFL",
    "AESER",
    "ASTDT",
    "AENDT",
    "ASEV"
  )
  expect_true(all(expected_names %in% names(occds_summary)))
  expect_s3_class(occds_summary, "summary_occds")

  # Captures occurrence count
  occ_id_seq <- occds_summary[["occurrence_id_seq"]]
  expect_s3_class(occ_id_seq, "summary_occurrence_id_seq")
  # Original data has: subject 1->2, 2->1, 3->3, 4->2, 5->2 occurrences
  expect_equal(sort(occ_id_seq[["counts"]]), c(1, 2, 2, 2, 3))
  expect_equal(occ_id_seq[["id_cols"]], "USUBJID")
  expect_equal(occ_id_seq[["seq_col"]], "AESEQ")

  # Stores ADSL columns correctly
  adsl_cols <- occds_summary[["adsl_cols"]]
  expect_s3_class(adsl_cols, "data.frame")
  shared <- intersect(colnames(adae), colnames(syn_adsl))
  expect_equal(sort(colnames(adsl_cols)), sort(shared))
  expect_equal(nrow(adsl_cols), nrow(syn_adsl))

  # Handles ordered column sets correctly
  ordered_summary <- occds_summary[["AEBODSYS_AEDECOD"]]
  expect_s3_class(ordered_summary, "summary_ordered")
  unique_combos <- ordered_summary[["unique_combinations"]]
  expect_equal(ncol(unique_combos), 2)
  expect_true(all(c("AEBODSYS", "AEDECOD") %in% colnames(unique_combos)))

  # Stores flag columns as summary_flag elements
  flag_names <- c("AOCCFL", "AOCCSFL", "TRTEMFL", "AESER")
  for (flag_name in flag_names) {
    expect_s3_class(occds_summary[[flag_name]], "summary_flag")
    expect_equal(occds_summary[[flag_name]][["col_name"]], flag_name)
  }

  # Stores ID and seq columns in occurrence_id_seq
  expect_equal(occ_id_seq[["id_cols"]], "USUBJID")
  expect_equal(occ_id_seq[["seq_col"]], "AESEQ")

  # Preserves column order
  col_order <- attr(occds_summary, "col_order")
  expect_equal(col_order, colnames(adae))
})

test_that("simulate_occds works correctly", {
  syn_occds <- suppressMessages(simulate_occds(occds_summary, seed = 123))

  # Produces valid output
  expect_s3_class(syn_occds, "data.frame")

  # Column names should match original (in same order)
  expect_equal(colnames(syn_occds), colnames(adae))

  # Replicates ADSL columns correctly
  # All USUBJID values should come from syn_adsl
  expect_true(all(syn_occds$USUBJID %in% syn_adsl$USUBJID))

  # ADSL columns should be consistent within each subject
  shared_cols <- intersect(colnames(adae), colnames(syn_adsl))
  for (col in shared_cols) {
    by_subject <- syn_occds |>
      dplyr::group_by(USUBJID) |>
      dplyr::summarise(n_unique = dplyr::n_distinct(.data[[col]]))
    expect_true(all(by_subject$n_unique == 1))
  }

  # Generates sequence column correctly
  # Sequence should start at 1 for each subject and increment
  seq_check <- syn_occds |>
    dplyr::group_by(USUBJID) |>
    dplyr::summarise(
      min_seq = min(AESEQ),
      max_seq = max(AESEQ),
      n_rows = dplyr::n()
    )

  expect_true(all(seq_check$min_seq == 1))
  expect_true(all(seq_check$max_seq == seq_check$n_rows))

  # Flag columns with prop_y = 1 are all Y
  expect_true(all(syn_occds$AOCCFL == "Y"))
  expect_true(all(syn_occds$AOCCSFL == "Y"))
  expect_true(all(syn_occds$TRTEMFL == "Y"))
  # AESER has prop_y = 0.1, so output contains Y and N
  expect_true(all(syn_occds$AESER %in% c("Y", "N")))

  # Preserves valid dictionary combinations
  # Get original unique combinations
  original_combos <- adae |>
    dplyr::select(AEBODSYS, AEDECOD) |>
    dplyr::distinct()

  # Get synthetic combinations
  syn_combos <- syn_occds |>
    dplyr::select(AEBODSYS, AEDECOD) |>
    dplyr::distinct()

  # All synthetic combinations should be valid (subset of original)
  joined <- dplyr::semi_join(syn_combos, original_combos,
    by = c("AEBODSYS", "AEDECOD")
  )
  expect_equal(nrow(joined), nrow(syn_combos))

  # Samples from occurrence count distribution
  # Run multiple times to check distribution is being sampled
  syn_occds_1 <- suppressMessages(simulate_occds(occds_summary, seed = 32))
  syn_occds_2 <- suppressMessages(simulate_occds(occds_summary, seed = 42))

  # Each subject should have between 1 and max(original counts) occurrences
  original_max <- max(table(adae$USUBJID))
  counts_1 <- table(syn_occds_1$USUBJID)
  expect_true(all(counts_1 >= 1))
  expect_true(all(counts_1 <= original_max))
})

test_that("simulate_occds is reproducible with seed", {
  suppressMessages({
    syn_occds_1 <- simulate_occds(occds_summary, seed = 123)
    syn_occds_2 <- simulate_occds(occds_summary, seed = 123)
    syn_occds_3 <- simulate_occds(occds_summary, seed = 456)
  })
  expect_equal(syn_occds_1, syn_occds_2)
  expect_false(isTRUE(all.equal(syn_occds_1, syn_occds_3)))
})

test_that("glimpse_occds works with ADCM-like data", {
  adcm <- dplyr::tibble(
    STUDYID = rep("STUDY01", 6),
    USUBJID = c("1", "1", "2", "3", "3", "4"),
    TRT01A = c("Placebo", "Placebo", "Placebo", "Drug A", "Drug A", "Drug A"),
    CMSEQ = c(1, 2, 1, 1, 2, 1),
    CMDECOD = c(
      "Aspirin", "Ibuprofen", "Aspirin", "Paracetamol", "Aspirin", "Ibuprofen"
    ),
    CMCLAS = c(
      "Analgesic", "Analgesic", "Analgesic",
      "Analgesic", "Analgesic", "Analgesic"
    ),
    ONTRTFL = c("Y", "Y", "Y", "Y", "Y", NA),
    ASTDT = as.Date("2024-01-01") + 1:6
  )

  adcm_summary <- suppressMessages(glimpse_occds(
    adcm,
    syn_adsl,
    id_cols = "USUBJID",
    seq_col = "CMSEQ",
    flag_cols = "ONTRTFL",
    ordered_col_sets = list(c("CMDECOD", "CMCLAS"))
  ))

  expect_s3_class(adcm_summary, "summary_occds")
  expect_equal(adcm_summary[["occurrence_id_seq"]][["seq_col"]], "CMSEQ")
  expect_equal(adcm_summary[["occurrence_id_seq"]][["id_cols"]], "USUBJID")

  syn_adcm <- suppressMessages(simulate_occds(adcm_summary, seed = 42))
  expect_s3_class(syn_adcm, "data.frame")
  expect_equal(colnames(syn_adcm), colnames(adcm))
  # Flag should be all "Y"
  expect_true(all(syn_adcm$ONTRTFL == "Y"))
})

test_that("glimpse_occds errors when SUBJID in data is missing from id_cols", {
  syn_adsl_ids <- dplyr::tibble(
    USUBJID = as.character(1:3),
    SUBJID = as.character(1:3)
  )
  adae_with_subjid <- dplyr::tibble(
    USUBJID = c("1", "1", "2", "3"),
    SUBJID = c("1", "1", "2", "3"),
    AESEQ = c(1, 2, 1, 1),
    ASEV = c("MILD", "MODERATE", "MILD", "SEVERE")
  )

  # SUBJID present in data but omitted from id_cols -> error
  expect_error(
    suppressMessages(glimpse_occds(
      adae_with_subjid,
      syn_adsl_ids,
      id_cols = "USUBJID",
      seq_col = "AESEQ"
    )),
    "missing from"
  )
})
