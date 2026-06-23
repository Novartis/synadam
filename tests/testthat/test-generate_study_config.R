##### Integration #####

test_that("Study config for study A is created correctly", {
  dir <- .create_test_dataset(.test_study_a_cols)
  yaml_path <- generate_study_config(
    dir,
    output_dir = file.path(dir, "out"),
    seed = 42
  )

  actual <- .strip_paths(yaml::read_yaml(yaml_path))
  expected <- .strip_paths(yaml::read_yaml(
    testthat::test_path("fixtures", "expected_study_a_config.yaml")
  ))

  .expect_config_equal(actual, expected)
})

test_that("Study config for pilot study is created correctly", {
  dir <- .create_test_dataset(.test_pilot_cols)
  yaml_path <- generate_study_config(
    dir,
    output_dir = file.path(dir, "out"),
    seed = 42
  )

  actual <- .strip_paths(yaml::read_yaml(yaml_path))
  expected <- .strip_paths(yaml::read_yaml(
    testthat::test_path("fixtures", "expected_pilot_config.yaml")
  ))

  .expect_config_equal(actual, expected)
})

test_that("output study config parses and works with simulate_study()", {
  dir <- .create_test_dataset(list(
    adsl  = .test_adsl(),
    adlb  = .test_adlb(),
    adae  = .test_adae(),
    adtte = .test_adtte()
  ))
  out_dir <- file.path(dir, "out")

  yaml_path <- generate_study_config(dir, output_dir = out_dir, seed = 42)
  expect_equal(yaml_path, file.path(out_dir, "synadam_config.yaml"))
  expect_true(file.exists(yaml_path))

  cfg <- yaml::read_yaml(yaml_path)
  expect_named(cfg, c("output_dir", "seed", "datasets"), ignore.order = TRUE)
  expect_equal(cfg$output_dir, out_dir)
  expect_equal(cfg$seed, 42)
  expect_setequal(names(cfg$datasets), c("adsl", "adlb", "adae", "adtte"))
  expect_equal(cfg$datasets$adsl$dataset_type, "adsl")
  expect_equal(cfg$datasets$adlb$dataset_type, "bds")
  expect_equal(cfg$datasets$adae$dataset_type, "occds")
  expect_equal(cfg$datasets$adtte$dataset_type, "tte")

  # ADSL-shared columns must not appear in ordered_col_sets for non-ADSL
  # blocks - listing them duplicates columns the ADSL spine already
  # contributes, which crashes simulate_study() with a select() error.
  shared <- c("TRT01A", "TRT01AN", "REGION1", "REGION1N")
  for (key in c("adlb", "adae", "adtte")) {
    expect_false(
      any(shared %in% unlist(cfg$datasets[[key]]$ordered_col_sets)),
      info = glue::glue("ADSL-shared cols leaked into {key}$ordered_col_sets")
    )
  }

  result <- suppressMessages(simulate_study(yaml_path))
  expect_null(result)
  expect_true(file.exists(file.path(out_dir, "syn_adsl.rds")))
  expect_true(file.exists(file.path(out_dir, "syn_adlb.rds")))
  expect_true(file.exists(file.path(out_dir, "syn_adae.rds")))
  expect_true(file.exists(file.path(out_dir, "syn_adtte.rds")))
})

##### Unit tests #####

test_that("Non-canonical filenames fall through to column inspection", {
  # PARAM present => bds
  expect_equal(
    synadam:::.infer_dataset_type(
      "adtest.sas7bdat",
      c("USUBJID", "PARAM", "PARAMCD", "AVAL")
    ),
    "bds"
  )
  # *SEQ but no PARAM => occds
  expect_equal(
    synadam:::.infer_dataset_type(
      "adtest.sas7bdat",
      c("USUBJID", "FOOSEQ", "AVAL")
    ),
    "occds"
  )
  # USUBJID + demographics, non-canonical filename => REVIEW.
  # ADSL is determined from the filename only; the column fallback never
  # classifies a file as ADSL.
  expect_equal(
    synadam:::.infer_dataset_type(
      "adtest.sas7bdat",
      c("USUBJID", "AGE", "SEX")
    ),
    "REVIEW"
  )
})

test_that("Treatment_cols captures TRT##(A|P)(L|N|GR\\d+|GR\\d+N) variants", {
  cols <- c(
    "USUBJID",
    "TRT01A", "TRT01AN", "TRT01AL",
    "TRT01P", "TRT01PN", "TRT01PL",
    "TRT01AGR1", "TRT01AGR1N",
    "TRT01PGR2", "TRT01PGR2N"
  )
  out <- synadam:::.infer_cols_adsl(cols)
  expect_setequal(
    out$args$treatment_cols,
    c(
      "TRT01A", "TRT01AN", "TRT01AL",
      "TRT01P", "TRT01PN", "TRT01PL",
      "TRT01AGR1", "TRT01AGR1N",
      "TRT01PGR2", "TRT01PGR2N"
    )
  )
  # treatment cols must not also be auto-paired into ordered_col_sets
  expect_false(
    any(out$args$treatment_cols %in% unlist(out$args$ordered_col_sets))
  )
})

test_that("BDS param_cols auto-includes PARCAT* but excludes PARAMTYP", {
  cols <- c(
    "USUBJID", "PARAM", "PARAMCD", "PARCAT1", "PARCAT2",
    "PARAMTYP", "PARAMN", "AVISIT", "AVISITN", "AVAL"
  )
  out <- synadam:::.infer_cols_bds(cols)
  expect_equal(out$args$param_cols, c("PARAM", "PARAMCD", "PARCAT1", "PARCAT2"))
})

