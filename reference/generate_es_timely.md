# ES timeliness scatterplot

Generates a scatterplot of the time it takes for each environmental
samples to arrive in lab.

## Usage

``` r
generate_es_timely(
  es.data,
  es_start_date = (lubridate::as_date(es_end_date) - lubridate::years(1)),
  es_end_date = end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  add_legend = TRUE,
  .color = "site.name"
)
```

## Arguments

- es.data:

  `tibble` ES data.

- es_start_date:

  `str` Start date of analysis. By default, this is one year from the
  end date.

- es_end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path for where to save the figure to.

- add_legend:

  `logical` Whether to add or remove a legend in the figure.

- .color:

  `str` What column to use as color. Defaults to `site.name`.

## Value

`ggplot` A scatterplot for timeliness of ES samples.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
generate_es_timely(ctry.data$es)
} # }
```
