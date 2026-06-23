# Suppress R CMD check NOTEs for non-standard evaluation
utils::globalVariables(c(
  ":=", "n", "PARAMCD", "n_occurrences", ".data",
  ".profile_idx", ".profile_data", ".profile_key",
  "param_visits"
))
