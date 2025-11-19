# 60-day follow up table

Generates a table summarizing the number of inadequate cases that need
follow up.

## Usage

``` r
generate_60_day_tab(cases.need60day)
```

## Arguments

- cases.need60day:

  `tibble` Summary table containing those that need 60 day follow-up.
  Output of
  [`generate_60_day_table_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md).

## Value

`flextable` A summary of cases requiring 60-day followups per year.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
stool.data <- generate_stool_data(
  ctry.data$afp.all.2, "good", "inadequate",
  "2021-01-01", "2023-12-31"
)
cases.need60day <- generate_60_day_table_data(
  stool.data,
  "2021-01-01", "2023-12-31"
)
generate_60_day_tab(cases.need60day)
} # }
```
