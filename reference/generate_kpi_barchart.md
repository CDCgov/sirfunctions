# Generate KPI indicator bar charts

**\[experimental\]**

A generalized function to create bar charts using the KPI tables.

## Usage

``` r
generate_kpi_barchart(df, indicator, target, label, faceting, y.axis.title)
```

## Arguments

- df:

  `tibble` A KPI table, namely C1-C4.

- indicator:

  `str` Name of the indicator within the KPI table.

- target:

  `num` A numeric target.

- label:

  `str` Name of the column containing labels.

- faceting:

  `ggplot2` A ggplot2 faceting object. Either using
  [`ggplot2::facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html)
  or
  [`ggplot2::facet_wrap()`](https://ggplot2.tidyverse.org/reference/facet_wrap.html).

- y.axis.title:

  `Str` Title of the y axis.

## Value

`ggplot2` A bar chart.
