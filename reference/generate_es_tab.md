# ES surveillance sites summary table

Generates a summary table on the performance of surveillance sites over
a rolling basis as indicated by the start and end dates. Includes
information on the EV detection rate, number of samples collected,
percentage of samples with good condition, and percentage of samples
meeting the timeliness target of arriving to lab within 3 days.

## Usage

``` r
generate_es_tab(
  es.data,
  es_start_date = (lubridate::as_date(es_end_date) - lubridate::years(1)),
  es_end_date = end_date
)
```

## Arguments

- es.data:

  `tibble` ES data. This is `ctry.data$es`, which is part of the output
  of either
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).
  Ensure that the `ctry.data` object has been cleaned with
  [`clean_ctry_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_ctry_data.md)
  first. Otherwise, there will be an error.

- es_start_date:

  `str` Start date of analysis. Defaults to a year before the end date.

- es_end_date:

  `str` End date of analysis.

## Value

`flextable` Summary table of ES surveillance site performance.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.data <- clean_ctry_data(ctry.data)
generate_es_tab(ctry.data$es, es_end_date = "2023-12-31")
} # }
```
