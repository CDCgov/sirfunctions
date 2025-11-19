# Pull the main map data to build the map

This function primarily pulls the relevant information to build the map.
Inherits areguments from
[`generate_adhoc_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_adhoc_map.md).

## Usage

``` r
pull_map_data(
  raw.data,
  .vdpv,
  country,
  surv,
  virus_type,
  .start_date,
  .end_date
)
```

## Arguments

- raw.data:

  `list` global polio data output from
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)

- .vdpv:

  `logical` Whether to include VDPV in maps.

- country:

  `str` or `list` Name of the country or countries.

- surv:

  `str` or `list` Surveillance type.

- virus_type:

  `str` or `list` Virus type to map.

- .start_date:

  `date` Start date.

- .end_date:

  `date` End date.

## Value

`tibble` Filtered dataset used to build the map.
