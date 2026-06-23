#' Generate a draft study config YAML from a directory of ADaM files.
#'
#' Scans a directory of `.sas7bdat` files, infers `dataset_type` and
#' per-dataset glimpse arguments using CDISC filename and column-name
#' conventions, and writes a draft YAML config suitable for `simulate_study()`.
#' Inferred fields are tagged with inline `# REVIEW` comments where the signal
#' is weak so users know what to verify before running the simulation.
#'
#' Only files whose basename matches `ad*.sas7bdat` (case-insensitive) are
#' considered. Any other files in `adam_dir` are skipped with a single
#' warning listing them.
#'
#' @section Detection rules:
#' Filename match (case-insensitive, basename without extension):
#'   - starts with `adsl` -> `adsl`
#'   - starts with `adae`/`adcm`/`admh`/`addv` -> `occds`
#'   - starts with `adtte` -> `tte`
#'   - any other name (including `ad*`) -> fall through to column inspection
#'
#' Column inspection rules (checked in order; `USUBJID` is required in
#' every ADaM dataset, so it is not used as a discriminator). ADSL is
#' classified from the filename only - any non-`adsl*` file that lacks
#' BDS/TTE/OCCDS column signatures falls through to `"REVIEW"`:
#'   - has `PARAM` -> `bds` (checked before CNSR so oncology hybrid
#'     datasets like ADRECIST that carry TTE-derived parameters inline
#'     classify as the longitudinal BDS they actually are)
#'   - has `CNSR` -> `tte` (CNSR is the only structurally required TTE
#'     variable in ADaM; `EVNTDESC` is conventional but not universal)
#'   - has any `*SEQ` column -> `occds`
#'   - otherwise -> `"REVIEW"` placeholder + warning
#'
#' Errors if no ADSL file is detected; `simulate_study()` requires exactly
#' one. If multiple ADSL candidates are detected, a file named exactly
#' `adsl.sas7bdat` (case-insensitive) is preferred; otherwise the
#' alphabetically-first candidate is used. The picked file is kept and the
#' rest are dropped with a warning.
#'
#' @section Column-role detection:
#' Within a classified dataset, the column-role inference picks up:
#'
#'   - `id_cols`: `USUBJID` and `SUBJID` when present.
#'   - `treatment_cols` (ADSL): `ACTARM`, `ACTARMCD`, `ARM`, `ARMCD`,
#'     `TRTSEQP`, `TRTSEQA` and any
#'     `TRT##A`/`TRT##AN`/`TRT##AL`/`TRT##P`/`TRT##PN`/`TRT##PL` matches,
#'     plus `TRT##(A|P)GR\d*` and `TRT##(A|P)GR\d*N` group variants.
#'   - `visit_cols` (BDS): `AVISIT`, `AVISITN`, `VISIT`, `VISITNUM`,
#'     `ATPT`, `ATPTN` when present.
#'   - `param_cols` (BDS, TTE): `PARAM`, `PARAMCD`, and any `PARCAT*` columns.
#'   - `seq_col` (OCCDS): the first known domain-coded `*SEQ` column
#'     (`AESEQ`, `CMSEQ`, `MHSEQ`, `PRSEQ`, `EXSEQ`, `DSSEQ`); falls back
#'     to the first `*SEQ` column if none of those are present.
#'   - `censor_cols` (TTE): `CNSR`, `EVNTDESC`, `CNSDTDSC` - only emitted
#'     when two or more of these are detected. A single `CNSR` flows
#'     through as a regular column and `censor_cols` is omitted.
#'   - `ordered_col_sets`: X/XN/XL groups where two or three variants of a
#'     base column name co-exist.
#'
#' @section What is NOT auto-inferred:
#' Some config decisions are opinionated and intended to be pruned or
#' extended by the user after generation:
#'
#'   - `flag_cols` emits every `*FL` column found. The user is expected to
#'     trim this list down to the flags they want to preserve.
#'   - Non-FL flag-like indicators (e.g. `AESER`) are not detected.
#'   - Ordered column sets that share semantics but not naming (e.g.
#'     `AEBODSYS`/`AEDECOD`) are not auto-paired; add them by hand.
#'   - For BDS and TTE datasets `param_cols` auto-includes `PARAM`,
#'     `PARAMCD`, and any `PARCAT*` columns present, but NOT `PARAMTYP`
#'     or `PARAMN`; add these manually if relevant.
#'   - For BDS, OCCDS, and TTE datasets `ordered_col_sets` excludes any
#'     column also present in the chosen ADSL. ADSL-shared columns are
#'     pulled in via the ADSL spine at simulation time, so listing them
#'     here would duplicate the column.
#'
#' @param adam_dir `character(1)` - directory containing `.sas7bdat` files.
#' @param output_dir `character(1)` - directory that both the generated config
#'   YAML and the synthetic `.rds` outputs are written to. Created recursively
#'   if it does not exist. This same path is recorded as the top-level
#'   `output_dir` field in the YAML, so `simulate_study()` writes its
#'   `syn_*.rds` files alongside the config.
#' @param config_yaml_name `character(1)` - filename for the generated config
#'   within `output_dir`. Defaults to `"synadam_config.yaml"`. If the file
#'   already exists, it is silently overwritten.
#' @param seed `integer(1)` / `numeric(1)` or `NULL` - value to write for
#'   the top-level `seed` field in the YAML. Defaults to `123`. If `NULL`, a
#'   `"REVIEW: ..."` placeholder is written instead.
#'
#' @return `character(1)` - the path the YAML was written to
#'   (`file.path(output_dir, config_yaml_name)`).
#'
#' @templateVar adam_dir_name adam_dir
#' @templateVar datasets adsl,adae
#' @template setup_adam_datasets
#' @examples
#'
#' yaml_path <- generate_study_config(
#'   adam_dir,
#'   output_dir = file.path(tempdir(), "syn_out")
#' )
#' yaml_path
#'
#' @export
generate_study_config <- function(adam_dir,
                                  output_dir,
                                  config_yaml_name = "synadam_config.yaml",
                                  seed = 123) {
  checkmate::assert_directory_exists(adam_dir)
  checkmate::assert_string(output_dir)
  checkmate::assert_string(config_yaml_name)
  checkmate::assert_number(seed, null.ok = TRUE)

  output_yaml <- file.path(output_dir, config_yaml_name)

  adam_dir <- normalizePath(adam_dir, mustWork = TRUE)
  paths <- .scan_adam_dir(adam_dir)

  cols_by_path <- stats::setNames(
    lapply(paths, function(p) {
      colnames(suppressWarnings(haven::read_sas(p, n_max = 0)))
    }),
    paths
  )
  type_by_path <- stats::setNames(
    vapply(paths, function(p) {
      .infer_dataset_type(p, cols_by_path[[p]])
    }, character(1)),
    paths
  )

  adsl_paths <- paths[type_by_path == "adsl"]
  chosen_adsl <- .resolve_adsl_path(adsl_paths, paths)
  paths <- setdiff(paths, setdiff(adsl_paths, chosen_adsl))
  adsl_cols <- cols_by_path[[chosen_adsl]]

  entries <- list()
  unresolved <- character()

  for (path in paths) {
    key <- tools::file_path_sans_ext(basename(path))
    cols <- cols_by_path[[path]]
    dataset_type <- type_by_path[[path]]

    if (dataset_type == "REVIEW") unresolved <- c(unresolved, basename(path))

    inferred <- switch(dataset_type,
      "adsl" = .infer_cols_adsl(cols),
      "bds" = .infer_cols_bds(cols, adsl_cols),
      "occds" = .infer_cols_occds(cols, adsl_cols),
      "tte" = .infer_cols_tte(cols, adsl_cols),
      "REVIEW" = list(args = list(), confidence = list())
    )

    entries[[key]] <- list(
      path         = path,
      dataset_type = dataset_type,
      args         = inferred$args,
      confidence   = inferred$confidence,
      cols         = if (dataset_type == "REVIEW") cols else NULL
    )
  }

  if (length(unresolved) > 0) {
    warning(glue::glue(
      "{length(unresolved)} file(s) could not be classified: ",
      "{paste(unresolved, collapse = ', ')}. ",
      "These entries have dataset_type = \"REVIEW\" in the config; ",
      "edit before running simulate_study()."
    ), call. = FALSE)
  }

  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  yaml_text <- .render_config_yaml(entries, output_dir, seed)
  writeLines(yaml_text, output_yaml)
  return(output_yaml)
}

