# Generate timeliness columns

**\[experimental\]**

The function generates timeliness columns in the positives dataset.

## Usage

``` r
generate_pos_timeliness(
  raw_data,
  start_date,
  end_date,
  risk_table = NULL,
  lab_locs = NULL
)
```

## Arguments

- raw_data:

  `list` Global polio surveillance dataset. Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

- risk_table:

  `tibble` Priority level of each country. Defaults to `NULL`, which
  will download the information directly from EDAV.

- lab_locs:

  `tibble` Summary of the sequencing capacities of labs. Output of
  [`get_lab_locs()`](https://cdcgov.github.io/sirfunctions/reference/get_lab_locs.md).
  Defaults to `NULL`, which will download the information directly from
  EDAV. .

## Value

`tibble` Columns added

## Details

This function is used in
[`generate_c1_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c1_table.md)
and
[`generate_timely_det_violin()`](https://cdcgov.github.io/sirfunctions/reference/generate_timely_det_violin.md).
