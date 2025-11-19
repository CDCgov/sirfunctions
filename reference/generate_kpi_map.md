# Generate KPI maps

**\[experimental\]**

Generalized function to build KPI maps.

## Usage

``` r
generate_kpi_map(
  c2,
  who_region,
  indicator,
  .year_label,
  risk_category,
  color_scheme,
  legend_title,
  .ctry_sf,
  .dist_sf
)
```

## Arguments

- c2:

  `tibble` Output of
  [`generate_c2_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c2_table.md).

- who_region:

  `str` A WHO region or a list of regions. Valid values are:

  - `"AFRO"`: African Region

  - `"AMRO"`: Region of the Americas

  - `"EMRO"`: Eastern Mediterranean Region

  - `"EURO"`: European Region

  - `"SEARO"`:South-East Asia Region

  - `"WPRO"`:Western Pacific Region

- indicator:

  `quoted var` Indicator variable.

- .year_label:

  `str` Year of the rollup.

- risk_category:

  `str` A string or a list of strings with priority categories. Valid
  values are: "LOW", "LOW (WATCHLIST)", "MEDIUM", "HIGH".

- color_scheme:

  `list` Named list with color mappings.

- legend_title:

  `str` Title of the legend.

- .ctry_sf:

  `sf` Country shapefile.

- .dist_sf:

  `sf` District shapefile.

## Value

`ggplot` A ggplot object.
