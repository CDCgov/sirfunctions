# Get the columns where records differ in a group

Get the columns where duplicates differ after performing a
[`dplyr::distinct()`](https://dplyr.tidyverse.org/reference/distinct.html)
operation. In some instances, two records might exist with the same
unique identifier. In datasets with lots of columns, it is difficult to
figure out which columns these potential duplicates differ. The function
outputs the columns where records with the same unique identifier
differ.

## Usage

``` r
get_diff_cols(df, id_col)
```

## Arguments

- df:

  `df` or `tibble` Dataframe with at least one column containing unique
  identifiers and other columns.

- id_col:

  `str` Column used as a unique identifier for records.

## Value

`tibble` A tibble showing the columns where duplicates differ.

## Examples

``` r
df1 <- dplyr::tibble(col1 = c(1, 1, 2), col2 = c("a", "b", "c"), col3 = c(1, 1, 3))
diff_cols <- get_diff_cols(df1, "col1")
```
