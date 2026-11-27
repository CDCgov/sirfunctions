# Analyze country-prioritization immunity and virus data

Applies the legacy country-prioritization calculations to the prepared
inputs. This includes immunity complements, six- and twelve-month WPV
and cVDPV counts, and the 200-km virus-proximity flag and detail field.

## Usage

``` r
analyze_GSAP_ctry_prioritization_data(
  prepared_data,
  end_date = NULL,
  positive_end_date = Sys.Date()
)
```

## Arguments

- prepared_data:

  Output of
  [`prepare_GSAP_ctry_prioritization_data()`](https://cdcgov.github.io/sirfunctions/reference/prepare_GSAP_ctry_prioritization_data.md).

- end_date:

  Optional analysis end date. Defaults to the date stored in
  `prepared_data`.

- positive_end_date:

  Date used as the end of the six- and twelve-month positive-detection
  and proximity windows. Defaults to
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

## Value

`prepared_data` with `immunity_indicators`, `positive_indicators`,
`proximity_indicators`, and `country_indicators` added.
