# Title

Title

## Usage

``` r
add_seq_capacity(
  df,
  ctry_col = "ctry",
  lab_locs = NULL,
  lab_data_cleaned = NULL,
  date_col = "dateonset"
)
```

## Arguments

- df:

  `tibble` Dataset with at least a country column to join to.

- ctry_col:

  `str` Country column in `df`. Defaults to `"ctry"`.

- lab_locs:

  `tibble` Lab testing information table. Defaults to `NULL`. If `NULL`,
  attempts to download the table from EDAV.

- lab_data_cleaned:

  `tibble` Cleaned lab data information table. Defaults to `NULL`. If
  `NULL`, uses the lab testing information table.

- date_col:

  `str` Date column in `df` used to determine sequencing capacity.
  Defaults to `"dateonset"`. Use `"date"` for standardized AFP data and
  `"collect.date"` for environmental surveillance data.

## Value

`tibble` A dataset with country sequencing capacity information
attached.
