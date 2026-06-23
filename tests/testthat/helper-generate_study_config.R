# Real-study column-name fixtures used by test-generate_study_config.R.
#
# These are the actual columns from two real studies, used to assert that
# the generate_study_config functionality can handle real-world ADaM data.

.test_study_a_cols <- list(
  adsl = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "CCS", "ASR", "AGE",
    "AGEGR1", "AGEGR1N", "COUNTRY", "AGEU", "RACE", "RACEL", "RACES",
    "SEX", "SEXL", "ARM", "ARMCD", "ACTARM", "ACTARMCD", "TRT01P",
    "TRT01PL", "TRT01PN", "TRT01A", "TRT01AN", "TRT01AL", "TR01SDT",
    "TR01SDTM", "TR01EDT", "TR01EDTM", "TRTSDT", "TRTSDTM", "TRTEDT",
    "TRTEDTM", "TRTDURD", "TRTDURW", "TRTDURM", "EXPCAT", "EXPCATN",
    "SFUEDT", "NFE2L2", "KEAP1", "CUL3", "ETHNIC", "ETHNICN", "ETHNICL",
    "BMISCR", "WGTSCR", "HGTSCR", "SCFAILFL", "SAFFL", "FASFL", "DDSFL",
    "ECOGBL", "EOTSTT", "POSFURES", "DCTREAS", "EOTSTTN", "EOTSTTL",
    "DCTREASP", "RFICDT", "NWTHYDT", "DISPRDT", "LSTALVDT", "RFICWDT",
    "DTHDT", "DTHDY", "DTHDTC", "DTHONTFL", "DTHCAUS", "ANPPDDT",
    "NCTXSDT", "NCTXEDT", "NCTX2SDT", "ACUTDT", "LOSFUDT", "DTHSOC",
    "DTHPT", "SMOKHIST", "POSTFUP"
  ),
  adae = c(
    "STUDYID", "USUBJID", "SUBJID", "CCS", "SEX", "COUNTRY", "AGE",
    "RACE", "ETHNIC", "ASR", "FASFL", "SAFFL", "RFICWDT", "DTHDT",
    "TRT01PN", "TRT01P", "TRT01PL", "TRT01AL", "TRT01AN", "TRT01A",
    "TRTSDT", "TRTSDTM", "TRTEDT", "TRTEDTM", "SFUEDT", "ACUTDT",
    "AESEQ", "AESPID", "SAEID", "AETERM", "AEDECOD", "AEBODSYS",
    "AEBDSYCD", "AELLT", "AELLTCD", "AEHLT", "AEHLTCD", "AEHLGT",
    "AEHLGTCD", "AECONTRT", "AECAT", "AESTDTC", "ASTDT", "ASTDTM",
    "ASTDTF", "AEENDTC", "AENDT", "AENDTM", "ASTDY", "AESTDY", "AENDY",
    "AEENDY", "ADURN", "ADURU", "TRTEMFL", "AETRTEM", "EVTDLT", "AOCCFL",
    "AOCC91FL", "AOCC92FL", "AOCC93FL", "AOCCGR9", "AOCCSFL", "TRTP",
    "TRTPN", "TRTPL", "TRTA", "TRTAN", "TRTAL", "AESER", "AESERN",
    "AESERL", "AESDTH", "AESLIFE", "AESDISAB", "AESHOSP", "AESCONG",
    "AESMIE", "AEREL", "AERELN", "AERELL", "AETOXGR", "AETOXGRN",
    "AETOXGRL", "AEACN", "AEACNN", "AEACNL", "AEOUT", "AEOUTN", "AEOUTL",
    "ANL01FL", "ANL01DSC"
  ),
  adlb = c(
    "STUDYID", "USUBJID", "SITEID", "AGE", "AGEU", "SEX", "RACE", "ASR",
    "ETHNIC", "COUNTRY", "CCS", "FASFL", "SAFFL", "TRT01P", "TRT01PL",
    "TRT01PN", "TRT01A", "TRT01AL", "TRT01AN", "TRTSDT", "TRTSDTM",
    "TRTEDT", "TRTEDTM", "DTHDT", "ACUTDT", "LBTEST", "LBTESTCD",
    "VISITNUM", "VISIT", "AVISITN", "AVISIT", "LBDTC", "ADT", "ADY",
    "ATM", "ADTM", "PARCAT1", "PARCAT2", "PARAM", "PARAMCD", "PARAMTYP",
    "AVAL", "AVALC", "ABLFL", "BASE", "BASEC", "CHG", "PCHG", "ANRLO",
    "ANRHI", "ANRIND", "BNRIND", "ATOXGR", "ATOXGRN", "BTOXGR", "BTOXGRN",
    "LBPCSNUM", "ONTRTFL", "PSTBLFL", "DTYPE", "ANL01FL", "ANL01DSC",
    "ANL02FL", "ANL02DSC", "paramr", "ANRINDS", "lbstresu", "DOMAIN",
    "LBCAT", "LBSCAT", "LBORRES", "LBORRESU", "LBORNRLO", "LBORNRHI",
    "LBSTRESC", "LBSTRESN", "LBSTNRLO", "LBSTNRHI", "LBNRIND", "LBSTAT",
    "LBSPEC", "LBMETHOD", "LBFAST", "LBENDTC", "LBDY", "LBPARM", "BNRINDS"
  ),
  adex = c(
    "STUDYID", "USUBJID", "COUNTRY", "CCS", "AGE", "AGEU", "SEX", "RACE",
    "ETHNIC", "ASR", "SAFFL", "FASFL", "ACTARM", "ACTARMCD", "ARM",
    "ARMCD", "TRT01P", "TRT01A", "TRTSDT", "TRTSDTM", "TRTEDT", "TRTEDTM",
    "PARAM", "PARAMCD", "PARAMTYP", "AVAL", "AVALC", "AVALCAT1",
    "AVALCA1N", "DTHDT", "AVALCAT2", "ACUTDT", "AVALCA2N"
  ),
  adpp = c(
    "STUDYID", "USUBJID", "ASEQ", "COUNTRY", "CCS", "ACUTDT", "AGE",
    "AGEU", "SEX", "RACE", "ETHNIC", "ASR", "SAFFL", "FASFL", "PKFL",
    "TRT01PL", "TRT01PN", "TRT01P", "TRT01AL", "TRT01A", "TRT01AN",
    "AVISIT", "AVISITN", "DOSREFID", "FPKFL", "TRTSDT", "TRTSDTM",
    "TRTEDT", "TRTEDTM", "PARAM", "PARAMCD", "AVAL", "AVALC", "DTHDT",
    "ANL01FL", "ANL01DSC", "ANLPRNT", "PPEXCCO", "PARCAT1"
  ),
  adrecist = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "TRTSDTM", "TRTSDT",
    "TRTEDTM", "TRTEDT", "TRT01P", "TRT01PN", "TRT01A", "TRT01AN", "SEX",
    "RACE", "ETHNIC", "DTHDT", "COUNTRY", "CCS", "ASR", "ARMCD", "ARM",
    "ACTARMCD", "ACTARM", "AGEU", "AGE", "ACUTDT", "SAFFL", "FASFL",
    "AVISITN", "AVISIT", "TRLNKIDN", "TRLNKID", "PARAMCD", "PARAM",
    "AVAL", "AVALC", "BASE", "CHG", "PCHG", "PARAMTYP", "DTYPE", "ADT",
    "ADY", "TRGRPIDN", "TRGRPID", "TULOCG1N", "TULOCGR1", "TULOC",
    "TULOCDTL", "TRMETHON", "TRMETHOD", "ABLFL", "ANL01FL", "ANL01DSC",
    "ANL03FL", "ANL03DSC", "ANL04FL", "ANL04DSC", "TRREASND", "VISIT",
    "VISITNUM", "LSTALVDT", "RFICWDT", "NWTHYDT", "DISPRDT", "NCTXEDT",
    "NCTX2SDT", "EVNTDESC", "STARTDT", "CNSR", "CNSDTDSC", "ANL05FL",
    "ANL05DSC"
  ),
  advs = c(
    "STUDYID", "USUBJID", "SITEID", "SUBJID", "AVISIT", "AVISITN", "ADT",
    "ADY", "ADTC", "ADTM", "ATM", "ANL02FL", "PSTBLFL", "PARAMCD",
    "PARAM", "PARAMN", "AVAL", "AVALC", "ABLFL", "BASE", "CHG", "PCHG",
    "ANL01DSC", "ANL01FL", "ANL02DSC", "CRIT1", "CRIT1FL", "CRIT2",
    "CRIT2FL", "ONTRTFL", "AVALCAT1", "VSPOS", "TRTA", "TRTP", "SAFFL",
    "FASFL", "SEX", "SFUEDT", "RACE", "ETHNIC", "ASR", "ARM", "ARMCD",
    "ACTARM", "ACTARMCD", "COUNTRY", "CCS", "TRTEDT", "TRTSDT", "TRT01A",
    "TRT01AN", "TRT01P", "TRT01PN", "TRTSDTM", "TRTEDTM", "AGE", "AGEU",
    "ACUTDT"
  ),
  adeg = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "TRTSDTM", "TRTSDT",
    "TRTEDTM", "TRTEDT", "TRT01P", "TRT01PN", "TRT01A", "TRT01AN", "SEX",
    "RACE", "ETHNIC", "DTHDT", "COUNTRY", "CCS", "ASR", "ARMCD", "ARM",
    "ACTARMCD", "ACTARM", "AGEU", "AGE", "ACUTDT", "SAFFL", "FASFL",
    "EGSEQ", "EGPOS", "PARCAT1", "PARAM", "PARAMCD", "PARAMN", "PARAMR",
    "ADT", "ADTM", "ATM", "ADY", "AVISIT", "AVISITN", "VISIT", "VISITNUM",
    "ATPT", "ATPTN", "AVAL", "AVALC", "BASE", "BASEC", "CHG", "PCHG",
    "ABLFL", "DTYPE", "ANL01FL", "ANL01DSC", "ONTRTFL", "CRIT1", "CRIT1FL",
    "CRIT2", "CRIT2FL", "CRIT3", "CRIT3FL", "CRIT4", "CRIT4FL", "CRIT5",
    "CRIT5FL", "TRTP", "TRTPN", "TRTA", "TRTAN"
  )
)

