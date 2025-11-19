# Calculate NPAFP by year and geographic level

Helper function for calculating the NPAFP rate based on the geographic
level. This function is used inside
[`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md).

## Usage

``` r
npafp_year(afp.data, pop.data, year.data, spatial_scale, pending)
```

## Arguments

- afp.data:

  `tibble` AFP linelist. Either from `raw.data$afp` of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  or `ctry.data$afp.all.2` of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- pop.data:

  `tibble` Population data. Either from `raw.data${ctry/prov/dist}.pop`
  of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  or `ctry.data${ctry/prov/dist}.pop` of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- year.data:

  `tibble` Summary table. Created from
  [`generate_year_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_year_data.md).

- spatial_scale:

  Spatial scale. Valid arguments are: `"ctry", "prov", "dist`.

- pending:

  `logical` Should cases classified as `PENDING` or `LAB PENDING` be
  included in calculations? Default `TRUE`.

## Value

`tibble` A summary table including NPAFP rates and population data.
