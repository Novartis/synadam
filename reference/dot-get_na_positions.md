# Extract NA positions from a vector.

Extract NA positions from a vector.

## Usage

``` r
.get_na_positions(x, na_mode = "mirror", na_noise = 0.05, seed = NULL)
```

## Arguments

- x:

  `vector` - input vector.

- na_mode:

  `character` - "mirror" to capture NA positions, "none" to ignore NAs
  in simulation.

- na_noise:

  `numeric` - proportion of positions to flip.

- seed:

  `integer` - random seed for reproducibility.

## Value

`integer` - indices of NA positions (with noise applied), or empty
vector if na_mode is "none".
