# Get missingness of date variables in the lab dataset

Obtains the percentage of missingness in date variables within the lab
dataset

## Usage

``` r
get_lab_date_col_missingness(lab_data, group_by = NULL)
```

## Arguments

- lab_data:

  `tibble` Lab data.

- group_by:

  `str` A column or a vector of columns to group results by.

## Value

`tibble` Summary of missingness of date variables

## Examples

``` r
if (FALSE) { # \dontrun{
get_lab_date_col_missingness(lab_data)
} # }
```
