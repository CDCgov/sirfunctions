# Histogram of NPAFP case age in one prov

Histogram of NPAFP case age in one prov

## Usage

``` r
generate_prov_npafp_age_histogram(
  ctry.data,
  prov_name,
  start_date,
  end_date,
  binwidth = 1,
  output_path = NULL
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  One value from `list_desk_review_prov(ctry.data)`.

- start_date, end_date:

  Analysis dates.

- binwidth:

  Width of histogram bins in years.

- output_path:

  Optional directory in which to save the PNG. `NULL` does not write a
  file.

## Value

A ggplot object.
