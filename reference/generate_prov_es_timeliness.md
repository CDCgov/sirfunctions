# ES sample-transport timeliness for one prov

This is the prov-filtered equivalent of
[`generate_es_timely()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_timely.md)
and uses the same site colors, three-day target line, labels, and
formatting.

## Usage

``` r
generate_prov_es_timeliness(
  ctry.data,
  prov_name,
  es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
  es_end_date = end_date,
  output_path = NULL,
  add_legend = TRUE,
  .color = "site.name"
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

- add_legend:

  Whether to show the site-name legend.

- .color:

  ES column mapped to point color. Defaults to `site.name`.

## Value

A ggplot object.
