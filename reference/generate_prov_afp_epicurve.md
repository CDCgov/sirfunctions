# PROV AFP epicurve

PROV AFP epicurve

## Usage

``` r
generate_prov_afp_epicurve(
  ctry.data,
  prov_name,
  start_date,
  end_date = lubridate::today(),
  output_path = NULL
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  One value from `list_desk_review_prov(ctry.data)`.

- start_date, end_date:

  Analysis dates.

- output_path:

  Optional directory in which to save the PNG. `NULL` does not write a
  file.

## Value

A ggplot object with weekly AFP cases faceted by onset year.
