# Visits to health clinics per year

Generates a bar plot showing the number of visits to health clinics per
year using the ISS/eSURV data.

## Usage

``` r
generate_iss_barplot(
  iss.data = NULL,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- iss.data:

  `tibble` ISS/eSURV data that has been cleaned via
  [`clean_iss_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_iss_data.md).

- start_date:

  `str` Start date of the analysis.

- end_date:

  `str` End date of the analysis.

- output_path:

  `str` Local path where the figure is saved to.

## Value

`ggplot` Bar plot of health clinic visits.

## Examples

``` r
if (FALSE) { # \dontrun{
iss_path <- "C:/Users/ABC1/Desktop/iss_data.csv"
ctry.data <- init_dr("algeria", iss_data_path = iss_path)
ctry.data$iss.data <- clean_iss_data(ctry.data)
generate_iss_barplot(ctry.data$iss.data)
} # }
```
