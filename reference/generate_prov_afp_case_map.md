# PROV-only paralytic polio and compatible-case map

PROV-only paralytic polio and compatible-case map

## Usage

``` r
generate_prov_afp_case_map(
  ctry.data,
  prov_name,
  prov.shape,
  start_date,
  end_date = lubridate::today(),
  output_path = NULL,
  dist.shape = NULL
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  One value from `list_desk_review_prov(ctry.data)`.

- prov.shape:

  PROV geometry in long format.

- start_date, end_date:

  Analysis dates.

- output_path:

  Optional directory in which to save the PNG. `NULL` does not write a
  file.

- dist.shape:

  Optional DIST geometry in long format. When supplied, district
  boundaries are drawn inside the selected prov.

## Value

A ggplot object.
