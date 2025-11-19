# Impute missing geographic information from the AFP linelist

Impute missing geographic information from the AFP linelist

## Usage

``` r
impute_missing_lab_geo(lab_data, afp_data = NULL)
```

## Arguments

- lab_data:

  `tibble` Lab data to clean.

- afp_data:

  `tibble` AFP data.

## Value

`tibble` Lab data set with imputed geographic columns based on the AFP
table.
