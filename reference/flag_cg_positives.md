# Flag positives data from identified consequential geographies

Obtains positive detections and determines whether they are part of the
consequential geographies or not. If they are, then they are flagged in
the column `in_cg` as `TRUE`.

## Usage

``` r
flag_cg_positives(cg_super_regions, pos, start_year = 2016)
```

## Arguments

- cg_super_regions:

  `sf` Spatial object of all CG super regions and a flag for all their
  specific GUIDs. This is the output of
  [`create_cg_super_regions()`](https://cdcgov.github.io/sirfunctions/reference/create_cg_super_regions.md).

- pos:

  `tibble` The positives file from the output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- start_year:

  `int` The the earliest year for analysis. Defaults to 2016.

## Value

`sf` All CG related positives flagged and ready for mapping with a point
geography.

## Examples

``` r
if (FALSE) { # \dontrun{
polio_data <- get_all_polio_data()
cg <- sirfunctions_io("read", file_loc = "Data/misc/consequential_geographies.rds")
super_regions <- create_cg_super_regions(cg,
ctry = polio_data$global.ctry, prov = polio_data$global.prov, dist = polio_data$global.dist)
cg_positives <- flag_cg_positives(cg_super_regions, polio_data$pos)
} # }
```
