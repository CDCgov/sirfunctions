# Get years with missing data based on variable name and VPD

**\[experimental\]**

For each pair of VPD and variable name, returns the years with missing
data for each country.

## Usage

``` r
get_vpd_missingness(
  vpd_name = NULL,
  variable_name = NULL,
  min_year = 1980,
  max_year = lubridate::year(Sys.Date())
)
```

## Arguments

- vpd_name:

  `str` A VPD name or a list of names.

- variable_name:

  `str` A variable name or a list of names.

- min_year:

  `int` Minimum year to analyze. Defaults to `1980`.

- max_year:

  `int` Maximum year to analyze. Defaults to the current year.

## Value

`tibble` A summary table of years with missing data for each country for
a particular VPD and variable name.

## Examples

``` r
if (FALSE) { # \dontrun{
missing_years <- get_vpd_missingness("Cholera", "cases")
} # }
```
