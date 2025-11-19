# Clean environmental surveillance data

The cleaning step will attempt to impute missing site coordinates and
create standardized columns used in the desk review.

## Usage

``` r
clean_es_data(es.data, dist.shape, ctry.data = lifecycle::deprecated())
```

## Arguments

- es.data:

  `tibble` Environmental surveillance data.

- dist.shape:

  `sf` District shapefile.

- ctry.data:

  **\[deprecated\]** `list` This parameter has been deprecated in favor
  of explicitly passing dataframes into the function. This allows for
  greater flexibility in the function.

## Value

`tibble` Cleaned environmental surveillance data.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
ctry.data$es <- clean_es_data(ctry.data$es, ctry.data$dist)
} # }
```
