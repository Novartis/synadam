test_that("simulate_study() works with ADSL only", {
  # Create test ADSL data
  adsl <- dplyr::tibble(
    USUBJID = as.character(1:5),
    STUDYID = "TEST001",
    TRT01A = rep(c("Treatment A", "Treatment B"), length.out = 5),
    TRT01AN = rep(c(1, 2), length.out = 5),
    SAFFL = rep(c("Y", "N"), length.out = 5),
    ITTFL = rep(c("Y", "Y", "N"), length.out = 5),
    AGE = c(25, 35, 45, 55, 65),
    REGION1 = c("NA", "EU", "NA", "ASIA", "EU"),
    REGION1N = c(1, 2, 1, 3, 2)
  )
  adsl_path <- file.path(tempdir(), "adsl.sas7bdat")
  suppressWarnings(haven::write_sas(adsl, adsl_path))

  # Create required yaml configuration
  output_dir <- file.path(tempdir(), "test_output_adsl_only")
  config <- list(
    output_dir = output_dir,
    seed = 123,
    datasets = list(
      adsl = list(
        dataset_type = "adsl",
        path = adsl_path,
        id_cols = list("USUBJID"),
        treatment_cols = list("TRT01A", "TRT01AN"),
        flag_cols = list("SAFFL", "ITTFL"),
        ordered_col_sets = list(list("REGION1", "REGION1N"))
      )
    )
  )
  config_path <- file.path(tempdir(), "config.yaml")
  yaml::write_yaml(config, config_path)

  result <- suppressMessages(simulate_study(config_path))

  # Check return value is NULL invisibly
  expect_null(result)

  # Check individual file exists
  syn_adsl_path <- file.path(output_dir, "syn_adsl.rds")
  expect_true(file.exists(syn_adsl_path))
  expect_false(file.exists(file.path(output_dir, "summary_adsl.rds")))

  # Read back and verify
  syn_adsl <- readRDS(syn_adsl_path)
  expect_s3_class(syn_adsl, "data.frame")
  expect_equal(nrow(syn_adsl), nrow(adsl))
  expect_equal(colnames(syn_adsl), colnames(adsl))

  # Check version attribute
  expect_equal(
    attr(syn_adsl, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
})

test_that("simulate_study() works with ADSL + BDS + OCCDS + TTE", {
  # Create test ADSL
  adsl <- dplyr::tibble(
    USUBJID = as.character(1:4),
    STUDYID = "TEST001",
    TRT01A = rep(c("Treatment A", "Treatment B"), each = 2),
    TRT01AN = rep(c(1, 2), each = 2),
    SAFFL = rep(c("Y", "Y"), 2)
  )

  # Create test BDS datasets
  adlb <- dplyr::tibble(
    USUBJID = rep(as.character(1:4), each = 2),
    STUDYID = "TEST001",
    PARAM = rep("Alanine Aminotransferase", 8),
    PARAMCD = rep("ALT", 8),
    AVISIT = rep(c("Baseline", "Week 4"), 4),
    AVISITN = rep(c(0, 4), 4),
    AVAL = c(25, 30, 28, 32, 27, 29, 26, 31),
    ANL01FL = "Y"
  )

  advs <- dplyr::tibble(
    USUBJID = rep(as.character(1:4), each = 2),
    STUDYID = "TEST001",
    PARAM = rep("Weight", 8),
    PARAMCD = rep("WEIGHT", 8),
    AVISIT = rep(c("Baseline", "Week 4"), 4),
    AVISITN = rep(c(0, 4), 4),
    AVAL = c(70, 71, 85, 84, 75, 76, 80, 81),
    ANL01FL = "Y"
  )

  # Create test OCCDS dataset
  adae <- dplyr::tibble(
    USUBJID = c("1", "1", "2", "3", "3", "4"),
    STUDYID = "TEST001",
    TRT01A = rep(c("Treatment A", "Treatment B"), c(3, 3)),
    TRT01AN = rep(c(1, 2), c(3, 3)),
    SAFFL = "Y",
    AESEQ = c(1, 2, 1, 1, 2, 1),
    AEBODSYS = c(
      "Gastrointestinal disorders", "Nervous system disorders",
      "Gastrointestinal disorders", "Nervous system disorders",
      "Nervous system disorders", "Skin disorders"
    ),
    AEDECOD = c(
      "Nausea", "Headache", "Vomiting", "Headache", "Dizziness", "Rash"
    ),
    AOCCFL = "Y",
    TRTEMFL = "Y"
  )

  # Create test TTE dataset
  adtte <- dplyr::tibble(
    USUBJID = as.character(1:4),
    STUDYID = "TEST001",
    PARAM = rep("Overall Survival", 4),
    PARAMCD = rep("OS", 4),
    AVAL = c(365, 500, 250, 400),
    CNSR = c(0, 1, 0, 1),
    EVNTDESC = c("Death", "Censored", "Death", "Censored"),
    CNSDTDSC = c("", "Last Contact", "", "Study End"),
    ANL01FL = "Y"
  )

  # Save datasets as sas files
  adsl_path <- file.path(tempdir(), "adsl_multi.sas7bdat")
  adlb_path <- file.path(tempdir(), "adlb_multi.sas7bdat")
  advs_path <- file.path(tempdir(), "advs_multi.sas7bdat")
  adae_path <- file.path(tempdir(), "adae_multi.sas7bdat")
  adtte_path <- file.path(tempdir(), "adtte_multi.sas7bdat")
  suppressWarnings(haven::write_sas(adsl, adsl_path))
  suppressWarnings(haven::write_sas(adlb, adlb_path))
  suppressWarnings(haven::write_sas(advs, advs_path))
  suppressWarnings(haven::write_sas(adae, adae_path))
  suppressWarnings(haven::write_sas(adtte, adtte_path))

  # Create YAML configuration
  output_dir <- file.path(tempdir(), "test_output_multi")
  config <- list(
    output_dir = output_dir,
    seed = 32,
    datasets = list(
      adsl = list(
        dataset_type = "adsl",
        path = adsl_path,
        id_cols = list("USUBJID"),
        treatment_cols = list("TRT01A", "TRT01AN"),
        flag_cols = list("SAFFL"),
        ordered_col_sets = list()
      ),
      adlb = list(
        dataset_type = "bds",
        path = adlb_path,
        id_cols = list("USUBJID"),
        param_cols = list("PARAM", "PARAMCD"),
        visit_cols = list("AVISIT", "AVISITN"),
        flag_cols = list("ANL01FL")
      ),
      advs = list(
        dataset_type = "bds",
        path = advs_path,
        id_cols = list("USUBJID"),
        param_cols = list("PARAM", "PARAMCD"),
        visit_cols = list("AVISIT", "AVISITN"),
        flag_cols = list("ANL01FL")
      ),
      adae = list(
        dataset_type = "occds",
        path = adae_path,
        id_cols = list("USUBJID"),
        seq_col = "AESEQ",
        flag_cols = list("AOCCFL", "TRTEMFL"),
        ordered_col_sets = list(list("AEBODSYS", "AEDECOD"))
      ),
      adtte = list(
        dataset_type = "tte",
        path = adtte_path,
        param_cols = list("PARAM", "PARAMCD"),
        censor_cols = list("CNSR", "EVNTDESC", "CNSDTDSC"),
        flag_cols = list("ANL01FL"),
        ordered_col_sets = list()
      )
    )
  )
  config_path <- file.path(tempdir(), "config_multi.yaml")
  yaml::write_yaml(config, config_path)

  # Run simulate_study
  result <- suppressMessages(simulate_study(config_path))

  # Check return value is NULL
  expect_null(result)

  # Check individual files exist
  expect_true(file.exists(file.path(output_dir, "syn_adsl.rds")))
  expect_true(file.exists(file.path(output_dir, "syn_adlb.rds")))
  expect_true(file.exists(file.path(output_dir, "syn_advs.rds")))
  expect_true(file.exists(file.path(output_dir, "syn_adae.rds")))
  expect_true(file.exists(file.path(output_dir, "syn_adtte.rds")))

  # Read back and verify
  syn_adsl <- readRDS(file.path(output_dir, "syn_adsl.rds"))
  syn_adlb <- readRDS(file.path(output_dir, "syn_adlb.rds"))
  syn_advs <- readRDS(file.path(output_dir, "syn_advs.rds"))
  syn_adae <- readRDS(file.path(output_dir, "syn_adae.rds"))
  syn_adtte <- readRDS(file.path(output_dir, "syn_adtte.rds"))

  expect_s3_class(syn_adsl, "data.frame")
  expect_s3_class(syn_adlb, "data.frame")
  expect_s3_class(syn_advs, "data.frame")
  expect_s3_class(syn_adae, "data.frame")
  expect_s3_class(syn_adtte, "data.frame")

  # Check version attributes
  expect_equal(
    attr(syn_adsl, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
  expect_equal(
    attr(syn_adlb, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
  expect_equal(
    attr(syn_advs, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
  expect_equal(
    attr(syn_adae, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
  expect_equal(
    attr(syn_adtte, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )

  # Glimpse the study to obtain the study summary for inspection
  summary_path <- file.path(tempdir(), "summary_multi.rds")
  suppressMessages(glimpse_study(config_path, summary_path))
  study_summary <- readRDS(summary_path)
  summaries <- study_summary[["summaries"]]
  summary_adsl <- summaries[["adsl"]]
  summary_adlb <- summaries[["adlb"]]
  summary_advs <- summaries[["advs"]]
  summary_adae <- summaries[["adae"]]
  summary_adtte <- summaries[["adtte"]]

  # Check S3 classes
  expect_s3_class(summary_adsl, "summary_adsl")
  expect_s3_class(summary_adlb, "summary_bds")
  expect_s3_class(summary_advs, "summary_bds")
  expect_s3_class(summary_adae, "summary_occds")
  expect_s3_class(summary_adtte, "summary_tte")

  # --- ID leakage tests ---
  real_ids <- as.character(1:4)

  # 1. Synthetic datasets: IDs follow synthetic pattern, no real IDs
  for (syn_ds in list(syn_adsl, syn_adlb, syn_advs, syn_adae, syn_adtte)) {
    expect_true(all(grepl("^USUBJID_\\d+$", syn_ds$USUBJID)))
    expect_length(intersect(syn_ds$USUBJID, real_ids), 0)
  }

  # 2. ADSL summary: ID entry stores only column name, no real values
  expect_equal(summary_adsl[["USUBJID"]][["col_name"]], "USUBJID")
  expect_null(summary_adsl[["USUBJID"]][["unique_values"]])
  expect_equal(length(summary_adsl[["USUBJID"]]), 1)

  # 3. BDS/OCCDS/TTE summaries: adsl_cols contain only synthetic IDs
  non_adsl_summaries <- list(
    summary_adlb, summary_advs, summary_adae, summary_adtte
  )
  for (summary_ds in non_adsl_summaries) {
    adsl_ids <- summary_ds[["adsl_cols"]]$USUBJID
    expect_true(all(grepl("^USUBJID_\\d+$", adsl_ids)))
    expect_length(intersect(adsl_ids, real_ids), 0)
  }

  # 4. BDS summaries: param_visit profiles contain no ID columns
  for (summary_bds in list(summary_adlb, summary_advs)) {
    profiles <- summary_bds[["param_visits"]][["profiles"]]
    for (profile in profiles) {
      expect_false("USUBJID" %in% colnames(profile))
    }
  }

  # 5. OCCDS summary: occurrence_id_seq stores only counts and column names
  occ_summary <- summary_adae[["occurrence_id_seq"]]
  expect_true(is.numeric(occ_summary[["counts"]]))
  expect_false(any(real_ids %in% occ_summary[["id_cols"]]))
  expect_false(any(real_ids %in% occ_summary[["seq_col"]]))
})

test_that("simulate_study() errors on missing or multiple ADSLs", {
  # Missing ADSL dataset (no dataset with dataset_type = "adsl")
  config_no_adsl <- list(
    output_dir = file.path(tempdir(), "test_output_no_adsl"),
    seed = 123,
    datasets = list(
      adlb = list(
        dataset_type = "bds",
        path = file.path(tempdir(), "adlb.sas7bdat"),
        id_cols = list("USUBJID"),
        param_cols = list("PARAM", "PARAMCD"),
        visit_cols = list("AVISIT", "AVISITN"),
        flag_cols = list("ANL01FL")
      )
    )
  )
  config_path <- file.path(tempdir(), "config_no_adsl.yaml")
  yaml::write_yaml(config_no_adsl, config_path)

  expect_error(
    simulate_study(config_path),
    "exactly one.*adsl"
  )

  # Two datasets with dataset_type = "adsl"
  config_two_adsl <- list(
    output_dir = file.path(tempdir(), "test_output_two_adsl"),
    seed = 123,
    datasets = list(
      adsl = list(
        dataset_type = "adsl",
        path = file.path(tempdir(), "adsl.sas7bdat"),
        id_cols = list("USUBJID"),
        treatment_cols = list("TRT01A"),
        flag_cols = list("SAFFL"),
        ordered_col_sets = list()
      ),
      adsl2 = list(
        dataset_type = "adsl",
        path = file.path(tempdir(), "adsl2.sas7bdat"),
        id_cols = list("USUBJID"),
        treatment_cols = list("TRT01A"),
        flag_cols = list("SAFFL"),
        ordered_col_sets = list()
      )
    )
  )
  config_path <- file.path(tempdir(), "config_two_adsl.yaml")
  yaml::write_yaml(config_two_adsl, config_path)

  expect_error(
    simulate_study(config_path),
    "exactly one.*adsl"
  )
})
