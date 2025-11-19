# Label rolling year periods

**\[experimental\]**

The function labels and categorizes dates based on the rolling period
specified. The start year will always be Year 1 and the rolling period
is defined by the start date and the number of periods to account for in
a given rolling year. For example, if the start date is defined as Jan
1, 2021 and we would like to calculate a 12-month rolling period, the
end date would be Dec 31, 2021.

## Usage

``` r
add_rolling_years(
  df,
  start_date,
  end_date,
  date_col,
  period = months(12, FALSE)
)
```

## Arguments

- df:

  `tibble` A dataset containing at least one date column.

- start_date:

  `str` Start date of Year 1. All years are classified in reference to
  this date.

- end_date:

  `str` End date to filter to.

- date_col:

  `str` The name of the date column.

- period:

  `period` A
  [`lubridate::period()`](https://lubridate.tidyverse.org/reference/period.html)
  object. Defaults to `months(12, FALSE)`.

## Value

`tibble` A tibble with rolling year information.

## Details

The function will filter data using the column specified by `date_col`
up to the end date specified.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
afp_data <- add_rolling_years(raw_data$afp, "2021-01-01", "2024-05-02", "dateonset")
} # }
```
