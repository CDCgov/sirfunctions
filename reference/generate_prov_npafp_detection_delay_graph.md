# Delayed detection of NPAFP cases in one prov

Each bar is the proportion of all NPAFP cases with a nonmissing
onset-to- second-stool interval in that year. The two requested
late-detection groups are shown; cases collected within 14 days remain
in the denominator.

## Usage

``` r
generate_prov_npafp_detection_delay_graph(
  ctry.data,
  prov_name,
  start_date,
  end_date,
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

- output_path:

  Optional directory in which to save the PNG. `NULL` does not write a
  file.

## Value

A ggplot object.
