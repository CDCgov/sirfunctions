# Export a country-prioritization workbook

Export a country-prioritization workbook

## Usage

``` r
export_GSAP_ctry_prioritization(prioritization_output, output_path)
```

## Arguments

- prioritization_output:

  A list containing `results` and optionally `analysis_notes`, as
  returned by
  [`generate_GSAP_ctry_prioritization()`](https://cdcgov.github.io/sirfunctions/reference/generate_GSAP_ctry_prioritization.md).

- output_path:

  `str` File path for the Excel workbook.

## Value

Invisibly returns `output_path`.
