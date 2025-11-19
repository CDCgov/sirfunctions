# Function to add metadata tags to figures and tables

Add metadata tags to figures and tables. These include the download date
of the dataset. The function will return an error if both `raw_data` and
`time_tag` parameters are `NULL`.

## Usage

``` r
f.metadata.tag(object, raw_data = NULL, time_tag = NULL)
```

## Arguments

- object:

  `ggplot` or `flextable` The figure or table to add metadata to.

- raw_data:

  `list` outputs of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  or
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md).

- time_tag:

  `str` A date and time string. Defaults to
  `raw.data$metadata$download_time`.

## Value

A `ggplot` or `flextable` object with metadata added.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
df <- datasets::iris
p1 <- ggplot2::ggplot() +
  ggplot2::geom_col(data = df, ggplot2::aes(x = Sepal.Length, y = Sepal.Width))
p2 <- f.metadata.tag(p1, raw.data) # use raw.data download time
p3 <- f.metadata.tag(p1, time_tag = "2021-01-01") # use custom time tag
} # }
```
