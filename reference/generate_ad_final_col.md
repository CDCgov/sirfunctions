# Helper function to add the `adequacy.final` column

The function is meant to be used for
[`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).
This function will classify the adequacy of a stool sample based on
timeliness and condition.

## Usage

``` r
generate_ad_final_col(afp.data)
```

## Arguments

- afp.data:

  `tibble` AFP dataset. Either `raw.data$afp` from
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  or `ctry.data$afp.all.2` from
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

## Value

`tibble` AFP dataset with `adequacy.final` column

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
stool.data <- generate_ad_final_col(raw.data$afp)
} # }
```
