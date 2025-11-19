# Checks the cache file and see if it should load parameters from it

Checks the cache file and see if it should load parameters from it

## Usage

``` r
check_cache(
  param_path,
  start_date,
  end_date,
  country_name = Sys.getenv("DR_COUNTRY")
)
```

## Arguments

- param_path:

  path to parameters.RData

- start_date:

  start date of the desk review

- end_date:

  end date of the desk review

- country_name:

  name of the country

## Value

boolean whether to use cache or not
