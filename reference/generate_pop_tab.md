# Summary table of indicators at the province level

Generates a table summarizing both NPAFP and stool adequacy rates at the
province level and by year.

## Usage

``` r
generate_pop_tab(
  pnpafp,
  pstool,
  start_date,
  end_date,
  prov.case.ind = lifecycle::deprecated()
)
```

## Arguments

- pnpafp:

  `tibble` NPAFP table. Output of
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
  at the province level.

- pstool:

  `tibble` Stool adequacy at province level. Output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  at the province level.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- prov.case.ind:

  `tibble` **\[deprecated\]** Deprecated in favor of the more
  informative pnpafp param name.

## Value

`flextable` Summary table of province NPAFP and stool adequacy rates per
year.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
start_date <- "2021-01-01"
end_date <- "2023-12-31"
prov.extract <- f.npafp.rate.01(
  afp.data = ctry.data$afp.all.2,
  pop.data = ctry.data$prov.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "prov",
  pending = T,
  rolling = F,
  sp_continuity_validation = F
)
pstool <- f.stool.ad.01(
  afp.data = ctry.data$afp.all.2,
  admin.data = ctry.data$prov.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "prov",
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = F
)
generate_pop_tab(prov.extract, pstool, start_date, end_date)
} # }
```
