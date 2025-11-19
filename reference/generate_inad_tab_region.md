# Generate a stool adequacy summary at the regional level

Generates a summary table at the country level highlighting issues
around stool adequacy.

## Usage

``` r
generate_inad_tab_region(afp_data, cstool, start_date, end_date)
```

## Arguments

- afp_data:

  `tibble` `afp.all.2` of the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- cstool:

  `tibble` Stool adequacy at the country level. This is the output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

## Value

`flextable` A summary of yearly stool adequacy at the regional level.

## Examples

``` r
if (FALSE) { # \dontrun{
inad_region <- generate_inad_tab_region(ctry_data$afp.all.2, cstool)
} # }
```
