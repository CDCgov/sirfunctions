# Export the AFP linelist

Export the AFP linelist with `adequacy.final2` column. The
`adequacy.final2` column describes the status of a stool sample, such as
if a stool sample is adequate or inadequate. Specifically, it is created
from
[`generate_stool_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_stool_data.md)
which takes parameters on how to deal with missing or inadequate stool
samples.

## Usage

``` r
create_afp_export(
  stool.data,
  country = Sys.getenv("DR_COUNTRY"),
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- stool.data:

  `tibble` AFP data with final adequacy columns. This is the output of
  [`generate_stool_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_stool_data.md).

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
create_afp_export(stool.data)
} # }
```
