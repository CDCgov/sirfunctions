# Generate tile plots for indicators

Generates tile plots for indicators present in c1-c4, showing changes
over multiple rolling periods.

## Usage

``` r
generate_kpi_tile(
  c_table,
  priority_category = "HIGH",
  output_path = Sys.getenv("KPI_FIGURES")
)
```

## Arguments

- c_table:

  `tibble` Either C1, C2, C3, C4

- priority_category:

  `str` A string or a list of priority category. Valid values are:
  "LOW", "LOW (WATCHLIST)", "MEDIUM", "HIGH".

- output_path:

  `str` Where to output the figure to.

## Value

`ggplot2` A tile plot for each indicator for each geography

## Details

The function automatically detects the geographic scale to present in
each plot. If passing a table that is grouped lower than the country
level, we recommend that only one country is present or a subset of
districts are presented so that the output plot is legible.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c1 <- generate_c1_table(raw_data, "2021-01-01", "2023-12-31")
generate_kpi_tile(c1)
} # }
```
