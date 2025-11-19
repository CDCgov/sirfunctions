# Extract vaccine coverage information from IHME estimates

Function to extract IHME vaccine coverage data to existing spatial
files. Key spatial data can be found
[here](https://www.healthdata.org/research-analysis/health-topics/vaccine-coverage-data).

Please keep in mind that these sources may change. Reach out to IHME
directly for further information. Enter your email to gain access to the
data folder. Inside the data folder go to `Geospatial Vaccine Coverage`
\> `04_Rasters`. Download the following geotifs and place them into a
single folder in your local machine:

- `bcg1_cov_mean_raked_2000_<current year>.tif`

- `dpt1_cov_mean_raked_2000_<current year>.tif`

- `dpt3_cov_mean_raked_2000_<current year>.tif`

- `mcv1_cov_mean_raked_2000_<current year>.tif`

- `polio3_cov_mean_raked_2000_<current year>.tif`

**NOTE:** `<current year>` will change as the vaccine coverage data gets
updated.

## Usage

``` r
update_vacc_cov_data(
  tif_folder,
  ctry = load_clean_ctry_sp(),
  prov = load_clean_prov_sp(),
  dist = load_clean_dist_sp(),
  output_folder = "GID/PEB/SIR/Data/coverage",
  edav = TRUE,
  output_format = ".rds"
)
```

## Arguments

- tif_folder:

  `str` Absolute folder path to the folder containing all .TIFs of
  interest.

- ctry:

  `sf` Output of
  [`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md).

- prov:

  `sf` Output of
  [`load_clean_prov_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_prov_sp.md).

- dist:

  `sf` Output of
  [`load_clean_dist_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_dist_sp.md).

- output_folder:

  `str` Absolute folder path location to save country, province and
  district coverage data. Outputs in RDS by default, but also supports
  `.qs2` format.

- edav:

  `logical` `TRUE` or `FALSE` depending on if final save location is in
  Azure. Defaults to `TRUE`.

- output_format:

  `str` '.rds' or '.qs2'.

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry_sf <- load_clean_ctry_sp()
prov_sf <- load_clean_prov_sp()
dist_sf <- load_clean_dist_sp()
update_vacc_cov_data(
  "C:/Users/abc1/Desktop/tif_folder",
  ctry_sf, prov_sf, dist_sf,
  FALSE, "C:/Users/abc1/Desktop/tif_folder"
)
} # }
```
