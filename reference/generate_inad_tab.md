# Issues with stool adequacy at the country level

Generates a summary table at the country level highlighting issues
around stool adequacy.

## Usage

``` r
generate_inad_tab(afp_data, cstool, start_date, end_date)
```

## Arguments

- afp_data:

  `tibble` `afp.all.2` of the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- cstool:

  `tibble` Stool adequacy at the country level. This is the output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

## Value

`flextable` Summary table containing stool adequacy issues at the
country level.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
start_date <- "2021-01-01"
end_date <- "2023-12-31"
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
generate_inad_tab(ctry.data, cstool, start_date, end_date)
} # }
```
