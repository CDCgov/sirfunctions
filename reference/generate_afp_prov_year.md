# AFP cases by province and year

Generates a tile plot for the number of AFP cases per month by province.

## Usage

``` r
generate_afp_prov_year(
  afp.by.month.prov,
  start_date,
  end_date = lubridate::today(),
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  .height = 5
)
```

## Arguments

- afp.by.month.prov:

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

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
afp.by.month <- generate_afp_by_month(ctry.data$afp.all.2, start_date, end_date)
afp.by.month.prov <- generate_afp_by_month_summary(
  afp.by.month, ctry.data,
  start_date, end_date, "prov"
)
generate_afp_prov_year(afp.by.month.prov, start_date, end_date)
} # }
```
