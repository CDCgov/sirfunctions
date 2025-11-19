# Obtain a constant variable used in sirfunctions

Some links used in certain functions are hardcoded, but may change in
the future. For ease of link maintenance, constants will be added to
this function.

## Usage

``` r
get_constant(constant_name = NULL)
```

## Arguments

- constant_name:

  `str` Name of the constant. Valid values include:

  - `"DEFAULT_EDAV_FOLDER"`

  - `"CTRY_RISK_CAT"`

  - `"LAB_LOCATIONS"`

  - `"SIRFUNCTIONS_GITHUB_TREE"`

  - `"CLEANED_LAB_DATA"`

## Value

`str` A string, typically a file path or a URL.

## Examples

``` r
get_constant("DEFAULT_EDAV_FOLDER")
#> [1] "GID/PEB/SIR"
```
