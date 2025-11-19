# Get a long version of shapefile at a given spatial scale

**\[deprecated\]**

This function was used primarily as a way to build maps in the desk
review. However, the map generation functions in the desk review will
now use the long formatted shapefile as of `sirfunctions v1.2`. This
function will be changed in the next version.

[`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md),
[`load_clean_prov_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_prov_sp.md),
[`load_clean_dist_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_dist_sp.md)
with `type = long` are the longform shapefiles.

## Usage

``` r
set_shapefiles(ctry.data, spatial.scale)
```

## Arguments

- ctry.data:

  `list` List containing country data. Either the result of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- spatial.scale:

  `str` Either `"ctry", "prov", "dist"`.

## Value

`sf` Data frame including the most recent shapefile.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
ctry.shape <- set_shapefiles(ctry.data, "ctry")

# Using init_dr()
ctry.data <- init_dr("algeria")
ctry.shape <- set_shapefiles(ctry.data, "ctry")
} # }
```
