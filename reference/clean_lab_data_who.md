# Clean polio lab data from WHO

Cleans the lab data from WHO. This is used in
[`clean_lab_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_lab_data.md),
but can be used on its own.

## Usage

``` r
clean_lab_data_who(
  lab_data,
  start_date,
  end_date,
  afp_data = NULL,
  ctry_name = NULL
)
```

## Arguments

- lab_data:

  `tibble` Lab dataset.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- afp_data:

  `tibble` AFP linelist. Either `ctry.data$afp.all.2` or `raw.data$afp`.

- ctry_name:

  `str` or `list` Name or a list of countries. Defaults to `NULL`.

## Value

`tibble` Cleaned lab data.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/XRG9/lab_data_who.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
ctry.data$lab_data <- clean_lab_data_who(ctry.data, "2021-01-01", "2023-12-31")

# Not using the desk review pipeline
raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
ctry.data$lab_data <- read_csv(lab_path)
ctry.data$lab_data <- clean_lab_data_who(ctry.data, "2021-01-01", "2023-12-31")
} # }
```