.test_pilot_cols <- list(
  adsl = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "AGEU",
    "AGEGR1", "AGEGR1N", "AGEGR2", "AGEGR2N", "SEX", "RACE",
    "RACEC2", "RACES", "RACEGR1", "ETHNIC", "COUNTRY", "CCS",
    "ASR", "SCRNFL", "RANDFL", "FASFL", "SCFAILFL", "SAFFL",
    "ACTARM", "ACTARMCD", "ARM", "ARMCD", "TRT01P", "TRT01PN",
    "TRT01A", "TRT01AN", "TRTSEQP", "TRTSEQA", "TRTSDT", "TRTSTM",
    "TRTSDTM", "TRTEDT", "TRTETM", "TRTEDTM", "TR01SDT", "TR01STM",
    "TR01SDTM", "TR01EDT", "TR01ETM", "TR01EDTM", "AP01SDT", "AP01STM",
    "AP01SDTM", "AP01EDT", "AP01ETM", "AP01EDTM", "VCUTDTC", "EOTSTT",
    "DCTRS", "DCTRSP", "EOTDT", "EOSSTT", "DCSRS", "DCSRSP",
    "EOSDT", "EOP01STT", "DCP01RS", "DCP01RSP", "EOP01DT", "RFICDT",
    "RAND1DT", "RAND1DTM", "PROVER", "ASTRVAL1", "ASTRVAL2", "ASTRVAL3",
    "PSTRVAL1", "PSTRVAL2", "PSTRVAL3", "TABSTAT", "IMAGSTAT", "ESCPFL",
    "RSCUFL", "PMRFL", "RFSTDTC", "LSTDOSTM", "LSTDOSDT", "LSTDOSDY",
    "DTHDT", "SYMSEV", "TIMEPIW", "TIMEGCAD", "TIMEGCAW", "TIMEGCAY"
  ),
  adlb = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "SEX", "RACE",
    "COUNTRY", "ETHNIC", "CCS", "ASR", "RANDFL", "FASFL", "SAFFL",
    "ARM", "ARMCD", "TRT01P", "TRT01PN", "TRT01A", "TRT01AN",
    "RAND1DT", "TRTSDT", "TRTEDT", "ABLFL", "ADT", "ADTM", "ADY",
    "ANL01FL", "ANL02FL", "ANL03FL", "ANRHI", "ANRIND", "ANRINDS",
    "ANRLO", "APERIOD", "APERIODC", "ASEQ", "ATM", "ATOXGR",
    "ATOXGRN", "AVAL", "AVALC", "AVALCA1N", "AVALCAT1", "AVISIT",
    "AVISITN", "BASE", "BASEC", "BASETYPE", "BNRIND", "BNRINDS",
    "BTOXGR", "BTOXGRN", "CHG", "DTYPE", "LABTP", "LBDTC", "LBFAST",
    "LBREFID", "LBSEQ", "LBSTRESC", "LBSTRESU", "LBTESTCD", "ONTRTFL",
    "PARAM", "PARAMCD", "PARAMTYP", "PARCAT1", "PARCAT2", "PARCAT3",
    "PCHG", "PCSNUM", "PSTBSPFL", "TRTA", "TRTAN", "TRTP", "TRTPN",
    "VISIT", "VISITNUM"
  ),
  adpr = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "SEX", "RACE",
    "ETHNIC", "COUNTRY", "CCS", "ASR", "RANDFL", "FASFL", "SAFFL",
    "ARM", "ARMCD", "TRT01P", "TRT01PN", "TRT01A", "TRT01AN",
    "RAND1DT", "TRTSDT", "TRTEDT", "PRCAT", "PRSEQ", "PRTRT",
    "PRBODSYS", "PRSOC", "PRINDC", "PRINDC1", "PRINDC2", "PRDECOD",
    "PRSTDTC", "PRSTDY", "ASTDT", "ASTDTF", "ASTDY", "PRENDTC",
    "PRENDY", "AENDT", "AENDTF", "AENDY", "APERIOD", "APERIODC",
    "ADURN", "ADURU", "PRONGO", "PREFL", "ONTRTFL", "PRENRF",
    "TRTA", "TRTAN"
  ),
  adrisk = c(
    "STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "SEX", "RACE",
    "ETHNIC", "COUNTRY", "CCS", "ASR", "RANDFL", "FASFL", "SAFFL",
    "ARM", "ARMCD", "TRT01P", "TRT01PN", "TRT01A", "TRT01AN",
    "RAND1DT", "TRTSDT", "TRTEDT", "AESEQ", "AETERM", "AEDECOD",
    "AEBODSYS", "AEBDSYCD", "AELLT", "AELLTCD", "AEPTCD", "AEHLT",
    "AEHLTCD", "AEHLGT", "AEHLGTCD", "AESTDTC", "AESTDY", "ASTDT",
    "ASTDTF", "AEENDTC", "AEENDY", "AENDT", "AENDTF", "ASTDY",
    "AENDY", "ADURN", "ADURU", "APERIOD", "APERIODC", "TRTEMFL",
    "EPOCH", "AEACN", "AECONTRT", "AEOUT", "AESCONG", "AESDISAB",
    "AESDTH", "AESHOSP", "AESLIFE", "AESMIE", "AESER", "AESEV",
    "AESEVN", "AEREL", "AERELGC", "AEACNGC", "TRTA", "TRTAN",
    "AOCCFL", "AOCCSFL", "AOCCHGFL", "AOCCHFL", "AOCCPFL", "AESOABR",
    "RKNAM", "SPPFL", "DSURFL", "RMPFL", "PSURFL", "IBFL", "ADRFL",
    "OTHSRFL", "MISINFFL", "EXPRULFL", "ADRUSIFL", "ADRJPIFL",
    "UNDISFL", "AESIFL", "MHFL", "RKCAT"
  )
)

