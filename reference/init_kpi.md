# Initialize the KPI analysis pipeline

**\[experimental\]**

Sets up folder structures and environmental variables, as well as
download global polio data.

## Usage

``` r
init_kpi(path = getwd(), name = NULL, edav = TRUE)
```

## Arguments

- path:

  `str` Path to the folder containing the KPI analysis folders. Defaults
  to current working directory.

- name:

  `str` Name of the KPI analysis folder. If not given any names, the
  folder will be named the date the function is ran.

- edav:

  `logical` Whether to use EDAV to load the global polio data. Defaults
  to `TRUE`. Lab data are always loaded from EDAV.

## Value

Does not return anything

## Details

Pre-cleaned lab data are downloaded from `CLEANED_LAB_DATA` on EDAV on
every run, independently of `edav`. Previous lab caches are not used. A
local snapshot is saved in the analysis data folder. The generated
template adds rolling-year fields without calling
[`clean_lab_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_lab_data.md).

## Examples

``` r
if (FALSE) { # \dontrun{
init_kpi(name = "kpi_jan_2024")
} # }
```
