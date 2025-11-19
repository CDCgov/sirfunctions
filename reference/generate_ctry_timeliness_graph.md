# Timeliness intervals of samples at the country level

A stacked horizontal bar graph for timeliness intervals of samples at
the country level. To get the full intervals from field to lab, the lab
data needs to be attached. Otherwise, only the timeliness intervals from
the field up to when it was sent to lab will be displayed.

## Usage

``` r
generate_ctry_timeliness_graph(
  int.data,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  afp.year.lab = lifecycle::deprecated()
)
```

## Arguments

- int.data:

  `tibble` Summary table with timeliness intervals at the country level.

- output_path:

  `str` Path where to output the figure.

- afp.year.lab:

  `tibble` **\[deprecated\]** Deprecated since it is not used anymore.

## Value

`ggplot` Plot of timeliness intervals at the country level.

## See also

[`generate_int_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_int_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Attaching lab data
lab_path <- "C:/Users/ABC1/Desktop/algeria_lab_data.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
lab.timeliness.ctry <- generate_lab_timeliness(ctry.data$lab.data, "ctry", start_date, end_date)
int.data.ctry <- generate_int_data(ctry.data, start_date, end_date,
  spatial.scale = "ctry",
  lab.timeliness.ctry
)
generate_ctry_timeliness_graph(int.data.ctry)
} # }
```
