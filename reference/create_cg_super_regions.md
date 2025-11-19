# Create super regions from subsets of consequential geographies

Create a shapefile containing super regions of consequential
geographies.

## Usage

``` r
create_cg_super_regions(cg, ctry, prov, dist)
```

## Arguments

- cg:

  `tibble` Table containing data about existing CGs, the dataset is
  expected to contain the following headers of the following datatypes:

  - `type`: `str` Consequential geographies must have a type of `"cg"`.
    All other can be `NA`.

  - `label`: `str` Geographic grouping (i.e., "Lake Chad"). Can be a
    country or a subset of a country (i.e., "Northern Yemen"). This
    column will be used to group the consequential geographies for
    creating super regions.

  - `ctry`: `str` Name of the country.

  - `prov`: `str` Name of the province.

  - `dist`: `str` Name of the district.

  - `adm_level`: `str` Name of the administrative level. Must be one of
    `NA` if at the country level, `"adm1"` if at the province level, and
    `"adm2` if at the district level.

- ctry:

  `sf` Country level spatial objects. Can be the `global.ctry` spatial
  object attached to the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- prov:

  `sf` Province level spatial objects. Can be the `global.prov` spatial
  object attached to the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- dist:

  `sf` District level spatial objects. Can be the `global.dist` spatial
  object attached to the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

## Value

`sf` Single spatial object with all consequential geography super
regions.

## Details

You can download an example dataset using: sirfunctions_io("read",
file_loc = "Data/misc/consequential_geographies.rds").

## Examples

``` r
if (FALSE) { # \dontrun{
polio_data <- get_all_polio_data()
cg <- sirfunctions_io("read", file_loc = "Data/misc/consequential_geographies.rds")
create_cg_super_regions(cg, ctry = polio_data$global.ctry,
prov = polio_data$global.prov, dist = polio_data$global.dist)
} # }
```
