# Calculate final country-prioritization scores and output table

Applies the legacy country-prioritization scoring thresholds and weights
to the analyzed data. The result contains the final output columns used
by the country-prioritization workbook.

## Usage

``` r
calculate_GSAP_ctry_prioritization(
  analyzed_data,
  previous_risk_table = NULL,
  min_surv_ind = 4,
  include_all_countries = FALSE
)
```

## Arguments

- analyzed_data:

  Output of
  [`analyze_GSAP_ctry_prioritization_data()`](https://cdcgov.github.io/sirfunctions/reference/analyze_GSAP_ctry_prioritization_data.md).

- previous_risk_table:

  Optional table containing the previous GPSAP country categories.
  Defaults to the risk table carried in `analyzed_data`.

- min_surv_ind:

  Minimum number of the seven surveillance indicators required for a
  complete score. Defaults to `4`.

- include_all_countries:

  `logical` Retain every country present in the AFP data, even when it
  has fewer than `min_surv_ind` indicators. Such countries receive
  `insufficient data` for the affected scores. Defaults to `FALSE`.

## Value

A list with `results` and `analysis_notes`.
