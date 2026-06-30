# Glimpse occurrence counts, ID columns, and sequence column.

Counts the number of occurrences (records) per subject in an OCCDS
dataset and captures the ID and sequence column names needed for spine
construction.

## Usage

``` r
glimpse_occurrence_id_seq(df, id_cols, seq_col)
```

## Arguments

- df:

  `data.frame` - OCCDS dataset containing ID and sequence columns.

- id_cols:

  `character` - name(s) of ID column(s) to group by.

- seq_col:

  `character` - name of the sequence column.

## Value

`summary_occurrence_id_seq` - contains occurrence counts per subject, ID
column names, and sequence column name.

## Examples

``` r
# Capture per-subject occurrence counts (used within glimpse_occds()).
glimpse_occurrence_id_seq(adae, id_cols = "USUBJID", seq_col = "AESEQ")
#> $counts
#> [1] 2 1 3 2 1 2 3 1
#> 
#> $id_cols
#> [1] "USUBJID"
#> 
#> $seq_col
#> [1] "AESEQ"
#> 
#> attr(,"class")
#> [1] "summary_occurrence_id_seq" "summary"                  
```
