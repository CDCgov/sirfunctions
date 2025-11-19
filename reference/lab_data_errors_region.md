# Check common errors in the regional lab data.

Error checking for regional lab data. This is a helper function meant to
be used inside
[`lab_data_errors()`](https://cdcgov.github.io/sirfunctions/reference/lab_data_errors.md).

## Usage

``` r
lab_data_errors_region(
  lab.data,
  afp.data,
  start.date,
  end.date,
  ctry_name = Sys.getenv("DR_COUNTRY"),
  error_path = Sys.getenv("DR_ERROR_PATH"),
  ctry.data = lifecycle::deprecated()
)
```

## Arguments

- lab.data:

  `tibble` Polio lab data.

- afp.data:

  `tibble` AFP linelist.

- start.date:

  `str` Start date of analysis.

- end.date:

  `str` End date of analysis.

- ctry_name:

  `str` Name of the country. Defaults to the desk review country.

- error_path:

  `str` Path to folder to save the error log.

- ctry.data:

  `list` Large list containing polio country data. Output of either
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).
  Note that lab data must be attached to`ctry.data` as `lab_data`.

## Value

None. It outputs an Excel file locally containing the error log.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/XRG9/lab_data_region.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
lab_data_errors_region(
  ctry.data$lab.data, ctry.data$afp.all.2,
  "2021-01-01", "2023-12-31"
)
} # }
```
