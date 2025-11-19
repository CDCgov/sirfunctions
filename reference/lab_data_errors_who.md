# Checks for common data errors in WHO lab data

This function is used internally within
[`lab_data_errors()`](https://cdcgov.github.io/sirfunctions/reference/lab_data_errors.md).
This checks for potential errors in the WHO lab data.

## Usage

``` r
lab_data_errors_who(
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

  `str` Start date of the analysis.

- end.date:

  `str` End date of the analysis.

- ctry_name:

  `list` or `str` A name of a country or a list of countries. Please
  pass lab data directly into lab.data parameter instead.

- error_path:

  `str` File path to store the error log.

- ctry.data:

  `list` **\[deprecated\]**

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/XRG9/lab_data_who.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
lab_data_errors_who(
  ctry.data$lab.data, ctry.data$afp.all.2,
  "2021-01-01", "2023-12-31"
)
} # }
```
