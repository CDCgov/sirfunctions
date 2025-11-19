# Clear local polio data cache

The local polio cache is created when
[`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
is called with `local_caching = TRUE`. The function clears the cache by
deleting all the files within it.

## Usage

``` r
clear_local_polio_data_cache()
```

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
clear_local_polio_data_cache()
} # }
```
