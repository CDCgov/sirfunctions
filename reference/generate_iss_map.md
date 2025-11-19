# Map of high priority health facilities

Generates a map of high priority health facilities across years based on
ISS/eSURV data.

## Usage

``` r
generate_iss_map(
  iss.data,
  ctry.shape,
  prov.shape,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- iss.data:

  `tibble` ISS/eSurv data. Ensure that the `iss.data` is part of
  `ctry.data` and has been cleaned by
  [`clean_iss_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_iss_data.md).

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path where to save the figure to.

## Value

`ggplot` Map of where the high priority health facilities are across
years.

## Examples

``` r
if (FALSE) { # \dontrun{
iss_path <- "C:/Users/ABC1/Desktop/iss_data.csv"
ctry.data <- init_dr("algeria", iss_data_path = iss_path)
ctry.data$iss.data <- clean_iss_data(ctry.data)
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_iss_map(
  ctry.data$iss.data, ctry.shape, prov.shape,
  "2021-01-01", "2023-12-31"
)
} # }
```
