# Assert canonical subject-ID columns are declared in id_cols.

If a canonical subject-ID column (USUBJID or SUBJID) is present in the
data, it must be listed in `id_cols` so it is regenerated as a synthetic
ID rather than value-sampled (which would leak real subject
identifiers).

## Usage

``` r
.assert_required_id_cols(data, id_cols, dataset_name)
```

## Arguments

- data:

  `data.frame` - the real ADaM dataset being glimpsed.

- id_cols:

  `character` - declared ID columns.

- dataset_name:

  `character` - name of the data object for error message.

## Value

`NULL` if assertion passes, otherwise throws an error.
