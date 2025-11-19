# Adjusts the end final year of the rolling period

**\[experimental\]**

In some instances, the final 12-month rolling period year goes beyond
the stated end date of the analysis. The function adjusts the final year
rolling period so that it is only up to the end date.

## Usage

``` r
adjust_rolling_years(data, end_date, date_col)
```

## Arguments

- data:

  `tibble` Data with rolling period columns.

- end_date:

  `str` The specified end date.

- date_col:

  `str` Column used when filtering by the end date.

## Value

`tibble` Tibble with adjusted rolling period for the final year.

## Details

As a consequence of the adjustment, the function will also ensure that
the final data output also only contains records that are only up to the
end date.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = F)
afp_data <- raw_data$afp
afp_data <- add_rolling_years(afp_data, start_date = "2022-01-01")
afp_data <- adjust_rolling_years(afp_data, "2025-02-25")
} # }
```
