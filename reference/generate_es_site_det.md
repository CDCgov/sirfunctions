# Virus detection in ES sites

Generates a dot plot for viral detections across ES sites, with SIA
dates overlaid.

## Usage

``` r
generate_es_site_det(
  sia.data,
  es.data,
  es_start_date = (lubridate::as_date(es_end_date) - lubridate::years(1)),
  es_end_date = end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  vaccine_types = NULL,
  detection_types = NULL,
  ctry.data = lifecycle::deprecated(),
  es.data.long = lifecycle::deprecated()
)
```

## Arguments

- sia.data:

  `tibble` SIA surveillance data.

- es.data:

  Environmental surveillance data, cleaned using
  [`clean_es_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_es_data.md)
  or a cleaned `ctry.data$es`.

- es_start_date:

  `str` Start date of analysis. By default, it is one year from the end
  date.

- es_end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path to output the figure to.

- vaccine_types:

  `list` A named list with colors assigned names corresponding to
  vaccine types. By default, it will use a prefilled list inside the
  function. However, the function will alert for missing vaccine types
  and the user must pass another list appended by that vaccine type.

- detection_types:

  `list` A named list with colors assigned names corresponding to viral
  detection type. By default, it will use a prefilled list inside the
  function. However, the function will alert for missing detection types
  and the user must pass another list appended by that vaccine type.

- ctry.data:

  **\[deprecated\]** Please pass the SIA data directly to sia.data
  instead of a list containing it.

- es.data.long:

  **\[deprecated\]** Please pass cleaned ES data instead.

## Value

`ggplot` A dot plot of viral detections per ES sites and SIA campaigns.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
es.data <- clean_es_data(ctry.data$es)
generate_es_site_det(ctry.data, es.data)
} # }
```