#' List `ad*.sas7bdat` files in an ADaM directory.
#'
#' Files whose basename does not match `ad*.sas7bdat` (case-insensitive)
#' are skipped with a single warning listing them.
#'
#' @param adam_dir `character(1)` - directory to scan.
#'
#' @return `character` - full paths to all matching `.sas7bdat` files;
#'   errors if none.
#' @keywords internal
.scan_adam_dir <- function(adam_dir) {
  all_paths <- list.files(adam_dir, full.names = TRUE)
  bases <- basename(all_paths)
  is_included <- grepl("^ad.*\\.sas7bdat$", bases, ignore.case = TRUE)
  included <- all_paths[is_included]
  skipped <- bases[!is_included]

  if (length(skipped) > 0) {
    warning(
      glue::glue(
        "Skipping {length(skipped)} file(s) that do not match ",
        "'ad*.sas7bdat': {paste(skipped, collapse = ', ')}."
      ),
      call. = FALSE
    )
  }

  if (length(included) == 0) {
    stop(
      glue::glue(
        "No ad*.sas7bdat files found in directory '{adam_dir}'."
      ),
      call. = FALSE
    )
  }
  return(included)
}

#' Infer the ADaM dataset type for a file.
#'
#' Tries the filename rules first, then falls back to column-presence rules.
#'
#' @param path `character(1)` - path to the dataset file.
#' @param cols `character` - column names of the dataset.
#'
#' @return `character(1)` - one of `"adsl"`, `"bds"`, `"occds"`, `"tte"`,
#'   or `"REVIEW"`.
#' @keywords internal
.infer_dataset_type <- function(path, cols) {
  base <- tolower(tools::file_path_sans_ext(basename(path)))
  by_name <- .infer_type_from_filename(base)
  if (!is.null(by_name)) {
    return(by_name)
  }
  return(.infer_type_from_columns(cols))
}

