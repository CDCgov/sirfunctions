# Function to load the raw lab data locally

This a function to load lab data that are either CSVs or Excel files.

## Usage

``` r
load_lab_data(lab_data_path, sheet_name = NULL)
```

## Arguments

- lab_data_path:

  `str` File path as a string to the lab data.

- sheet_name:

  `str` Name of the sheet to load. This is optional in cases of an Excel
  sheet with multiple tabs.

## Value

`tibble` Lab data loaded from the CSV or Excel file path.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_data_path <- "C:/Users/ABC1/Desktop/lab_data.csv"
lab_data <- load_lab_data(lab_data_path)
} # }
```
