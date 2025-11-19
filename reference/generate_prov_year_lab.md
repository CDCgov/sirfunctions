# Generate a summary of samples by year and province

**\[deprecated\]**

Generates a summary table of the number of AFP cases per province and
year. This function was used primarily with
[`generate_prov_timeliness_graph()`](https://cdcgov.github.io/sirfunctions/reference/generate_prov_timeliness_graph.md).
However,
[`generate_prov_timeliness_graph()`](https://cdcgov.github.io/sirfunctions/reference/generate_prov_timeliness_graph.md)
now creates the labels itself so this function is not used anymore.

## Usage

``` r
generate_prov_year_lab(ctry.data, start_date, end_date)
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

`tibble` A table containing summary of AFP cases by year and province.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
prov.labels <- generate_prov_year_lab(ctry.data, "2021-01-01", "2023-12-31")
} # }
```
