# Adjust the zoom level of the map

This is an internal function changes the zoom level of the map depending
on the user specification.

## Usage

``` r
set_zoom_level(g1, map_ref, country, m_base_ctry)
```

## Arguments

- g1:

  `ggplot` Original ggplot map.

- map_ref:

  `ggplot` Reference map.

- country:

  `str` Country or countries to zoom into.

- m_base_ctry:

  `sf` Shapefile containing base map of country.

## Value

`ggplot` Map with adjusted zoom level, if specified.
