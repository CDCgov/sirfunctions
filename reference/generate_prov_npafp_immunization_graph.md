# Immunization status of NPAFP cases in one prov

Pending and lab-pending cases may be included to match the national
graph.

## Usage

``` r
generate_prov_npafp_immunization_graph(
  ctry.data,
  prov_name,
  start_date,
  end_date,
  include_pending = TRUE,
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

- include_pending:

  Include pending and lab-pending cases. Defaults to `TRUE`, matching
  [`generate_case_num_dose_g()`](https://cdcgov.github.io/sirfunctions/reference/generate_case_num_dose_g.md).

- output_path:

  Optional directory in which to save the PNG. `NULL` does not write a
  file.

## Value

A ggplot object.