##### Fixtures containing simple mock ADaM datasets #####

# There is one mock dataset per data type; ADSL, BDS, OCCDS, TTE.
.test_adsl <- function() {
  dplyr::tibble(
    USUBJID  = as.character(1:4),
    STUDYID  = "TEST001",
    TRT01A   = rep(c("Treatment A", "Treatment B"), each = 2),
    TRT01AN  = rep(c(1, 2), each = 2),
    SAFFL    = "Y",
    ITTFL    = "Y",
    AGE      = c(25, 35, 45, 55),
    REGION1  = c("NA", "EU", "NA", "EU"),
    REGION1N = c(1, 2, 1, 2)
  )
}

.test_adlb <- function() {
  dplyr::tibble(
    USUBJID  = rep(as.character(1:4), each = 2),
    STUDYID  = "TEST001",
    TRT01A   = rep(rep(c("Treatment A", "Treatment B"), each = 2), each = 2),
    TRT01AN  = rep(rep(c(1, 2), each = 2), each = 2),
    REGION1  = rep(c("NA", "EU", "NA", "EU"), each = 2),
    REGION1N = rep(c(1, 2, 1, 2), each = 2),
    PARAM    = "Alanine Aminotransferase",
    PARAMCD  = "ALT",
    AVAL     = c(25, 30, 28, 32, 27, 29, 26, 31),
    ANL01FL  = "Y"
  )
}

