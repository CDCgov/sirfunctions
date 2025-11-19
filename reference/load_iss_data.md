# Read ISS/eSURV data

The function is written to assist in load the ISS data from a path
specified by the user during
[`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).
This function is not meant to be exported.

## Usage

``` r
load_iss_data(iss_path, sheet_name = NULL)
```

## Arguments

- iss_path:

  `str` Path to the excel or csv file.

- sheet_name:

  `str` Optional name of the ISS data. This is mainly used if the path
  is to an Excel file and that Excel file has multiple tabs.

## Value

`tibble` ISS/eSURV data loaded into a tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
iss_path <- "C:/Users/ABC1/Desktop/iss_data.csv"
iss_data <- load_iss_data(iss_path)
} # }
```
