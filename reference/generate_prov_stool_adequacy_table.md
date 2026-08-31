# PROV stool adequacy issues table

PROV stool adequacy issues table

## Usage

``` r
generate_prov_stool_adequacy_table(
  ctry.data,
  pstool,
  prov_name,
  start_date,
  end_date
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- pstool:

  Province output from
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

- prov_name:

  PROV name.

- start_date, end_date:

  Analysis dates.

## Value

A flextable.
