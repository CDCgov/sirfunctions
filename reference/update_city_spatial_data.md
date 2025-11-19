# Update City Spatial data

Function to download latest city data for mapping purposes.

## Usage

``` r
update_city_spatial_data(
  edav,
  output_path = "GID/PEB/SIR/Data/spatial/cities.new.rds"
)
```

## Arguments

- edav:

  `logical` `TRUE` or `FALSE` depending on if final save location is in
  Azure.

- output_path:

  `str` Absolute file path location to save city spatial data. Outputs
  in RDS by default, but also supports `.qs2` format.

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
update_city_spatial_data(edav = TRUE)
} # }
```
