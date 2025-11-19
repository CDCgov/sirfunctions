# Set plot looks

The function serves to collate and return plot looks. Depending on the
parameter, specific values in a `ggplot2` theme object will be returned.

## Usage

``` r
f.plot.looks(type)
```

## Arguments

- type:

  `str` Type of graph format. Accepted values include:

  - `"02"`

  - `"epicurve"`

  - `"geomtile"`

  - `"gpln_type1"`

  - `"gpln_type2"`

## Value

`ggplot2 theme obj` A theme object that can be added into an existing
plot.

## Examples

``` r
if (FALSE) { # \dontrun{
epicurve_looks <- f.plot.looks("epicurve")
df <- datasets::iris
p1 <- ggplot2::ggplot() +
  ggplot2::geom_col(data = df, ggplot2::aes(x = Sepal.Length, y = Sepal.Width))
p2 <- p1 + epicurve_looks
} # }
```
