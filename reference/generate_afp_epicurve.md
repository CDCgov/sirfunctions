# Epicurve of AFP cases by year

Generates an epicurve line graph of AFP cases by year.

## Usage

``` r
generate_afp_epicurve(
  ctry.data,
  start_date,
  end_date = lubridate::today(),
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- ctry.data:

  `list` Large list containing country polio data. This is the output of
  either
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis. By default, it is up to the current date.

- output_path:

  `str` Local path location to save the figure.

## Value

`ggplot` A line graph of AFP cases faceted by year.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
generate_afp_epicurve(ctry.data, start_date)
} # }
```
