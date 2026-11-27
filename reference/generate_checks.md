# Generate diagnostic checks workbook

Creates the core surveillance diagnostic tables and optional expanded
KPI check sheets. The same function can be used by the
country-prioritization and KPI workflows.

## Usage

``` r
generate_checks(
  raw_data,
  start_date,
  end_date,
  output_path = NULL,
  missing_agemonths = TRUE,
  include_details_inconsisten_GUIDs = FALSE
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

- output_path:

  Optional Excel output path. If `NULL`, no workbook is written.

- missing_agemonths:

  `logical` Whether district NPAFP eligibility checks include cases with
  missing `age.months`. Defaults to `TRUE`, matching the
  country-prioritization calculation.

- include_details_inconsisten_GUIDs:

  `logical` Whether to include the optional `C1_Checks` sheet containing
  inconsistent GUID details. Defaults to `FALSE`.

## Value

A list containing the three core check tables, the ES site check, and
the optional inconsistent GUID detail table.
