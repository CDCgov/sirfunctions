# PROV-only stool adequacy map by district

PROV-only stool adequacy map by district

## Usage

``` r
generate_prov_stool_adequacy_map(
  dstool,
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

- dstool:

  District output from
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

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
