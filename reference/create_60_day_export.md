# Export 60-day follow up table

Exports the output of
[generate_60_day_table_data](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md)
into an Excel file.

## Usage

``` r
create_60_day_export(
  cases.need60day,
  country = Sys.getenv("DR_COUNTRY"),
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- cases.need60day:

  `tibble` Summary table for 60-day follow-up.

- country:

  `str` Name of the country.

- excel_output_path:

  `str` Output path of the Excel file.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
stool.data <- generate_stool_data(
  ctry.data$afp.all.2, "good", "inadequate",
  "2021-01-01", "2023-12-31"
)
cases.need60day <- generate_60_day_table_data(stool.data, start_date, end_date)
create_60_day_export(cases.need60day)
} # }
```
