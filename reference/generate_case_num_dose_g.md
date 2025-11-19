# Immunization rates per year

Generates a stacked percent bar plot displaying immunization rates per
year for the country. Note that this function only graphs immunization
rates for children aged 6-59 months that have the classification of
NPAFP.

## Usage

``` r
generate_case_num_dose_g(
  ctry.data,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- ctry.data:

  `list` A large list containing polio data of country. This is the
  output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).
  Note that `ctry_data` needs to be cleaned via
  [`clean_ctry_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_ctry_data.md)
  prior to running the function.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path of where to save the figure to.

## Value

`ggplot` A percent bar plot displaying immunization rates per year by
immunization status.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.data <- clean_ctry_data(ctry.data)
generate_case_num_dose_g(ctry.data, "2021-01-01", "2023-12-31")
} # }
```
