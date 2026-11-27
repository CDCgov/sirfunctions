# Generate a country prioritization workbook

Calculate the GPSAP country-prioritization indicators and weighted
scores using the package KPI calculations for AFP, ES, and detection
timeliness. Population-immunity data are supplied explicitly because
they are not part of the POLIS download.

## Usage

``` r
generate_GSAP_ctry_prioritization(
  raw_data,
  start_date,
  end_date,
  immunity_data,
  risk_table = NULL,
  lab_locs = NULL,
  regional_classification = NULL,
  proposed_category = NULL,
  ctry_sf = NULL,
  category_breaks = NULL,
  min_surv_ind = 4,
  include_all_countries = FALSE,
  output_path = NULL,
  positive_end_date = Sys.Date(),
  lab_data = NULL
)
```

## Arguments

- raw_data:

  `list` Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md).
  The data must be supplied by the calling template; this function does
  not download or save a separate POLIS R data file.

- start_date:

  `Date` or date-like string. Start of the analysis period.

- end_date:

  `Date` or date-like string. End of the analysis period.

- immunity_data:

  `tibble` Country-level immunity data. It must contain `Country` (or
  `country`) and either `zero.dose.pct`, `under.immun.pct`, and
  `no.ipv1.pct`, or `dtp1.pct`, `dtp3.pct`, and `ipv1.pct`.

- risk_table:

  `tibble` Previous country-priority table. It must contain `Country`
  and `SG Priority Level`. Defaults to the country-risk table retrieved
  from EDAV using `CTRY_RISK_CAT`.

- lab_locs:

  `tibble` Laboratory-location data. Defaults to the package data source
  when `NULL`.

- regional_classification:

  `tibble` Optional table with `Country` and a column named
  `Regional classification`.

- proposed_category:

  `tibble` Optional table with `Country` and either
  `Proposed GPSAP 2025-26 prioritization` or `SG Priority Level`.

- ctry_sf:

  `sf` Optional country spatial data used for proximity to virus
  detections. If omitted, `raw_data$global.ctry` is used when present.

- category_breaks:

  `numeric` Optional named thresholds for assigning a proposed category
  from the total score. Names must include `HIGH`, `MEDIUM`, and
  `LOW (WATCHLIST)`.

- min_surv_ind:

  `integer` Minimum number of available surveillance indicators required
  for a complete score. Defaults to `4`.

- include_all_countries:

  `logical` Retain every country present in the AFP data, even when it
  has fewer than `min_surv_ind` indicators. Such countries receive
  `insufficient data` for the affected scores. Defaults to `FALSE`.

- output_path:

  `str` Optional path for an Excel output. If `NULL`, no file is
  written.

- positive_end_date:

  `Date` Date used as the end of the six- and twelve-month
  positive-detection and proximity windows. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

- lab_data:

  `tibble` Optional cleaned laboratory data containing
  `DateStoolReceivedinLab`. When supplied, this date is used for the C2
  onset-to-laboratory timeliness indicator.

## Value

A list with `results`, `analysis_notes`, and `output_path`.
