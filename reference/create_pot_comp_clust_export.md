# Export potentially compatible and compatible summary table

Exports the output of
[`generate_potentially_compatibles_cluster()`](https://cdcgov.github.io/sirfunctions/reference/generate_potentially_compatibles_cluster.md)
as an Excel file.

## Usage

``` r
create_pot_comp_clust_export(
  pot.c.clust,
  country = Sys.getenv("DR_COUNTRY"),
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- pot.c.clust:

  `tibble` Potentially compatible cluster summary. The output of
  [`generate_potentially_compatibles_cluster()`](https://cdcgov.github.io/sirfunctions/reference/generate_potentially_compatibles_cluster.md).

- country:

  `str` Name of the country.

- excel_output_path:

  `str` Output path of where to store the Excel file.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
stool.data <- generate_stool_data(
  ctry.data$afp.all.2, "good", "inadequate",
  "2021-01-01", "2023-12-31"
)
cases.need60day <- generate_60_day_table_data(stool.data, start_date, end_date)
pot.c.clust <- generate_potentially_compatibles_cluster(cases.need60day)
create_pot_comp_clust_export(pot.c.clust)
} # }
```
