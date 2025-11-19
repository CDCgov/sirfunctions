# Force load data from the local cache

In certain instances, it may be desirable to load the global polio data
directly from the local cache. For example, if connection from EDAV
fails or if there are internet connection issues.

## Usage

``` r
force_load_polio_data_cache(attach.spatial.data, output_format = ".rds")
```

## Arguments

- attach.spatial.data:

  `logical` Should spatial data be attached?

- output_format:

  `str` Output format of the file to load to R.

## Value

`list` List containing information pertinent to the global polio
dataset.

## Examples

``` r
if (FALSE) { # \dontrun{
force_load_polio_data_cache(attach.spatial.data = TRUE)
} # }
```
