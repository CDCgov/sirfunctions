# ES detection dot chart for one prov

This is the prov-filtered equivalent of
[`generate_es_site_det()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_site_det.md)
and uses the same SIA shading, detection colors, labels, and theme.

## Usage

``` r
generate_prov_es_detection_chart(
  ctry.data,
  prov_name,
  es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
  es_end_date = end_date,
  output_path = NULL,
  vaccine_types = NULL,
  detection_types = NULL
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

- output_path:

  Optional output directory.

- vaccine_types, detection_types:

  Optional named color vectors. Defaults match the main desk-review
  chart.

## Value

A ggplot object.
