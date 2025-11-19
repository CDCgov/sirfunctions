# Generate ES data with viral detection columns

**\[deprecated\]**

The function importantly adds the `ed.detect`, `all_dets`, and `year`
columns to the environmental surveillance data.

## Usage

``` r
generate_es_data_long(es.data)
```

## Arguments

- es.data:

  `tibble` ES data.

## Value

`tibble` ES data with viral detection columns.

## Details

This function will is now part of the
[`clean_es_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_es_data.md).

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
ctry.data$es <- clean_es_data(ctry.data$es, ctry.data$dist)
es.data.long <- generate_es_data_long(ctry.data$es)
} # }
```
