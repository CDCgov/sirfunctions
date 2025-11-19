# Generates KPI violin plot

**\[experimental\]**

This function is generalized to produce violin plots used in the KPI
code.

## Usage

``` r
generate_kpi_violin(
  df,
  country.label,
  interval,
  priority_level,
  faceting,
  target,
  y.min = 0,
  y.max
)
```

## Arguments

- df:

  `tibble` Data to be used.

- country.label:

  `quoted var` Country label.

- interval:

  `quoted var` Interval to use.

- priority_level:

  `quoted var` Priority level column.

- faceting:

  `ggplot::facet` A faceting object.

- target:

  `num` Numeric target.

- y.min:

  `num` Minimum used in the y-axis.

- y.max:

  `num` Maximum used in the y-axis.

## Value

`ggplot` A plot object.
