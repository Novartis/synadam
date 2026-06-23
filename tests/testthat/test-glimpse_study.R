.make_minimal_config <- function() {
  adsl <- dplyr::tibble(
    USUBJID = as.character(1:5),
    STUDYID = "TEST001",
    TRT01A = rep(c("Treatment A", "Treatment B"), length.out = 5),
    TRT01AN = rep(c(1, 2), length.out = 5),
    SAFFL = rep(c("Y", "N"), length.out = 5),
    AGE = c(25, 35, 45, 55, 65)
  )
  adsl_path <- file.path(tempdir(), "glstudy_adsl.sas7bdat")
  suppressWarnings(haven::write_sas(adsl, adsl_path))

  output_dir <- file.path(tempdir(), "glstudy_output")
  config <- list(
    output_dir = output_dir,
    seed = 123,
    datasets = list(
      adsl = list(
        dataset_type = "adsl",
        path = adsl_path,
        id_cols = list("USUBJID"),
        treatment_cols = list("TRT01A", "TRT01AN"),
        flag_cols = list("SAFFL"),
        ordered_col_sets = list()
      )
    )
  )
  config_path <- file.path(tempdir(), "glstudy_config.yaml")
  yaml::write_yaml(config, config_path)

  list(config_path = config_path, output_dir = output_dir, seed = 123)
}

test_that("glimpse_study() writes study summary with summaries and metadata", {
  cfg <- .make_minimal_config()
  summary_path <- file.path(tempdir(), "glstudy_summary.rds")
  if (file.exists(summary_path)) file.remove(summary_path)

  result <- suppressMessages(
    glimpse_study(cfg$config_path, summary_path)
  )

  expect_null(result)
  expect_true(file.exists(summary_path))

  study_summary <- readRDS(summary_path)
  expect_type(study_summary, "list")
  expect_named(
    study_summary,
    c("summaries", "seed", "synadam_version", "glimpsed_at"),
    ignore.order = TRUE
  )
  expect_named(study_summary$summaries, "adsl")
  expect_s3_class(study_summary$summaries$adsl, "summary_adsl")
  expect_equal(study_summary$seed, cfg$seed)
  expect_equal(
    study_summary$synadam_version,
    as.character(utils::packageVersion("synadam"))
  )
  expect_s3_class(study_summary$glimpsed_at, "POSIXct")
})

test_that("simulate_study_from_summary() produces synthetic files", {
  cfg <- .make_minimal_config()
  summary_path <- file.path(tempdir(), "glstudy_summary2.rds")
  out_dir <- file.path(tempdir(), "from_summary_out")
  unlink(out_dir, recursive = TRUE)

  suppressMessages(glimpse_study(cfg$config_path, summary_path))
  result <- suppressMessages(
    simulate_study_from_summary(summary_path, out_dir)
  )

  expect_null(result)
  syn_path <- file.path(out_dir, "syn_adsl.rds")
  expect_true(file.exists(syn_path))

  syn_adsl <- readRDS(syn_path)
  expect_s3_class(syn_adsl, "data.frame")
  expect_equal(nrow(syn_adsl), 5)
  expect_equal(
    attr(syn_adsl, "synadam_version"),
    as.character(utils::packageVersion("synadam"))
  )
})

test_that("glimpse + simulate_from_summary round-trips simulate_study()", {
  cfg <- .make_minimal_config()

  # Path A: original simulate_study() into dir A
  out_dir_a <- file.path(tempdir(), "rt_a")
  unlink(out_dir_a, recursive = TRUE)
  config_a <- yaml::read_yaml(cfg$config_path)
  config_a$output_dir <- out_dir_a
  config_path_a <- file.path(tempdir(), "rt_config_a.yaml")
  yaml::write_yaml(config_a, config_path_a)
  suppressMessages(simulate_study(config_path_a))

  # Path B: glimpse_study() then simulate_study_from_summary() into dir B
  out_dir_b <- file.path(tempdir(), "rt_b")
  unlink(out_dir_b, recursive = TRUE)
  summary_path <- file.path(tempdir(), "rt_summary.rds")
  suppressMessages(glimpse_study(cfg$config_path, summary_path))
  suppressMessages(simulate_study_from_summary(summary_path, out_dir_b))

  syn_a <- readRDS(file.path(out_dir_a, "syn_adsl.rds"))
  syn_b <- readRDS(file.path(out_dir_b, "syn_adsl.rds"))

  # Same seed and same summaries -> identical synthetic data
  expect_equal(as.data.frame(syn_a), as.data.frame(syn_b))
})

test_that("simulate_study_from_summary() seed override changes output", {
  cfg <- .make_minimal_config()
  summary_path <- file.path(tempdir(), "rt_summary_seed.rds")
  out_dir <- file.path(tempdir(), "rt_seed_out")
  unlink(out_dir, recursive = TRUE)

  suppressMessages(glimpse_study(cfg$config_path, summary_path))
  suppressMessages(
    simulate_study_from_summary(summary_path, out_dir, seed = cfg$seed)
  )
  syn_default <- readRDS(file.path(out_dir, "syn_adsl.rds"))

  out_dir2 <- file.path(tempdir(), "rt_seed_out2")
  unlink(out_dir2, recursive = TRUE)
  suppressMessages(
    simulate_study_from_summary(summary_path, out_dir2, seed = cfg$seed + 1)
  )
  syn_other <- readRDS(file.path(out_dir2, "syn_adsl.rds"))

  # Different seed should produce some difference in randomized columns.
  expect_false(identical(as.data.frame(syn_default), as.data.frame(syn_other)))
})

test_that("simulate_study_from_summary() validates the study summary", {
  bad_path <- file.path(tempdir(), "rt_bad_summary.rds")
  saveRDS(list(not = "a study summary"), bad_path)

  expect_error(
    simulate_study_from_summary(
      bad_path,
      file.path(tempdir(), "rt_bad_out")
    )
  )
})
