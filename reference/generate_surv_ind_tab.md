# Surveillance indicator table

Generates the surveillance indicator table for each year. Outputs the
number of AFP cases, national NPAFP rate and stool adequacy,percentage
of population living in districts with greater than or equal to 100,000
U15 meeting both indicators.

## Usage

``` r
generate_surv_ind_tab(
  ctry.data,
  ctry.extract,
  dist.extract,
  cstool,
  dstool,
  afp.case,
  country_name = Sys.getenv("DR_COUNTRY")
)
```

## Arguments

- ctry.data:

  `list` Large list containing polio data of a country.

- ctry.extract:

  `tibble` Country NPAFP rate. Output of
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
  calculated at the country level.

- dist.extract:

  `tibble` District NPAFP rate. Output of
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
  calculated at the district level.

- cstool:

  `tibble` Country stool adequacy. Output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  calculated at the country level.

- dstool:

  `tibble` District stool adequacy. Output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  calculated at the district level.

- afp.case:

  `tibble` AFP case counts. Output of
  [`generate_afp_by_month_summary()`](https://cdcgov.github.io/sirfunctions/reference/generate_afp_by_month_summary.md)
  with `by="year"`.

- country_name:

  `str` Name of the country.

## Value

`flextable` Table summarizing yearly trends in NPAFP and stool adequacy
at the national level.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.extract <- f.npafp.rate.01(
  afp.data = ctry.data$afp.all.2,
  pop.data = ctry.data$ctry.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "ctry",
  pending = T,
  rolling = F,
  sp_continuity_validation = F
)
dist.extract <- f.npafp.rate.01(
  afp.data = ctry.data$afp.all.2,
  pop.data = ctry.data$ctry.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "dist",
  pending = T,
  rolling = F,
  sp_continuity_validation = F
)
cstool <- f.stool.ad.01(
  afp.data = ctry.data$afp.all.2,
  admin.data = ctry.data$ctry.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "ctry",
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = F
)
dstool <- f.stool.ad.01(
  afp.data = ctry.data$afp.all.2,
  admin.data = ctry.data$dist.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "dist",
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = F
)
afp.by.month <- generate_afp_by_month(ctry.data$afp.all.2, "2021-01-01", "2023-12-31")
afp.case <- generate_afp_by_month_summary(afp.by.month, ctry.data, start_date, end_date, "year")
generate_surv_ind_tab(ctry.data, ctry.extract, dist.extract, cstool, dstool, afp.case)
} # }
```
