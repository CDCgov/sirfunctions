# Summary of lab sample timeliness

Generates a summary of the timeliness of samples for specific intervals.

## Usage

``` r
generate_lab_timeliness(
  lab_data,
  spatial.scale,
  start_date,
  end_date,
  start.date = lifecycle::deprecated(),
  end.date = lifecycle::deprecated()
)
```

## Arguments

- lab_data:

  `tibble` Pre-cleaned lab data loaded from EDAV by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- spatial.scale:

  `str` Spatial scale to analyze the data. Valid values are
  `"ctry", "prov", "all"`.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- start.date:

  `str` **\[deprecated\]** renamed in favor of `start_date`.

- end.date:

  `str` **\[deprecated\]** renamed in favor of `end_date`.

## Value

`tibble` A table with timeliness data summary.

## Examples

``` r
if (FALSE) { # \dontrun{
init_dr("algeria", start_date = "2021-01-01", end_date = "2023-12-31")
lab.timeliness.ctry <- generate_lab_timeliness(
  dplyr::filter(lab_data, ctry == "ALGERIA"), "ctry", start_date, end_date
)
} # }
```
