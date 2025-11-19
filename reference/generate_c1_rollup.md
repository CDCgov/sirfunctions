# Generate C1 rollup for high-priority countries

**\[experimental\]**

Generates a summary of how many of the high priority countries have met
their AFP and ES indicators.

## Usage

``` r
generate_c1_rollup(
  c1,
  priority_level = "HIGH",
  who_region = NULL,
  .group_by = "rolling_period",
  npafp_target = 80,
  stool_target = 80,
  ev_target = 80,
  timely_wpv_vdpv_target = 80
)
```

## Arguments

- c1:

  `tibble` The output of
  [`generate_c1_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c1_table.md).

- priority_level:

  `str or list` Priority level. Defaults to `"HIGH"`. Valid values are
  `"LOW", "LOW (WATCHLIST)", "MEDIUM", "HIGH"`

- who_region:

  `str` WHO region to summarize the data to.

- .group_by:

  `str` How the rollup should be grouped. Defaults to the column
  `"rolling_period"`.

- npafp_target:

  `num` Target used when calculating the proportion of districts in a
  country that meets NPAFP rate.

- stool_target:

  `num` Target used when calculating the proportion of districts in a
  country that meets stool adequacy rate.

- ev_target:

  `num` Target used when calculating the proportion of ES sites in a
  country that meets EV detection rate.

- timely_wpv_vdpv_target:

  `num` Target used when calculating the proportion of ES sites in a
  country that meets timeliness of detection of WPV and VDPV cases.

## Value

`tibble` A summary rollup

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c1 <- generate_c1_table(raw_data, "2022-01-01", "2024-12-31")
c1_rollup <- generate_c1_rollup(c1)
} # }
```
