# GPEI Strategy surveillance KPIs

**\[experimental\]**

Monitoring surveillance KPIs for Certification of Poliomyelitis
Eradication at country regional and global levels.

## Usage

``` r
generate_c1_table(
  raw_data,
  start_date,
  end_date,
  risk_category = NULL,
  risk_table = NULL,
  lab_locs = NULL
)
```

## Arguments

- raw_data:

  `list` Global polio surveillance dataset. Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- start_date:

  `str` Start date of the analysis in YYYY-MM-DD format.

- end_date:

  `str` End date of the analysis in YYYY-MM-DD format.

- risk_category:

  `str` Risk category or a list of categories. Defaults to `NULL`. Valid
  values are: `"LOW, LOW (WATCHLIST), MEDIUM, HIGH`.

- risk_table:

  `tibble` Priority level of each country. Defaults to `NULL`, which
  will download the information directly from EDAV.

- lab_locs:

  `tibble` Summary of the sequencing capacities of labs. Output of
  [`get_lab_locs()`](https://cdcgov.github.io/sirfunctions/reference/get_lab_locs.md).
  Defaults to `NULL`, which will download the information directly from
  EDAV. .

## Value

`tibble` Summary table of GPSAP KPIs.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
c1 <- generate_c1_table(raw_data, "2021-01-01", "2023-12-31")
} # }
```
