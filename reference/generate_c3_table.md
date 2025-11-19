# Environmental surveillance KPIs by site

**\[experimental\]**

Environmental surveillance KPIs summarized by site.

## Usage

``` r
generate_c3_table(
  es_data,
  start_date,
  end_date,
  risk_category = NULL,
  lab_locs = NULL,
  risk_table = NULL
)
```

## Arguments

- es_data:

  `tibble` Environmental surveillance data.

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

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

`tibble` A summary table of environmental surveillance KPIs.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
c3 <- generate_c3_table(raw_data$es, "2021-01-01", "2023-12-31")
} # }
```