#' Classify a dataset by filename prefix.
#'
#' @param base `character(1)` - lowercased basename without extension.
#'
#' @return `character(1)` dataset type, or `NULL` if no prefix matched.
#' @keywords internal
.infer_type_from_filename <- function(base) {
  occds_prefixes <- c("adae", "adcm", "admh", "addv")
  if (startsWith(base, "adsl")) {
    return("adsl")
  }
  if (any(vapply(occds_prefixes, startsWith, logical(1), x = base))) {
    return("occds")
  }
  if (startsWith(base, "adtte")) {
    return("tte")
  }
  return(NULL)
}

#' Classify a dataset by column presence.
#'
#' @param cols `character` - column names of the dataset.
#'
#' @return `character(1)` - one of `"adsl"`, `"bds"`, `"occds"`, `"tte"`,
#'   or `"REVIEW"` when no rule matches.
#' @keywords internal
.infer_type_from_columns <- function(cols) {
  if ("PARAM" %in% cols) {
    return("bds")
  }
  if ("CNSR" %in% cols) {
    return("tte")
  }
  if (any(grepl("SEQ$", cols))) {
    return("occds")
  }
  return("REVIEW")
}


# ---- Per-role detectors -----------------------------------------------
#
# Each .detect_* helper inspects `cols` for one role and returns
#   list(value = <vector|scalar|NULL>, note = <character(1)|NULL>)
# `value` becomes the entry under `args`; a non-NULL `note` becomes the
# entry under `confidence`. The four .infer_cols_* functions compose
# these detectors and feed the result through .pack_inferred().

#' Detect id_cols (USUBJID, SUBJID).
#' @noRd
.detect_id_cols <- function(cols) {
  value <- intersect(c("USUBJID", "SUBJID"), cols)
  note <- if (length(value) == 0) "REVIEW: no USUBJID or SUBJID found" else NULL
  return(list(value = value, note = note))
}

#' Detect *FL flag columns by name pattern.
#'
#' Emits every column matching `^[A-Z0-9]+FL$`. The user is expected to
#' trim the resulting list to the flags they want to preserve before
#' running [simulate_study()], since `glimpse_flag()` requires values to
#' be a subset of `{"Y", "N", NA}` and many `*FL` columns in real data
#' carry blanks or other non-Y/N values.
#' @noRd
.detect_flag_cols <- function(cols) {
  matches <- cols[grepl("^[A-Z0-9]+FL$", cols)]
  note <- if (length(matches) > 0) "REVIEW: matched *FL pattern" else NULL
  return(list(value = matches, note = note))
}

