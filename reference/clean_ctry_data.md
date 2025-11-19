# Cleans and adds additional age and dosage number columns to the AFP linelist

The function does additional cleaning of the `ctry.data` list. It fills
in missing districts, convert character date columns to a date data
type, calculates age group, add columns for the number of doses per
case, and cleans the environmental surveillance data.

## Usage

``` r
clean_ctry_data(ctry.data)
```

## Arguments

- ctry.data:

  `list` Large list containing polio country data. This is the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

## Value

`list` Cleaned country data list.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.data <- clean_ctry_data(ctry.data)
} # }
```
