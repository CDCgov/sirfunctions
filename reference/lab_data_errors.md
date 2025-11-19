# Generate a log of potential errors in the lab data

Checks the loaded lab data for potential issues. The function will
detect whether the lab data loaded either came from the regional office
or from global.

## Usage

``` r
lab_data_errors(
  lab.data,
  afp.data,
  start.date = start_date,
  end.date = end_date,
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

## Value

None. It outputs locally an Excel file containing the error log.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/ABC1/Desktop/lab_data.xlsx"
start_date <- "2021-01-01"
end_date <- "2023-12-31"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
lab_data_errors(ctry.data$lab.data, ctry.data$afp.data)
} # }
```
