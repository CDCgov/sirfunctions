# AFP cases by ctry and year

Generates a tile plot for the number of AFP cases per month by country.

## Usage

``` r
generate_afp_ctry_year(
  afp.by.month.ctry,
  start_date,
  end_date = lubridate::today(),
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  .height = 5
)
```

## Arguments

- afp.by.month.ctry:

  `tibble` Table summarizing AFP cases by month and province. This is
  the output of
  [`generate_afp_by_month_summary()`](https://cdcgov.github.io/sirfunctions/reference/generate_afp_by_month_summary.md).

- start_date:

  `str` Start date of the analysis.

- end_date:

  `str` End date of the analysis. By default, it displays the most
  recent date.

- output_path:

  `str` Local path to output the figure.

- .height:

  `int` Change the height of the figure. Defaults to 5.

## Value

`ggplot` A tile plot displaying the number of AFP cases by month and
province.

## Examples