test_that(".detect_flag_cols emits every *FL column by name pattern", {
  cols <- c("USUBJID", "SAFFL", "MISINFFL", "ANL01FL")
  out <- synadam:::.detect_flag_cols(cols)
  expect_setequal(out$value, c("SAFFL", "MISINFFL", "ANL01FL"))
  expect_match(out$note, "REVIEW")
})

test_that(".detect_flag_cols returns NULL note when no *FL columns present", {
  out <- synadam:::.detect_flag_cols(c("USUBJID", "AGE"))
  expect_equal(out$value, character(0))
  expect_null(out$note)
})

test_that("BDS/OCCDS/TTE exclude ADSL-shared columns from ordered_col_sets", {
  shared <- c("TRT01A", "TRT01AN", "REGION1", "REGION1N")

  bds_cols <- c("USUBJID", "PARAM", "PARAMCD", "AVAL", shared)
  bds_out <- synadam:::.infer_cols_bds(bds_cols, adsl_cols = shared)
  expect_false(any(shared %in% unlist(bds_out$args$ordered_col_sets)))

  occds_cols <- c("USUBJID", "AESEQ", "AETERM", shared)
  occds_out <- synadam:::.infer_cols_occds(occds_cols, adsl_cols = shared)
  expect_false(any(shared %in% unlist(occds_out$args$ordered_col_sets)))

  tte_cols <- c("USUBJID", "PARAM", "PARAMCD", "CNSR", "EVNTDESC", shared)
  tte_out <- synadam:::.infer_cols_tte(tte_cols, adsl_cols = shared)
  expect_false(any(shared %in% unlist(tte_out$args$ordered_col_sets)))
})

test_that("output_dir is required", {
  dir <- .create_test_dataset(list(adsl = .test_adsl()))
  expect_error(generate_study_config(dir))
})

test_that("config is written into output_dir, which is created if missing", {
  dir <- .create_test_dataset(list(adsl = .test_adsl()))
  out_dir <- file.path(tempdir(), "gsc_made", "nested")
  unlink(dirname(out_dir), recursive = TRUE)

  yaml_path <- generate_study_config(
    dir,
    output_dir = out_dir,
    config_yaml_name = "my_config.yaml"
  )

  expect_equal(yaml_path, file.path(out_dir, "my_config.yaml"))
  expect_true(dir.exists(out_dir))
  expect_true(file.exists(yaml_path))

  cfg <- yaml::read_yaml(yaml_path)
  expect_equal(cfg$output_dir, out_dir)
})

test_that("zero ADSL files in directory errors out", {
  dir <- .create_test_dataset(list(adlb = .test_adlb()))
  expect_error(
    generate_study_config(dir, output_dir = file.path(dir, "out")), "ADSL"
  )
})

test_that("multiple ADSL: prefers exact adsl.sas7bdat over other candidates", {
  dir <- .create_test_dataset(list(
    adsl    = .test_adsl(),
    adslsub = .test_adsl()
  ))
  expect_warning(
    yaml_path <- generate_study_config(dir, output_dir = file.path(dir, "out")),
    "adslsub"
  )
  cfg <- yaml::read_yaml(yaml_path)
  expect_true("adsl" %in% names(cfg$datasets))
  expect_false("adslsub" %in% names(cfg$datasets))
  expect_equal(cfg$datasets$adsl$dataset_type, "adsl")
})

test_that("multiple ADSL: falls back to first alphabetically", {
  dir <- .create_test_dataset(list(
    adsl_b = .test_adsl(),
    adsl_a = .test_adsl()
  ))
  expect_warning(
    yaml_path <- generate_study_config(dir, output_dir = file.path(dir, "out")),
    "adsl_b"
  )
  cfg <- yaml::read_yaml(yaml_path)
  expect_true("adsl_a" %in% names(cfg$datasets))
  expect_false("adsl_b" %in% names(cfg$datasets))
  expect_equal(cfg$datasets$adsl_a$dataset_type, "adsl")
})

test_that("non-'ad' files in directory are skipped with a warning", {
  dir <- .create_test_dataset(list(
    adsl = .test_adsl(),
    foo  = dplyr::tibble(x = 1:3, y = letters[1:3])
  ))
  expect_warning(
    yaml_path <- generate_study_config(dir, output_dir = file.path(dir, "out")),
    "foo"
  )
  cfg <- yaml::read_yaml(yaml_path)
  expect_null(cfg$datasets$foo)
  expect_true("adsl" %in% names(cfg$datasets))
})

test_that("every *FL column is auto-included in flag_cols", {
  adsl_with_bad_fl <- .test_adsl() |>
    dplyr::mutate(MISINFFL = rep("REPORT", 4))
  dir <- .create_test_dataset(list(adsl = adsl_with_bad_fl))
  cfg <- yaml::read_yaml(suppressWarnings(
    generate_study_config(dir, output_dir = file.path(dir, "out"))
  ))
  expect_true("MISINFFL" %in% cfg$datasets$adsl$flag_cols)
  expect_true("SAFFL" %in% cfg$datasets$adsl$flag_cols)
})

test_that("ad-prefixed file that fails column inspection still emits REVIEW", {
  dir <- .create_test_dataset(list(
    adsl  = .test_adsl(),
    adfoo = dplyr::tibble(USUBJID = as.character(1:3), AGE = c(20, 30, 40))
  ))
  expect_warning(
    yaml_path <- generate_study_config(dir, output_dir = file.path(dir, "out")),
    "adfoo"
  )
  cfg <- yaml::read_yaml(yaml_path)
  expect_equal(cfg$datasets$adfoo$dataset_type, "REVIEW")
})
