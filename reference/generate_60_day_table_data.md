# Generate summary table for those requiring 60-day follow-up

The 60-day table highlights the number of cases per year that need
60-day follow-up. It summarizes the number of cases due for follow up,
those with recorded follow ups, number missing follow ups, and
compatible cases.

## Usage

``` r
generate_60_day_table_data(stool.data, start_date, end_date)
```

## Arguments

- stool.data:

  `tibble` AFP data with stool adequacy columns. This is the output of
  [`generate_stool_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_stool_data.md).

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

## Value

`tibble` A summary table for those requiring 60-day follow-up.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
stool.data <- generate_stool_data(
  ctry.data$afp.all.2,
  "2021-01-01", "2023-12-31",
  "good", "inadequate"
)
table60.days <- generate_60_day_table_data(stool.data, "2021-01-01", "2023-12-31")
} # }
```
