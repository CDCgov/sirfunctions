# Generate a summary table for sample timeliness intervals

The summary table will output timeliness intervals of samples from
collection to lab testing. Lab timeliness will only be calculated if the
lab data is attached. Otherwise, by default, the function will return
only the timeliness intervals up to when the samples were sent to lab.

## Usage

``` r
generate_int_data(
  afp_data,
  pop_data,
  start_date,
  end_date,
  spatial_scale,
  lab_data_summary = NULL,
  ctry.data = lifecycle::deprecated(),
  spatial.scale = lifecycle::deprecated(),
  lab.data = lifecycle::deprecated()
)
```

## Arguments

- afp_data:

  `tibble` AFP dataset.

- pop_data:

  `tibble` Population dataset that matches the spatial scale.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- spatial_scale:

  `str` Scale to summarize to. Valid values are: `"ctry", "prov"`, or
  `"all"`. `"dist"` not available currently.

- lab_data_summary:

  `tibble` Summarized lab data, if available. This parameter will
  calculate timeliness intervals in the lab. Otherwise, only the field
  component will be presented. This is the output of
  [`generate_lab_timeliness()`](https://cdcgov.github.io/sirfunctions/reference/generate_lab_timeliness.md).

- ctry.data:

  `list` **\[deprecated\]**

- spatial.scale:

  `str` **\[deprecated\]** Renamed in favor of `spatial_scale`.

- lab.data:

  `tibble` **\[deprecated\]** Renamed in favor of `lab_data_summary`.

  Passing ctry.data has been deprecated in favor of independently
  assigning the AFP dataset to afp.data and the population dataset to
  pop.data. This allows the function to run either on raw.data or
  ctry.data.

## Value

`tibble` A table summarizing median days for different timeliness
intervals.

## See also

[`clean_ctry_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_ctry_data.md)

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
ctry.data <- extract_country_data("algeria", raw.data)
# lab data not attached
int.data <- generate_int_data(
  raw.data$afp, raw.data$ctry.pop,
  "2021-01-01", "2023-12-31", "ctry"
)

# If lab data is available. Assume ctry.data is loaded.
lab_path <- "C:/Users/ABC1/Desktop/algeria_lab.csv"
lab.data <- readr::read_csv(lab_path)
lab.data.summary <- generate_lab_timeliness(
  lab.data, "ctry",
  "2021-01-01", "2023-12-31"
)
int.data <- generate_int_data(
  ctry.data$afp.all.2, ctry.data$ctry.pop,
  "2021-01-01", "2023-12-31", "ctry",
  lab.data.summary
)
} # }
```
