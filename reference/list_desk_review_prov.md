# List available prov_names in country data

Uses `ctry.data$prov$ADM1_NAME` as the preferred source, with
`admin1officialname`, province population, and AFP data used as
fallbacks for country-data objects with alternate naming conventions.

## Usage

``` r
list_desk_review_prov(ctry.data)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

## Value

A sorted character vector of prov names.
