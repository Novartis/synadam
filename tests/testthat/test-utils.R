# Convert a SAS file to parquet without arrow's R metadata, like a parquet
# file written outside R.
.sas_to_parquet <- function(sas_path, parquet_path) {
  adam <- arrow::arrow_table(haven::read_sas(sas_path))
  adam$metadata$r <- NULL
  arrow::write_parquet(adam, parquet_path)
  return(parquet_path)
}

test_that("read_adam() reads a parquet file the same as the SAS file", {
  adsl <- dplyr::tibble(
    USUBJID = c("1", "2", "3"),
    SEX = c("M", "", "F"),
    AGE = c(30, NA, 51),
    TRTSDT = as.Date(c("2020-01-01", NA, "2021-06-30"))
  )
  sas_path <- tempfile(fileext = ".sas7bdat")
  suppressWarnings(haven::write_sas(adsl, sas_path))
  parquet_path <- .sas_to_parquet(
    sas_path, tempfile(fileext = ".parquet")
  )

  from_sas <- read_adam(sas_path)
  from_parquet <- read_adam(parquet_path)

  expect_true(is.na(from_parquet$SEX[2]))
  # haven adds a `format.sas` attribute to date columns; parquet has none.
  expect_equal(from_parquet, from_sas, ignore_attr = "format.sas")
})

test_that("parquet input gives the same synthetic data as SAS input", {
  sas_dir <- tempfile("adam_sas_")
  parquet_dir <- tempfile("adam_parquet_")
  dir.create(sas_dir)
  dir.create(parquet_dir)
  for (ds in c("adsl", "adlb", "adae")) {
    adam <- utils::read.csv(
      system.file("extdata", paste0(ds, ".csv"), package = "synadam"),
      stringsAsFactors = FALSE
    ) |>
      dplyr::mutate(dplyr::across(dplyr::ends_with("DT"), as.Date))
    sas_path <- file.path(sas_dir, paste0(ds, ".sas7bdat"))
    suppressWarnings(haven::write_sas(adam, sas_path))
    .sas_to_parquet(sas_path, file.path(parquet_dir, paste0(ds, ".parquet")))
  }

  simulate_dir <- function(adam_dir) {
    out_dir <- tempfile("syn_")
    yaml_path <- suppressWarnings(
      generate_study_config(adam_dir, output_dir = out_dir)
    )
    suppressMessages(simulate_study(yaml_path))
    files <- list.files(out_dir, pattern = "^syn_.*\\.rds$")
    stats::setNames(lapply(file.path(out_dir, files), readRDS), files)
  }

  from_sas <- simulate_dir(sas_dir)
  from_parquet <- simulate_dir(parquet_dir)

  expect_named(from_sas, c("syn_adae.rds", "syn_adlb.rds", "syn_adsl.rds"))
  expect_identical(from_parquet, from_sas)
})
