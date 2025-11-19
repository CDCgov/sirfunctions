# Title

Title

## Usage

``` r
add_seq_capacity(df, ctry_col = "ctry", lab_locs = NULL)
```

## Arguments

- df:

  `tibble` Dataset with at least a country column to join to.

- lab_locs:

  `tibble` Lab testing information table. Defaults to `NULL`. If `NULL`,
  attempts to download the table from EDAV.

## Value

`tibble` A dataset with country lab information attached.
