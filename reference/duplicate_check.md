# Assess duplicates in the get_all_polio_data() output

Checks for duplicate records in AFP, other, SIA, and Virus datasets.

## Usage

``` r
duplicate_check(.raw.data = raw.data)
```

## Arguments

- .raw.data:

  Named `list` output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
raw.data <- duplicate_check(raw.data)
} # }
```
