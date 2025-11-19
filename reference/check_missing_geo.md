# Checks for missing geographic data

checks the AFP dataset for rows with missing geographic data. It checks
for missing data based on the scale passed through spatial.scale.

## Usage

``` r
check_missing_geo(afp.data, spatial.scale)
```

## Arguments

- afp.data:

  tibble containing AFP data

- spatial.scale:

  what geographic level to check for. Valid values are "ctry","prov",
  "dist".

## Value

tibble containing records with missing geographic data
