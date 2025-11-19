# Should the local global polio dataset be recached?

The function checks the analytics folder for changes in the global polio
dataset. If there is a change between versions in EDAV and locally,
returns whether the it should be recached locally.

## Usage

``` r
recache_raw_data(analytic_folder, edav, output_format)
```

## Arguments

- analytic_folder:

  `str` Path to the analytics folder.

- edav:

  `logical` Should we use EDAV? Defaults to TRUE.

- output_format:

  `str` Output format to load.

## Value

`logical` Whether the global polio dataset should be cached.

## Details

If
[`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
is used locally, then calling the function does not really make sense
given there is already a local copy of the global polio dataset.
