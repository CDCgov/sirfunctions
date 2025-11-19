# Get vaccine preventable diseases dataset

**\[experimental\]**

Gets the VPD dataset from EDAV.

## Usage

``` r
get_vpd_data(
  vpd_name = NULL,
  variable_name = NULL,
  years = NULL,
  ctry_name = NULL,
  iso3_codes = NULL,
  add_ctry_sf = TRUE,
  add_ctry_pop = TRUE
)
```

## Arguments

- vpd_name:

  `str` A VPD or a list of VPDs. Defaults to `NULL`, which returns the
  full VPD dataset.

- variable_name:

  `str` A variable or a list of variables. Defaults to `NULL`, which
  returns a dataset containing all the variable names.

- years:

  `int` A year or a list of years. Defaults to `NULL`, which returns a
  dataset containing all the years available.

- ctry_name:

  `str` A country or a list country names. Defaults to `NULL`, which
  returns all the countries in the dataset.

- iso3_codes:

  `str` An ISO3 code or a list of ISO3 codes. Defaults to `NULL`, which
  returns all the ISO3 codes in the dataset.

- add_ctry_sf:

  `logical` Attach the country shapefile? Defaults to `TRUE`.

- add_ctry_pop:

  `logical` Attach the country population data? Defaults to `TRUE`.

## Value

`list` A list containing the VPD data, and optionally the shapefile and
population data.

## Examples

``` r
if (FALSE) { # \dontrun{
vpd_data <- get_vpd_data()
} # }
```
