# Create a country level rollup of the C3 label

**\[experimental\]**

Create a country level summary of ES site performance with respect to
meeting established targets for EV detection rates, good samples. Note,
this country roll up will only consider sites that have at least 10
collections and open for at least 12 months, consistent with guidelines
in the 2025-2026 GPSAP indicators.

## Usage

``` r
generate_c3_rollup(
  c3,
  include_labels = TRUE,
  min_sample = 10,
  timely_wpv_vdpv_target = 80
)
```

## Arguments

- c3:

  `tibble` Output of
  [`generate_c3_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c3_table.md).

- include_labels:

  `logical` Include columns for the labels? Default TRUE.

- min_sample:

  `num` Only consider sites with at least this number of ES samples.
  Default is `10`.

- timely_wpv_vdpv_target:

  Target used when determining whether a country meets EV detection
  target.

## Value

`tibble` A summary of the c3 table at the country level

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c3 <- generate_c3_table(raw_data$es, "2021-01-01", "2023-12-31")
c3_rollup <- generate_c3_rollup(c3)
} # }
```
