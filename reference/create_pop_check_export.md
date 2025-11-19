# Exports file for checking population roll-ups

Export the population roll-ups and determine differences between each
population counts.

## Usage

``` r
create_pop_check_export(
  ctry.data,
  country = Sys.getenv("DR_COUNTRY"),
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- ctry.data:

  `list` A large list containing polio data for a country. This is the
  output of either
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md)
  or
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

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
create_pop_check_export(ctry.data)
} # }
```
