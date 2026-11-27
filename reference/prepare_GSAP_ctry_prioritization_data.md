# Prepare country-prioritization source data

Pulls the existing sirfunctions KPI calculations needed for the first
country-prioritization stage. This function does not download POLIS
data; the caller supplies the in-memory result of
[`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).
It also keeps the positives data available for the later virus-risk step
and reads the long-format WUENIC workbook supplied outside POLIS.

## Usage

``` r
prepare_GSAP_ctry_prioritization_data(
  raw_data,
  start_date,
  end_date,
  immunity_data = NULL,
  immunity_file = NULL,
  wuenic_year = NULL,
  risk_table = NULL,
  lab_locs = NULL,
  ctry_sf = NULL,
  lab_data = NULL
)
```

## Arguments

- raw_data:

  `list` Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).

- start_date:

  `Date` or date-like string. Start of the analysis period.

- end_date:

  `Date` or date-like string. End of the analysis period.

- immunity_data:

  `tibble` Optional already-read WUENIC data.

- immunity_file:

  `str` Optional WUENIC workbook path. Used when `immunity_data` is
  `NULL`.

- wuenic_year:

  `integer` Optional WUENIC year to use when `immunity_data` is read
  from `immunity_file`. If `NULL`, the reader uses its default
  year-selection behavior.

- risk_table:

  `tibble` Optional current country-risk table. Defaults to the EDAV
  `CTRY_RISK_CAT` table.

- lab_locs:

  `tibble` Optional laboratory-location table. Defaults to the EDAV
  laboratory-location data.

- ctry_sf:

  Optional country spatial layer. Defaults to `raw_data$global.ctry`
  when present.

- lab_data:

  `tibble` Optional cleaned laboratory data containing
  `DateStoolReceivedinLab`. When supplied, this date is used for the C2
  onset-to-laboratory timeliness indicator.

## Value

A list containing the source inputs, existing KPI tables, and
`surveillance_indicators` table with the indicators needed by the later
scoring step.
