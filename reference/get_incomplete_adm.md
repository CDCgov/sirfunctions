# Helper function to filter GUIDs that are not consistent across temporal scale

Helper function to filter GUIDs that are not consistent across temporal
scale

## Usage

``` r
get_incomplete_adm(admin_data, spatial_scale, start_date, end_date)
```

## Arguments

- admin_data:

  population dataset

- spatial_scale:

  "ctry", "prov", or "dist"

- start_date:

  start date

- end_date:

  end date

## Value

a list of GUIDs not present in the time period
