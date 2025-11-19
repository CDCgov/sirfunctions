# Generates a summary table regarding wild and VDPV cases

Generates a summary table regarding wild and VDPV cases

## Usage

``` r
generate_wild_vdpv_summary(
  raw_data,
  start_date,
  end_date,
  risk_table = NULL,
  lab_locs = NULL,
  .group_by = c("whoregion", "SG Priority Level", "place.admin.0", "rolling_period",
    "year_label", "analysis_year_start", "analysis_year_end")
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

- .group_by:

  How to group the results by.

## Value

`tibble` Summary of wild and VDPV cases
