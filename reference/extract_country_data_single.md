# Extract country specific information from raw polio data

Filters country specific data from the CDC generated `raw.data` object
from
[`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

## Usage

``` r
extract_country_data_single(.country, .raw.data = raw.data)
```

## Arguments

- .country:

  `str` A string or a vector of strings containing country name(s) of
  interest. Case insensitive.

- .raw.data:

  `list` Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

## Value

Named `list` with country specific datasets.
