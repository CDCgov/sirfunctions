# Generate a summary of AFP samples by year

**\[deprecated\]**

Generates a summary table of the number of AFP cases per country and
year. This function is used primarily with
[`generate_ctry_timeliness_graph()`](https://cdcgov.github.io/sirfunctions/reference/generate_ctry_timeliness_graph.md)
as a label of the y-axis. However, as of sirfunctions 1.3.0,
[`generate_ctry_timeliness_graph()`](https://cdcgov.github.io/sirfunctions/reference/generate_ctry_timeliness_graph.md)
now creates its own labels.

## Usage

``` r
generate_year_lab(ctry.data, start_date, end_date)
```

## Arguments

- ctry.data:

  `list` Large list containing country polio data. This is the output of
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md)
  or
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

## Value

`tibble` A table containing summary of AFP cases by year and country.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
ctry.labels <- generate_year_lab(ctry.data, "2021-01-01", "2023-12-31")
} # }
```
