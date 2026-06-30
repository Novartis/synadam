# Emit YAML lines for one dataset block.

Emit YAML lines for one dataset block.

## Usage

``` r
.emit_dataset_block(key, entry)
```

## Arguments

- key:

  `character(1)` - dataset key (filename without extension).

- entry:

  `list` - one element of the entries list passed to
  [`.render_config_yaml()`](https://novartis.github.io/synadam/reference/dot-render_config_yaml.md).

## Value

`character` - YAML lines for this block, including a trailing blank-line
separator.
