# Generate the complete prov AFP review set

This convenience function calls all nine prov outputs and returns them
in a named list. Use `list_desk_review_prov(ctry.data)` to obtain valid
values for `prov_name` or iterate over all prov_names.

## Usage

``` r
generate_prov_desk_review_outputs(
  ctry.data,
  prov_name,
  dist.extract,
  pstool,
  dstool,
  cases.need60day,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  output_path = NULL,
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

- dist.extract:

  District output from
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md).

- pstool, dstool:

  Province and district outputs from
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

- cases.need60day:

  Output from
  [`generate_60_day_table_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md).

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- start_date, end_date:

  Analysis dates.

- output_path:

  Optional directory for PNG files. Tables are returned and are not
  written to disk.

- es_start_date, es_end_date:

  ES analysis dates. By default, the ES period is the year ending on
  `end_date`.

## Value

A named list of PROV figures, timeliness panels, and flextables.
