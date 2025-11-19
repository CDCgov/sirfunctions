# Add the risk category based on the country

Add the risk category based on the country

## Usage

``` r
add_risk_category(df, risk_table = NULL, ctry_col = "ctry")
```

## Arguments

- df:

  `tibble` Dataframe with at least a column for country

- risk_table:

  `tibble` Risk category table for each country. Defaults to `NULL`.
  When set to `NULL`, attempts to download the risk category table from
  EDAV.

## Value

`tibble` A dataframe with risk category columns added.
