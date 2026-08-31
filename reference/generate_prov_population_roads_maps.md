# Generate DIST population and roads maps for multiple prov_names

Generate DIST population and roads maps for multiple prov_names

## Usage

``` r
generate_prov_population_roads_maps(
  ctry.data,
  prov.shape,
  dist.shape,
  end_date,
  prov_names = list_desk_review_prov(ctry.data),
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

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- end_date:

  Date determining the map and population year.

- prov_names:

  Character vector of PROV names. Defaults to all PROVs found in
  `ctry.data`.

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

A named list of ggplot objects.
