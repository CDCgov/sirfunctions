# Imputes missing site coordinates in ES data

Adds coordinates for ES surveillance sites missing them. This function
is not meant to be exported. This is part of
[`clean_es_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_es_data.md).

## Usage

``` r
impute_site_coord(es.data, dist.shape, ctry.data = lifecycle::deprecated())
```

## Arguments

- ctry.data:

  **\[deprecated\]** `list` This parameter has been deprecated in favor
  of explicitly passing dataframes into the function. This allows for
  greater flexibility in the function.

## Value

`tibble` ES data with imputed coordinates for sites missing them.
