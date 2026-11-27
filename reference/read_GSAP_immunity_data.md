# Read WUENIC coverage inputs for country prioritization

Reads the long-format `country` sheet from a WUENIC workbook and returns
one country-level table. The default follows the population-immunity
analysis: filter by year and vaccine, reshape coverage to one row per
country, and calculate the DTP1, DTP3, and IPV1 complements. Country
labels are standardized here because the workbook is an external input;
other prioritization inputs are expected to already use the package
country key.

## Usage

``` r
read_GSAP_immunity_data(
  path,
  sheet = "country",
  year = NULL,
  target_grp = NULL,
  include_coverage = FALSE
)
```

## Arguments

- path:

  `str` Path to the WUENIC Excel workbook.

- sheet:

  `str` Workbook sheet containing the long-format country data.

- year:

  `integer` Optional WUENIC year. If omitted, the maximum year available
  after filtering to the requested vaccines is used. The year is
  selected before any `target_grp` filter is applied. All three
  requested vaccines must have data for that year and target group.

- target_grp:

  `str` Optional WUENIC target group. `NULL` (the default) ignores this
  field; provide a value only when an explicit target-group filter is
  needed.

- include_coverage:

  `logical` Include the source coverage columns in addition to the
  complement columns. Defaults to `FALSE`, matching the reference
  analysis.

## Value

A tibble with `Country`, `zero.dose.pct`, `under.immun.pct`, and
`no.ipv1.pct`; coverage columns are included when requested.
