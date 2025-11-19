# Calculate the NPAFP rate on a rolling basis

Calculates the NPAFP rate on a rolling basis, based on the start and end
dates specified.

## Usage

``` r
npafp_rolling(
  afp.data,
  year.pop.data,
  start_date,
  end_date,
  spatial_scale,
  pending
)
```

## Arguments

- afp.data:

  `tibble` AFP linelist, Either from `raw.data$afp` of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  or `ctry.data$afp.all.2` of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- year.pop.data:

  `tibble` Summary table containing year and pop data. This is created
  inside
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md).

- start_date:

  `str` Start date to calculate the rolling interval for.

- end_date:

  `str` End date to calculate the rolling interval for.

- spatial_scale:

  Spatial scale. Valid arguments are: `"ctry", "prov", "dist`.

- pending:

  `logical` Should cases classified as `PENDING` or `LAB PENDING` be
  included in calculations? Default `TRUE`.

## Value

A summary table including NPAFP rates and population data.
