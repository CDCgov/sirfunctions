# Download province geographic data

Pulls province shapefiles directly from the geodatabase

## Usage

``` r
load_clean_prov_sp(
  azcontainer = suppressMessages(get_azure_storage_connection()),
  fp = "GID/PEB/SIR/Data/spatial/global.prov.rds",
  prov_guid = NULL,
  prov_name = NULL,
  ctry_name = NULL,
  end_year = lubridate::year(Sys.Date()),
  st_year = 2000,
  data_only = FALSE,
  type = NULL,
  version = "standard",
  edav = TRUE,
  end.year = lifecycle::deprecated(),
  st.year = lifecycle::deprecated(),
  data.only = lifecycle::deprecated()
)
```

## Arguments

- azcontainer:

  Azure validated container object

- fp:

  `str` Location of geodatabase.

- prov_guid:

  `str array` Array of all province GUIDS that you want to pull.

- prov_name:

  `str array` Array of all province names that you want to pull.

- ctry_name:

  `str array` Array of all country names that you want to pull.

- end_year:

  `int` Last year you want to pull information for. Default is current
  year.

- st_year:

  `int` Earlier year of spatial data you want to pull. Default is 2000.

- data_only:

  `logical` Whether to return a tibble with shapefiles or not. Defaults
  to `FALSE`.

- type:

  `str` Whether to return a spatial object for every year group.
  Defaults to `NULL`.

  - `"long"` Return a dataset for every year group.

  - `NULL` Return a dataset only with unique GUIDs and when they were
    active.

- version:

  `str` Specify whether to return standard shapefiles or new shapefiles
  still under evaluation/development. Default is `"standard"`.

  - `"standard"` Standard shapefiles.

  - `"dev"` New shapefiles still under evaluation/development.

- edav:

  `logical` Load from EDAV? Defaults to `TRUE`.

- end.year:

  `int` **\[deprecated\]** Renamed in favor of `end_year`.

- st.year:

  `int` **\[deprecated\]** Renamed in favor of `st_year`.

- data.only:

  `logical` **\[deprecated\]** Renamed in favor of `data_only`.

## Value

`tibble` or `sf` Dataframe containing spatial data.

## Examples

``` r
if (FALSE) { # \dontrun{
prov <- load_clean_prov_sp(ctry_name = c("ALGERIA", "NIGERIA"), st_year = 2019)
prov.long <- load_clean_prov_sp(ctry_name = "ALGERIA", st_year = 2019, type = "long")
} # }
```
