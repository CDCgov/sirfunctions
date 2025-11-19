# Generate KPI Stool adequacy bar chart summary

**\[experimental\]**

Generates a bar chart highlighting percentage of priority countries
achieving stool adequacy targets.

## Usage

``` r
generate_kpi_stoolad_bar(c1, afp_data, output_path = Sys.getenv("KPI_FIGURES"))
```

## Arguments

- c1:

  `tibble` Output of
  [`generate_c1_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c1_table.md).

- afp_data:

  `tibble` AFP dataset. List item of the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- output_path:

  `str` Folder location to output the image to.

## Value

`ggplot2` A barplot.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c1 <- generate_c1_table(raw_data, "2021-01-01", "2023-12-31", rolling = TRUE)
plot <- generate_kpi_stoolad_bar(c1, raw_data$afp)
} # }
```
