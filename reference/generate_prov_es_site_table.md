# ES site details table for one prov

This is the prov-filtered equivalent of
[`generate_es_tab()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_tab.md)
and preserves the main desk-review calculations, labels, and flextable
formatting.

## Usage

``` r
generate_prov_es_site_table(
  ctry.data,
  prov_name,
  es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
  es_end_date = end_date
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  PROV name.

- es_start_date, es_end_date:

  ES analysis dates.

## Value

A flextable.
