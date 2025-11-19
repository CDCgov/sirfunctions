# Find established sites

**\[experimental\]**

Finds established ES sites defined as those that has been active for for
at least 12 months since the end date with at least 10 collections.

## Usage

``` r
get_es_site_age(es_data, end_date)
```

## Arguments

- es_data:

  `tibble` ES data

- end_date:

  `str` End date to anchor analysis to

## Value

`tibble` A summary of established ES sites
