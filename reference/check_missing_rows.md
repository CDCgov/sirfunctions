# Check for rows with NA values

A general function that checks the number of `NA` rows for a particular
column.

## Usage

``` r
check_missing_rows(df, .col_name, .group_by)
```

## Arguments

- df:

  `tibble` Dataset to check.

- .col_name:

  `str` Name of the target column.

- .group_by:

  `str` or `list` A string or a list of strings to group the check by.

## Value

`tibble` A summary of the number of rows missing for the target
variable.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
missing <- check_missing_rows(raw.data$afp, "age.months", c("place.admin.0", "yronset"))
} # }
```
