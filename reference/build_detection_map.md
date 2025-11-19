# Build detection map

This is the key function that builds the detection map. This is
internally referred to as `g1` within
[`generate_adhoc_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_adhoc_map.md).

## Usage

``` r
build_detection_map(
  m_base_region,
  m_base_prov,
  data_p,
  m_data_prov,
  new_detect,
  virus_type,
  surv_options,
  start_date,
  date_3a,
  download_date,
  emg_cols,
  country,
  labels,
  clean_maps,
  data_r,
  .owner
)
```

## Arguments

- m_base_region:

  `sf` Map base for region.

- m_base_prov:

  `sf` Map base for provinces.

- data_p:

  `tibble` Data for map creation.

- m_data_prov:

  `tibble` Map data for provinces.

- new_detect:

  `logical` Whether to include new detections.

- virus_type:

  `str` or `list` Virus type to display.

- surv_options:

  `str` or `list` Surveillance options.

- start_date:

  `date` Start date.

- date_3a:

  `date` ???

- download_date:

  `date` Date global polio data was downloaded.

- emg_cols:

  `list` Emergence colors.

- country:

  `str` Country or countries of interest.

- labels:

  `logical` Whether to label provinces.

- clean_maps:

  `ggplot` Clean maps.

- data_r:

  `tibble` Reported detections.

- .owner:

  `str` Entity that produced the map.

## Value

`ggplot` Map of recent detections.
