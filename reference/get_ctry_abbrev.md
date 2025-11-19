# Get country abbreviations

**\[experimental\]**

Gets the country abbreviation from the AFP dataset.

## Usage

``` r
get_ctry_abbrev(afp_data)
```

## Arguments

- afp_data:

  `tibble` AFP dataset

## Value

`tibble` A tibble with the country, abbreviation, and WHO region

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry_abbrev <- get_ctry_abbrev(raw_data$afp)
} # }
```
