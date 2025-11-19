# Generate AFP case count summary

**\[stable\]**

Summarize AFP case counts by month and another grouping variable.

## Usage

``` r
generate_afp_by_month_summary(
  afp_data,
  start_date,
  end_date,
  by,
  pop_data = NULL,
  ctry.data = lifecycle::deprecated()
)
```

## Arguments

- afp_data:

  `tibble` AFP dataset.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- by:

  `str` How to group the data by. Either `"ctry"`, `"prov"`, `"dist"`,
  or `"year"`.

- pop_data:

  `tibble` Population dataset.

- ctry.data:

  **\[deprecated\]** `ctry.data` is no longer supported; the function
  will explicitly ask for the AFP dataset instead of accessing it from a
  list.

## Value

`tibble` Summary table of AFP cases by month and another grouping
variable.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
afp.by.month <- generate_afp_by_month_summary(
  raw.data$afp, "2021-01-01", "2023-12-31", "ctry",
  raw.data$ctry.pop
)
} # }
```
