# Timeliness intervals of samples at the province level

A stacked horizontal bar graph for timeliness intervals of samples at
the province level. To get the full intervals from field to lab, the lab
data needs to be attached. Otherwise, only the timeliness intervals from
the field up to when it was sent to lab will be displayed.

## Usage

``` r
generate_prov_timeliness_graph(
  int.data,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  afp.prov.year.lab = lifecycle::deprecated()
)
```

## Arguments

- int.data:

  `tibble` Summary table with timeliness intervals at the province
  level.

- output_path:

  `str` Path where to output the figure.

- afp.prov.year.lab:

  `tibble` **\[deprecated\]** Deprecated since it is not used anymore.

## Value

`ggplot` Plot of timeliness intervals at the country level.

## Examples

``` r
if (FALSE) { # \dontrun{
# Attaching lab data
lab_path <- "C:/Users/ABC1/Desktop/algeria_lab_data.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
lab.timeliness.prov <- generate_lab_timeliness(ctry.data$lab.data, "prov", start_date, end_date)
int.data.prov <- generate_int_data(ctry.data, start_date, end_date,
  spatial.scale = "prov",
  lab.timeliness.prov
)
generate_ctry_timeliness_graph(int.data.prov)
} # }
```
