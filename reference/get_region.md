# Determines whether lab data is EMRO or AFRO

Outputs the name of the region which a country belongs to.

## Usage

``` r
get_region(country_name = Sys.getenv("DR_COUNTRY"))
```

## Arguments

- country_name:

  `str` Name of the country.

## Value

`str` A string, either `"EMRO"` or `"AFRO"`.

## Examples

``` r
if (FALSE) { # \dontrun{
get_region("algeria")
} # }
```
