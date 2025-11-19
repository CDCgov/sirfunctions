# Calculate EV detection rate function

Function to calculate the EV detection rate in sites from POLIS.

## Usage

``` r
f.ev.rate.01(es.data, start.date, end.date)
```

## Arguments

- es.data:

  `tibble` ES data which includes site name (site.name), country
  (ADM0_NAME), date of collection (collect.date), and a binary ev
  detection variable (ev.detect) that indicates absence/presence (0, 1)
  of enterovius in an ES sample. This is `ctry.data$es` of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md),
  or `raw.data$es` of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- start.date:

  `str` Date in the format of `"YYYY-MM-DD"`.

- end.date:

  `str` Date in the format of `"YYYY-MM-DD"`.

## Value

`tibble` Long format dataframe including site specific EV detection
rates.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
ev_rates <- f.ev.rate.01(ctry.data$es, "2021-01-01", "2023-12-31")
} # }
```