.test_adae <- function() {
  dplyr::tibble(
    USUBJID = c("1", "1", "2", "3", "3", "4"),
    STUDYID = "TEST001",
    TRT01A = c(
      "Treatment A", "Treatment A", "Treatment A",
      "Treatment B", "Treatment B", "Treatment B"
    ),
    TRT01AN = c(1, 1, 1, 2, 2, 2),
    REGION1 = c("NA", "NA", "EU", "NA", "NA", "EU"),
    REGION1N = c(1, 1, 2, 1, 1, 2),
    AESEQ = c(1, 2, 1, 1, 2, 1),
    AEBODSYS = c(
      "Gastrointestinal disorders", "Nervous system disorders",
      "Gastrointestinal disorders", "Nervous system disorders",
      "Nervous system disorders", "Skin disorders"
    ),
    AEDECOD = c(
      "Nausea", "Headache", "Vomiting", "Headache",
      "Dizziness", "Rash"
    ),
    AOCCFL = "Y",
    TRTEMFL = "Y"
  )
}

.test_adtte <- function() {
  dplyr::tibble(
    USUBJID  = as.character(1:4),
    STUDYID  = "TEST001",
    TRT01A   = rep(c("Treatment A", "Treatment B"), each = 2),
    TRT01AN  = rep(c(1, 2), each = 2),
    REGION1  = c("NA", "EU", "NA", "EU"),
    REGION1N = c(1, 2, 1, 2),
    PARAM    = "Overall Survival",
    PARAMCD  = "OS",
    AVAL     = c(365, 500, 250, 400),
    CNSR     = c(0, 1, 0, 1),
    EVNTDESC = c("Death", "Censored", "Death", "Censored"),
    ANL01FL  = "Y"
  )
}

