# Check data quality errors from the country data

Performs a check for different errors in the AFP linelist and population
files. It also alerts the users for GUIDs that have changed.

## Usage

``` r
ctry_data_errors(ctry.data, error_path = Sys.getenv("DR_ERROR_PATH"))
```

## Arguments

- ctry.data:

  `list` Large list containing polio country data. This is the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- error_path:

  `str` Path where to store checks in `ctry.data`.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry_data_errors(ctry.data)
} # }
```
