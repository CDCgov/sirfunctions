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

  `logical` Whether to use EDAV to load the raw_data and lab_data files.
  Defaults to `TRUE`.

## Value

Does not return anything

## Examples

``` r
if (FALSE) { # \dontrun{
init_kpi(name = "kpi_jan_2024")
} # }
```
