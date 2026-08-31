# PROV-only annualized NPAFP rate map by district

PROV-only annualized NPAFP rate map by district

## Usage

``` r
generate_prov_npafp_map(
  dist.extract,
  prov_name,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  output_path = NULL,
  caption_size = 3
)
```

## Arguments

- dist.extract:

  District output from
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md).

- prov_name:

  PROV name.

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- start_date, end_date:

  Analysis dates.

- output_path:

  Optional output directory.

- caption_size:

  Caption text size.

## Value

A ggplot object.
