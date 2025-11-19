# Calculate non-polio AFP rate

**\[stable\]**

Calculate the NPAFP rate from POLIS data. Can either pass `raw.data` to
calculate NPAFP rates on the global dataset, or a `ctry.data` dataset.

## Usage

``` r
f.npafp.rate.01(
  afp.data,
  pop.data,
  start.date,
  end.date,
  spatial.scale,
  pending = T,
  missing_agemonths = F,
  rolling = F,
  sp_continuity_validation = T
)
```

## Arguments

- afp.data:

  `tibble` AFP data which includes GUID at a given spatial scale
  formatted as `adm(0,1,2)guid`, onset date as `date` and
  `cdc.classification.all2` which includes
  `"NPAFP", "PENDING", "LAB PENDING"`. This is either
  `ctry.data$afp.all.2` of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md)
  or `raw.data$afp` of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- pop.data:

  `tibble` Under 15 population data by a given spatial scale including
  `year`, `adm(0,1,2)guid`, `u15pop`, and `ctry/prov/dist` as
  appropriate. This is part of the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  and
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- start.date:

  `str` Start date with the format `"YYYY-MM-DD"`.

- end.date:

  `str` Start date with the format `"YYYY-MM-DD"`.

- spatial.scale:

  `str` Spatial scale for analysis.

  - `"prov"` Province level.

  - `"dist"` District level.

  - `"ctry"` Country level.

- pending:

  `logical` Should cases classified as `PENDING` or `LAB PENDING` be
  included in calculations? Default `TRUE`.

- missing_agemonths:

  `logical` Should cases with `NA` values for `age.months` be included?
  Default `FALSE`.

- rolling:

  `logical` Should the analysis be performed on a rolling bases? Default
  `FALSE`.

- sp_continuity_validation:

  `logical` Should we filter places that are not present for the
  entirety of the analysis dates? Default `TRUE`.

## Value

`tibble` A table containing NPAFP rates as well as additional
information relevant to each location analyzed.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
npafp_ctry <- f.npafp.rate.01(raw.data$afp, raw.data$ctry.pop, "2022-01-01", "2024-12-31", "ctry")
} # }
```
