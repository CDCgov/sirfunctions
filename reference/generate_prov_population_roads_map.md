# PROV DIST under-15 population, roads, and labels map

This is the prov-level counterpart of
[`generate_pop_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_pop_map.md)
and
[`generate_dist_pop_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_dist_pop_map.md).
Existing DIST under-15 population estimates are joined to DIST geometry;
missing population is displayed rather than imputed.

## Usage

``` r
generate_prov_population_roads_map(
  ctry.data,
  prov_name,
  prov.shape,
  dist.shape,
  end_date,
  output_path = NULL,
  include_cities = FALSE,
  label_size = 3,
  repel_labels = TRUE,
  road_color = "#2166AC",
  road_linewidth = 0.7,
  dist_line_color = "grey55",
  dist_linewidth = 0.25,
  caption_size = 9
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- prov_name:

  PROV name.

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- end_date:

  Date determining the map and population year.

- output_path:

  Optional directory for the PNG file. `NULL` does not save.

- include_cities:

  Whether to add available population-centre points.

- label_size:

  DIST label size.

- repel_labels:

  Whether to repel DIST labels and draw leader lines.

- road_color, road_linewidth:

  Road color and line width.

- dist_line_color, dist_linewidth:

  DIST boundary color and line width.

- caption_size:

  Caption text size.

## Value

A ggplot object.
