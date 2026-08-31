# ES location and detection-rate map for one prov

This is the prov-filtered equivalent of
[`generate_es_det_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_det_map.md)
and uses identical detection-rate categories, colors, labels, and theme.

## Usage

``` r
generate_prov_es_location_map(
  ctry.data,
  prov_name,
  prov.shape,
  dist.shape,
  es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
  es_end_date = end_date,
  output_path = NULL
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  PROV name.

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- es_start_date, es_end_date:

  ES analysis dates.

- output_path:

  Optional output directory.

## Value

A ggplot or annotated ggarrange object.