#' Detect treatment columns: canonical ARM family + numbered TRT##.
#' @noRd
.detect_treatment_cols <- function(cols) {
  canonical <- intersect(
    c("ACTARM", "ACTARMCD", "ARM", "ARMCD", "TRTSEQP", "TRTSEQA"),
    cols
  )
  numbered <- cols[grepl("^TRT\\d+[AP](GR\\d*N?|[NL])?$", cols)]
  value <- c(canonical, numbered)
  note <- if (length(value) == 0) {
    paste(
      "REVIEW: no ACTARM/ARM/TRTSEQP/TRTSEQA/",
      "TRT##A/TRT##AN/TRT##AL/TRT##(A|P)GR columns found"
    )
  } else {
    NULL
  }
  return(list(value = value, note = note))
}

#' Detect param columns for BDS: PARAM, PARAMCD, plus any PARCAT*.
#' @noRd
.detect_param_cols_bds <- function(cols) {
  parcat <- grep("^PARCAT[0-9]+$", cols, value = TRUE)
  value <- intersect(c("PARAM", "PARAMCD", parcat), cols)
  note <- if (length(value) < 2) {
    "REVIEW: expected PARAM and PARAMCD"
  } else if (length(parcat) > 0) {
    glue::glue(
      "REVIEW: auto-included PARCAT* (",
      "{paste(parcat, collapse = ', ')}); remove if undesired"
    )
  } else {
    NULL
  }
  return(list(value = value, note = note))
}

#' Detect param columns for TTE: PARAM, PARAMCD, plus any PARCAT*.
#'
#' Mirrors `.detect_param_cols_bds()` since TTE is a BDS subclass and
#' PARCAT* parameter-categorization variables are valid in TTE.
#' @noRd
.detect_param_cols_tte <- function(cols) {
  parcat <- grep("^PARCAT[0-9]+$", cols, value = TRUE)
  value <- intersect(c("PARAM", "PARAMCD", parcat), cols)
  note <- if (length(value) < 2) {
    "REVIEW: expected PARAM and PARAMCD"
  } else if (length(parcat) > 0) {
    glue::glue(
      "REVIEW: auto-included PARCAT* (",
      "{paste(parcat, collapse = ', ')}); remove if undesired"
    )
  } else {
    NULL
  }
  return(list(value = value, note = note))
}

#' Detect visit columns for BDS.
#' @noRd
.detect_visit_cols <- function(cols) {
  value <- intersect(
    c("AVISIT", "AVISITN", "VISIT", "VISITNUM"), cols
  )
  note <- if (length(value) > 0) "REVIEW: visit_cols are optional" else NULL
  return(list(value = value, note = note))
}

#' Detect the OCCDS sequence column. Prefers domain-coded *SEQ;
#' falls back to the first *SEQ; returns NA_character_ if none.
#' @noRd
.detect_seq_col <- function(cols) {
  candidates <- cols[grepl("SEQ$", cols)]
  if (length(candidates) == 0) {
    return(list(
      value = NA_character_,
      note = "REVIEW: no *SEQ column found"
    ))
  }
  preferred <- c("AESEQ", "CMSEQ", "MHSEQ", "PRSEQ", "EXSEQ", "DSSEQ")
  preferred_hit <- intersect(preferred, candidates)
  value <- if (length(preferred_hit) > 0) preferred_hit[1] else candidates[1]
  note <- if (length(candidates) > 1) {
    glue::glue(
      "REVIEW: multiple *SEQ candidates: ",
      "{paste(candidates, collapse = ', ')} ",
      "(selected: {value})"
    )
  } else {
    NULL
  }
  return(list(value = value, note = note))
}

