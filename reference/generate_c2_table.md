# AFP surveillance KPI summary

**\[experimental\]**

This function creates a summary table of AFP surveillance KPIs.

## Usage

``` r
generate_c2_table(
  afp_data,
  pop_data,
  start_date,
  end_date,
  spatial_scale,
  risk_category = NULL,
  lab_locs = NULL,
  risk_table = NULL
)
```

## Arguments

- afp_data:

  `tibble` AFP linelist data.

- pop_data:

  `tibble` Population data.

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

- spatial_scale:

  `str` Either `"ctry", "prov", "dist"`.

- risk_category:

  `str` Risk category or a list of categories. Defaults to `NULL`. Valid
  values are: `"LOW, LOW (WATCHLIST), MEDIUM, HIGH`.

- lab_locs:

  `tibble` Summary of the sequencing capacities of labs. Output of
  [`get_lab_locs()`](https://cdcgov.github.io/sirfunctions/reference/get_lab_locs.md).
  Defaults to `NULL`, which will download the information directly from
  EDAV. .

- risk_table:

  `tibble` Priority level of each country. Defaults to `NULL`, which
  will download the information directly from EDAV.

## Value

`tibble` Summary table containing AFP KPIs.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
c2 <- generate_c2_table(raw_data$afp, raw_data$ctry.pop, "2021-01-01", "2023-12-31", "ctry")
} # }
```
