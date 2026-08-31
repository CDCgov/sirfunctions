# Annual AFP timeliness map panels by district for one prov

The four indicators use the cleaned desk-review flags `noti.7d.on`,
`inv.2d.noti`, `coll.3d.inv`, and `ship.3d.coll`. One faceted plot is
returned for each indicator, with one district-map panel per year.

## Usage

``` r
generate_prov_district_timeliness_panel(
  ctry.data,
  prov_name,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  output_path = NULL
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md)
  and
  [`clean_ctry_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_ctry_data.md).

- prov_name:

  PROV name.

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- start_date, end_date:

  Analysis dates.

- output_path:

  Optional output directory.

## Value

A named list of four ggplot objects, one per timeliness indicator.
