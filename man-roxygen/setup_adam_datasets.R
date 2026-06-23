#' @examples
#' \dontshow{
#' # Stage ADaM datasets as SAS files so the example can run.
#' adam_dir <- file.path(tempdir(), "<%= adam_dir_name %>")
#' dir.create(adam_dir, showWarnings = FALSE)
<% for (ds in strsplit(datasets, ",")[[1]]) { -%>
#' <%= ds %> <- read.csv(
#'   system.file("extdata", "<%= ds %>.csv", package = "synadam"),
#'   stringsAsFactors = FALSE
#' )
#' suppressWarnings(
#'   haven::write_sas(<%= ds %>, file.path(adam_dir, "<%= ds %>.sas7bdat"))
#' )
<% } -%>
#' }