#' Detect TTE censor columns. Only emits a value when 2+ of CNSR,
#' EVNTDESC, CNSDTDSC are present; a single CNSR flows through as a
#' regular column (value = NULL, no note).
#' @noRd
.detect_censor_cols <- function(cols) {
  detected <- intersect(c("CNSR", "EVNTDESC", "CNSDTDSC"), cols)
  if (length(detected) >= 2) {
    return(list(value = detected, note = NULL))
  }
  if (length(detected) == 0) {
    return(list(
      value = NULL,
      note = "REVIEW: no censoring columns detected"
    ))
  }
  return(list(value = NULL, note = NULL))
}

#' Detect X/XN/XL ordered column groups, excluding any cols already
#' claimed by a more specific role.
#' @noRd
.detect_ordered_col_sets <- function(cols, exclude) {
  value <- .find_ordered_sets(cols, exclude = exclude)
  note <- if (length(value) > 0) "REVIEW: X/XN/XL groups detected" else NULL
  return(list(value = value, note = note))
}

#' Pack a named list of detector results into the (args, confidence)
#' shape the YAML emitter expects.
#'
#' Drops detector entries with `note = NULL` from confidence. Preserves
#' all entries (including `value = NULL`, e.g. single-CNSR `censor_cols`)
#' under args; the YAML emitter's `is.null()` skip pattern handles those.
#' @noRd
.pack_inferred <- function(detections) {
  args <- lapply(detections, `[[`, "value")
  conf <- Filter(Negate(is.null), lapply(detections, `[[`, "note"))
  return(list(args = args, confidence = conf))
}


#' Infer ADSL glimpse arguments from column names.
#'
#' @param cols `character` - column names of the ADSL dataset.
#'
#' @return `list(args, confidence)` - args ready for the YAML emitter and
#'   per-field REVIEW notes for low-confidence inferences.
#' @keywords internal
.infer_cols_adsl <- function(cols) {
  id <- .detect_id_cols(cols)
  trt <- .detect_treatment_cols(cols)
  fl <- .detect_flag_cols(cols)
  claimed <- c(id$value, trt$value, fl$value)
  ord <- .detect_ordered_col_sets(cols, exclude = claimed)
  return(.pack_inferred(list(
    id_cols          = id,
    treatment_cols   = trt,
    flag_cols        = fl,
    ordered_col_sets = ord
  )))
}

#' Infer BDS glimpse arguments from column names.
#'
#' @param cols `character` - column names of the BDS dataset.
#' @param adsl_cols `character` - column names of the chosen ADSL.
#'   Excluded from `ordered_col_sets` since the ADSL spine contributes
#'   them at simulation time; listing them again would duplicate the
#'   column.
#'
#' @return `list(args, confidence)` - args ready for the YAML emitter and
#'   per-field REVIEW notes for low-confidence inferences.
#' @keywords internal
.infer_cols_bds <- function(cols, adsl_cols = character()) {
  id <- .detect_id_cols(cols)
  param <- .detect_param_cols_bds(cols)
  visit <- .detect_visit_cols(cols)
  fl <- .detect_flag_cols(cols)
  claimed <- c(id$value, param$value, visit$value, fl$value, adsl_cols)
  ord <- .detect_ordered_col_sets(cols, exclude = claimed)
  return(.pack_inferred(list(
    id_cols          = id,
    param_cols       = param,
    visit_cols       = visit,
    flag_cols        = fl,
    ordered_col_sets = ord
  )))
}

#' Infer OCCDS glimpse arguments from column names.
#'
#' @param cols `character` - column names of the OCCDS dataset.
#' @param adsl_cols `character` - column names of the chosen ADSL.
#'   Excluded from `ordered_col_sets` since the ADSL spine contributes
#'   them at simulation time; listing them again would duplicate the
#'   column.
#'
#' @return `list(args, confidence)` - args ready for the YAML emitter and
#'   per-field REVIEW notes for low-confidence inferences.
#' @keywords internal
.infer_cols_occds <- function(cols, adsl_cols = character()) {
  id <- .detect_id_cols(cols)
  seq <- .detect_seq_col(cols)
  fl <- .detect_flag_cols(cols)
  claimed <- c(id$value, seq$value, fl$value, adsl_cols)
  ord <- .detect_ordered_col_sets(cols, exclude = claimed)
  return(.pack_inferred(list(
    id_cols          = id,
    seq_col          = seq,
    flag_cols        = fl,
    ordered_col_sets = ord
  )))
}