##### Helper functions #####

#' Write a named list of ADaM datasets as .sas7bdat files in a fresh temp dir.
.create_test_dataset <- function(datasets) {
  dir <- tempfile("adam_")
  dir.create(dir)
  for (nm in names(datasets)) {
    entry <- datasets[[nm]]
    df <- if (is.data.frame(entry)) {
      entry
    } else {
      dplyr::as_tibble(stats::setNames(
        replicate(length(entry), character(0), simplify = FALSE),
        entry
      ))
    }
    path <- file.path(dir, paste0(nm, ".sas7bdat"))
    suppressWarnings(haven::write_sas(df, path))
  }
  return(dir)
}

#' Compare two parsed generate_study_config() YAMLs for semantic equality.
.expect_config_equal <- function(actual, expected) {
  testthat::expect_setequal(
    names(actual$datasets), names(expected$datasets)
  )
  for (key in names(expected$datasets)) {
    testthat::expect_mapequal(
      actual$datasets[[key]], expected$datasets[[key]]
    )
  }
  top_keys <- setdiff(names(expected), "datasets")
  testthat::expect_equal(actual[top_keys], expected[top_keys])
}

#' Strip non-deterministic path fields from a parsed
#' generate_study_config() YAML.
#'
#' @param cfg `list` - parsed YAML config as returned by `yaml::read_yaml()`.
.strip_paths <- function(cfg) {
  cfg$output_dir <- NULL
  cfg$datasets <- lapply(cfg$datasets, function(ds) {
    ds$path <- NULL
    return(ds)
  })
  return(cfg)
}
