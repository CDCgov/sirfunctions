# Creating a table of compatible and potentially compatible cases

Creates a table of compatible and potentially compatible cases, with an
optional parameter to run a clustering algorithm.

## Usage

``` r
generate_potentially_compatibles_cluster(cases.need60day, create_cluster = F)
```

## Arguments

- cases.need60day:

  `tibble` Summary table of cases that need 60-day follow-up. This is
  the output of
  [`generate_60_day_table_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md).

- create_cluster:

  `logical` Add column for clusters? Default to `FALSE`.

## Value

`tibble` A summary table of cases.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
stool.data <- generate_stool_data(
  ctry.data$afp.all.2, "2021-01-01", "2023-12-31",
  "good", "inadequate"
)
table60.days <- generate_60_day_table_data(stool.data, "2021-01-01", "2023-12-31")
pot.c.clust <- generate_potentially_compatibles_cluster(table60.days,
  create_cluster = TRUE
)
} # }
```
