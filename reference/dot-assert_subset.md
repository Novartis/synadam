# Assert that required values are a subset of available values

Assert that required values are a subset of available values

## Usage

``` r
.assert_subset(required_cols, available_cols, dataset_name, col_type = NULL)
```

## Arguments

- required_cols:

  `character` - values to check for.

- available_cols:

  `character` - available values (e.g., from colnames()).

- dataset_name:

  `character` - name of the data object for error message.

- col_type:

  `character` - optional descriptor for value type (e.g., "ID", "Flag").

## Value

`NULL` if assertion passes, otherwise throws an error.
