# Identifying new detections

The function adds new detections as specified by the user when they use
[`generate_adhoc_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_adhoc_map.md).
This function inherits arguments from the parent function.

## Usage

``` r
add_new_detection(data_p, country, date_3a, date_3a_a, date_3b)
```

## Arguments

- data_p:

  `tibble` Map data.

- country:

  `str` or `list` Country or a list of countries.

- date_3a:

  `str` ???

- date_3a_a:

  `str` ???

- date_3b:

  `str` ???

## Value

a dataset containing new detections
