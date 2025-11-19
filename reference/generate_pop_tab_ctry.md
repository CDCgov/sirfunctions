# Country-Level Population Surveillance Table (wide, multi-year)

Builds a formatted table of country-level surveillance indicators across
a span of years. It aggregates inputs to the **country–year** level,
computes year-over-year differences in NP-AFP case counts, pivots to a
wide layout (one row per country; columns per year), and applies
target-based highlighting for **NPAFP rate \< 2** and **stool adequacy
\< 80%**.

## Usage

``` r
generate_pop_tab_ctry(cnpafp, cstool, start_date, end_date)
```

## Arguments

- cnpafp:

  `tibble` Output of
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
  at the country level.

- cstool:

  `tibble` Output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  at the country level.

- start_date, end_date:

  Dates (any format coercible by
  [`lubridate::as_date()`](https://lubridate.tidyverse.org/reference/as_date.html))
  defining the inclusive year range to display. All years between
  `year(start_date)` and `year(end_date)` are included.

## Value

A `flextable` object suitable for viewing in the RStudio Viewer (e.g.,
with
[`flextable::save_as_html()`](https://davidgohel.github.io/flextable/reference/save_as_html.html) +
[`rstudioapi::viewer()`](https://rstudio.github.io/rstudioapi/reference/viewer.html)),
or exporting to Word/PowerPoint/HTML via `flextable`.

## Examples

``` r
if (FALSE) { # \dontrun{
tab <- generate_pop_tab_ctry(
  cnpafp  = ctry.extract,  # your country NP-AFP dataset
  cstool  = cstool,        # your country stool adequacy dataset
  start_date = "2021-01-01",
  end_date   = "2024-12-31"
)
} # }
```
