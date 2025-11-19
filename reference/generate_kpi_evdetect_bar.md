# Generate KPI EV rate bar chart summary

**\[experimental\]**

Generates a bar chart highlighting percentage of priority countries
achieving 80% of ES sites meeting sensitivity threshold of at least 50%
samples positive for enterovirus. Sites included are sites with at least
10 collections in the last 12 months.

## Usage

``` r
generate_kpi_evdetect_bar(
  c1,
  afp_data,
  output_path = Sys.getenv("KPI_FIGURES"),
  who_region = NULL
)
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

- who_region:

  `str` A WHO region or a list of regions. Valid values are:

  - `"AFRO"`: African Region

  - `"AMRO"`: Region of the Americas

  - `"EMRO"`: Eastern Mediterranean Region

  - `"EURO"`: European Region

  - `"SEARO"`:South-East Asia Region

  - `"WPRO"`:Western Pacific Region

## Value

`ggplot2` A barplot.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c1 <- generate_c1_table(raw_data, "2021-01-01", "2023-12-31", rolling = TRUE)
plot <- generate_kpi_evdetect_bar(c1, raw_data$afp)
} # }
```