#' Infer TTE glimpse arguments from column names.
#'
#' @param cols `character` - column names of the TTE dataset.
#' @param adsl_cols `character` - column names of the chosen ADSL.
#'   Excluded from `ordered_col_sets` since the ADSL spine contributes
#'   them at simulation time; listing them again would duplicate the
#'   column.
#'
#' @return `list(args, confidence)` - args ready for the YAML emitter and
#'   per-field REVIEW notes for low-confidence inferences.
#' @keywords internal
.infer_cols_tte <- function(cols, adsl_cols = character()) {
  param <- .detect_param_cols_tte(cols)
  censor <- .detect_censor_cols(cols)
  fl <- .detect_flag_cols(cols)
  claimed <- c(param$value, censor$value, fl$value, adsl_cols)
  ord <- .detect_ordered_col_sets(cols, exclude = claimed)
  return(.pack_inferred(list(
    param_cols       = param,
    censor_cols      = censor,
    flag_cols        = fl,
    ordered_col_sets = ord
  )))
}

#' Find X/XN/XL ordered column groups.
#'
#' Detects groups where two or three of the variants exist together and
#' none of the members is already claimed by a more specific role. For a
#' base column X, the emitted group includes X plus whichever of XN and XL
#' exist (e.g. REGION1 plus REGION1N, SEX plus SEXL, or ETHNIC plus
#' ETHNICN plus ETHNICL).
#'
#' @param cols `character` - column names to scan.
#' @param exclude `character` - columns already claimed by a more specific
#'   role and therefore ineligible for grouping.
#'
#' @return `list` of `character` vectors, one per detected group.
#' @keywords internal
.find_ordered_sets <- function(cols, exclude = character()) {
  available <- setdiff(cols, exclude)
  bases <- available[!grepl("[NL]$", available)]

  groups <- lapply(bases, function(base) {
    suffixed <- paste0(base, c("N", "L"))
    return(c(base, intersect(suffixed, available)))
  })

  return(groups[lengths(groups) >= 2])
}

#' Resolve the canonical ADSL path from one or more candidates.
#'
#' Errors if no ADSL was detected. When multiple candidates are present,
#' prefers a file named exactly `adsl.sas7bdat` (case-insensitive); else
#' falls back to the alphabetically-first candidate. The non-chosen
#' candidates are reported in a warning.
#'
#' @param adsl_paths `character` - paths classified as ADSL.
#' @param all_paths `character` - all scanned paths (for error messages).
#'
#' @return `character(1)` - the chosen ADSL path. Errors if zero ADSL.
#' @keywords internal
.resolve_adsl_path <- function(adsl_paths, all_paths) {
  if (length(adsl_paths) == 0) {
    stop(
      glue::glue(
        "No ADSL dataset detected. simulate_study() requires exactly one ",
        "dataset with dataset_type = 'adsl'. Files scanned: ",
        "{paste(basename(all_paths), collapse = ', ')}."
      ),
      call. = FALSE
    )
  }
  if (length(adsl_paths) == 1) {
    return(adsl_paths)
  }

  exact_hit <- adsl_paths[tolower(basename(adsl_paths)) == "adsl.sas7bdat"]
  chosen <- if (length(exact_hit) >= 1) {
    exact_hit[1]
  } else {
    adsl_paths[order(basename(adsl_paths))][1]
  }
  skipped <- setdiff(adsl_paths, chosen)
  warning(
    glue::glue(
      "Multiple ADSL candidates detected: ",
      "{paste(basename(adsl_paths), collapse = ', ')}. ",
      "Using '{basename(chosen)}' and skipping ",
      "'{paste(basename(skipped), collapse = ', ')}'."
    ),
    call. = FALSE
  )
  return(chosen)
}

