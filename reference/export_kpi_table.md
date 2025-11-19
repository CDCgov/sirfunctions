# Export KPI tables

**\[experimental\]**

Performs formatting and export of the C1-C4 KPI tables.

## Usage

``` r
export_kpi_table(
  c1 = NULL,
  c2 = NULL,
  c3 = NULL,
  c4 = NULL,
  output_path = Sys.getenv("KPI_TABLES"),
  drop_label_cols = FALSE,
  sc_targets = FALSE,
  pos_data = NULL,
  risk_table = NULL
)
```

## Arguments

- c1:

  `tibble` Output of
  [`generate_c1_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c1_table.md).
  Defaults to `NULL`.

- c2:

  `tibble` Output of
  [`generate_c2_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c2_table.md).
  Defaults to `NULL`.

- c3:

  `tibble` Output of
  [`generate_c3_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c3_table.md).
  Defaults to `NULL`.

- c4:

  `tibble` Output of
  [`generate_c4_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c4_table.md).
  Defaults to `NULL`.

- output_path:

  `str` Path to output the table to. Defaults to the path initiated
  after running
  [`init_kpi()`](https://cdcgov.github.io/sirfunctions/reference/init_kpi.md).

- drop_label_cols:

  `logical` Keep or discard label columns. Defaults to `TRUE`.

- sc_targets:

  `logical` Whether to use SC targets when exporting the table. Defaults
  to FALSE.

- pos_data:

  `tibble` Positives dataset.

- risk_table:

  `tibble` The risk table. Required if using sc_targets and outside of
  CDC.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
init_kpi()
c1 <- generate_c1_table(raw_data, "2021-01-01", "2023-12-31")
c2 <- generate_c2_table(raw_data$afp, raw_data$ctry.pop, "2021-01-01", "2023-12-31", "ctry")
c3 <- generate_c3_table(raw_data$es, "2021-01-01", "2023-12-31")
c4 <- generate_c4_table(lab_data, raw_data$afp, "2021-01-01", "2024-12-31")
export_kpi_table(c1, c2, c3, c4)
} # }
```
