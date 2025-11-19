# Generate KPI lab intervals

**\[experimental\]**

Generates lab intervals related to the KPI code.

## Usage

``` r
generate_kpi_lab_timeliness(lab_data, start_date, end_date, afp_data)
```

## Arguments

- lab_data:

  `tibble` Lab data containing information of ES or AFP samples.

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

- afp_data:

  `tibble` AFP surveillance data.

## Value

`tibble` lab data with timeliness columns.

## Details

This function is used in both
[generate_c4_table](https://cdcgov.github.io/sirfunctions/reference/generate_c4_table.md)
and in the lab timeliness KPI violin plots.
