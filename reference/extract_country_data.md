# Extract country specific information from raw polio data

Filters country specific data from the CDC generated `raw.data` object
from
[`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

## Usage

``` r
extract_country_data(.country, .raw.data = raw.data)
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

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data(c("nigeria", "eritrea"), raw.data)
} # }
```
