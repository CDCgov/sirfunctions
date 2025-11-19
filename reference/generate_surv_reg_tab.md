# Regional Surveillance Indicators by Year (Multi-country aggregate)

Computes **region-level** time series of surveillance indicators by
aggregating across all countries present in your inputs (or implicitly
after the joins). The function:

1.  builds district-level indicators, restricts to districts with **U15
    ≥ 100,000**,

2.  derives the **% population in adequate districts** (NPAFP rate ≥ 2
    **and** stool adequacy ≥ 80%), and counts of adequate vs. total
    ≥100k districts,

3.  aggregates **country-level** indicators to the region using **simple
    means** for rates and **sums** for AFP cases, and

4.  returns either a tidy tibble or a formatted `flextable`.

## Usage

``` r
generate_surv_reg_tab(
  ctry_data,
  ctry.extract,
  dist.extract,
  cstool,
  dstool,
  afp.cases,
  start_year = NULL,
  end_year = NULL,
  output = c("flextable", "tibble")
)
```

## Arguments

- ctry_data:

  A list-like object that contains at least `dist.pop`, a data frame
  with district metadata. Must include columns:

  - `ctry` (country code/name),

  - `adm2guid` (district id), and preferably `year` and a U15 population
    column (e.g., `u15pop`).

- ctry.extract:

  Country-level dataset (one row per country-year). Should contain
  `year` and either `adm0guid` (to join with `cstool`) or `ctry`. It
  should include `npafp_rate` and `per.stool.ad`, or columns that can be
  unambiguously renamed to these.

- dist.extract:

  District-level dataset (one row per district-year) with at minimum
  `adm2guid` and `year`. If it already contains `u15pop`, `npafp_rate`,
  `per.stool.ad`, those are used; otherwise they may be pulled in via
  joins.

- cstool:

  Country-level surveillance stool adequacy dataset with `year` and
  either `adm0guid` or `ctry`, containing `npafp_rate` and
  `per.stool.ad` (or columns that can be renamed to these).

- dstool:

  District-level surveillance stool adequacy dataset with `adm2guid`,
  `year`, and indicator columns such as `npafp_rate`, `per.stool.ad`.

- afp.cases:

  Either:

  - country-year AFP case data with columns `ctry`, `year`, and a cases
    column (e.g., `afp.cases`, `afp.case`, `cases`) **or**

  - region/overall year totals with `year` and a cases column. The
    function will rename the first matching cases column to `afp.cases`.

- start_year, end_year:

  Optional numeric bounds to filter the analysis years, inclusive.

- output:

  One of `"flextable"` (default) or `"tibble"`. When `"tibble"`, returns
  a data frame with columns: `year`, `afp.cases`, `npafp_rate`,
  `per.stool.ad`, `prop.dist.adeq`, `prop`.

## Value

A `flextable` (default) for presentation, or a tibble when
`output = "tibble"`.

## Details

**U15 population column detection**: the function tries to ensure a
column named `u15pop` exists in the joined district data by:

1.  coalescing `u15pop.x`/`u15pop.y` after joins,

2.  renaming common aliases (e.g., `u15_pop`, `U15Pop`, `under15_pop`),
    or

3.  importing from `ctry_data$dist.pop` by `adm2guid` and `year`.

**Adequacy rule (district level)**:

- Adequate if `npafp_rate >= 2` **and** `per.stool.ad >= 80`.

- The % population in adequate ≥100k districts is: \\100 \* (sum(U15 in
  adequate ≥100k districts) / sum(U15 in all ≥100k districts))\\.

  \**Aggregation*\*:

- AFP cases: summed across countries per year.

- `npafp_rate` and `per.stool.ad`: **simple means** across countries per
  year (switch to a weighted mean if needed).

The output `flextable` renders `year` as plain text (no thousands
separator).

## Examples

``` r
if (FALSE) { # \dontrun{
ft <- generate_surv_reg_tab(
  ctry_data    = ctry_data,
  ctry.extract = ctry.extract,
  dist.extract = dist.extract,
  cstool       = cstool,
  dstool       = dstool,
  afp.cases    = afp.cases,
  start_year   = 2021,
  end_year     = 2024,
  output       = "flextable"
)
} # }
```