#' Render the full YAML config text from a list of dataset entries.
#'
#' @param entries `list` - one entry per dataset, each holding `path`,
#'   `dataset_type`, `args`, `confidence`, and (for REVIEW) `cols`.
#' @param output_dir `character(1)` - value for the top-level `output_dir`
#'   field.
#' @param seed `numeric(1)` or `NULL` - value for the top-level `seed`
#'   field; `NULL` writes a REVIEW placeholder.
#'
#' @return `character(1)` - the YAML document as a single newline-joined
#'   string.
#' @keywords internal
.render_config_yaml <- function(entries, output_dir, seed) {
  lines <- c(
    "# Auto-generated by generate_study_config().",
    "# Fields marked REVIEW were inferred with low confidence -",
    "# verify them before running simulate_study().",
    ""
  )

  od_line <- paste0("output_dir: ", .yaml_quote(output_dir))
  seed_line <- if (is.null(seed)) {
    "seed: \"REVIEW: set seed\""
  } else {
    paste0("seed: ", as.character(seed))
  }

  lines <- c(lines, od_line, seed_line, "", "datasets:")

  for (key in names(entries)) {
    lines <- c(lines, .emit_dataset_block(key, entries[[key]]))
  }

  return(paste(lines, collapse = "\n"))
}

#' Wrap a string in double quotes, escaping any embedded double quotes.
#'
#' @param s `character(1)` - string to quote.
#'
#' @return `character(1)` - the YAML-quoted string.
#' @keywords internal
.yaml_quote <- function(s) {
  return(paste0("\"", gsub("\"", "\\\\\"", s), "\""))
}

#' Emit YAML lines for one dataset block.
#'
#' @param key `character(1)` - dataset key (filename without extension).
#' @param entry `list` - one element of the entries list passed to
#'   `.render_config_yaml()`.
#'
#' @return `character` - YAML lines for this block, including a trailing
#'   blank-line separator.
#' @keywords internal
.emit_dataset_block <- function(key, entry) {
  dataset_type <- entry$dataset_type
  type_comment <- if (dataset_type == "REVIEW") {
    "  # REVIEW: could not infer"
  } else {
    ""
  }

  lines <- c(
    paste0("  ", key, ":"),
    paste0("    dataset_type: \"", dataset_type, "\"", type_comment),
    paste0("    path: ", .yaml_quote(entry$path))
  )

  if (dataset_type == "REVIEW") {
    lines <- c(
      lines,
      paste0(
        "    # detected columns: ",
        paste(entry$cols, collapse = ", ")
      ),
      "    # REVIEW: set dataset_type and required fields by hand",
      ""
    )
    return(lines)
  }

  field_order <- switch(dataset_type,
    "adsl" = c("id_cols", "treatment_cols", "flag_cols", "ordered_col_sets"),
    "bds" = c(
      "id_cols", "param_cols", "visit_cols", "flag_cols", "ordered_col_sets"
    ),
    "occds" = c("id_cols", "seq_col", "flag_cols", "ordered_col_sets"),
    "tte" = c(
      "param_cols", "censor_cols", "flag_cols", "ordered_col_sets"
    )
  )

  for (field in field_order) {
    if (is.null(entry$args[[field]])) next
    lines <- c(
      lines,
      .emit_field(field, entry$args[[field]], entry$confidence[[field]])
    )
  }

  return(c(lines, ""))
}

#' Emit YAML lines for one field of a dataset block.
#'
#' Handles the special cases for `seq_col` (scalar) and `ordered_col_sets`
#' (block-style list of pairs); everything else is a flow-style list.
#'
#' @param field `character(1)` - field name.
#' @param value the field value (`character` vector, scalar, or list of
#'   pairs depending on `field`).
#' @param confidence `character(1)` or `NULL` - REVIEW comment for this
#'   field, appended inline.
#'
#' @return `character` - one or more YAML lines.
#' @keywords internal
.emit_field <- function(field, value, confidence) {
  comment <- if (!is.null(confidence)) paste0("  # ", confidence) else ""

  if (field == "seq_col") {
    val <- if (length(value) == 0 || is.na(value)) "REVIEW" else value
    return(paste0("    ", field, ": ", val, comment))
  }

  if (field == "ordered_col_sets") {
    if (length(value) == 0) {
      return(paste0("    ", field, ": []", comment))
    }
    header <- paste0("    ", field, ":", comment)
    pair_lines <- vapply(value, function(pair) {
      return(paste0("      - [", paste(pair, collapse = ", "), "]"))
    }, character(1))
    return(c(header, pair_lines))
  }

  # Regular flow-style list
  if (length(value) == 0) {
    return(paste0("    ", field, ": []", comment))
  }
  return(paste0(
    "    ", field, ": [", paste(value, collapse = ", "), "]", comment
  ))
}
