# Update Roads Spatial data

Function to download latest roads data for mapping purposes

## Usage

``` r
update_road_spatial_data(
  edav,
  output_path = "GID/PEB/SIR/Data/spatial/roads.new.rds",
  resolution = 10
)
```

## Arguments

- edav:

  `logical` `TRUE` or `FALSE` depending on if final save location is in
  Azure.

- output_path:

  `str` Absolute file path location to save roads spatial data. Outputs
  in RDS by default, but also supports `.qs2` format.

- resolution:

  `int` options are 110 (low resolution), 50 (medium resolution) and 10
  (high resolution); default is 10

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
update_road_spatial_data(edav = TRUE)
} # }
```
