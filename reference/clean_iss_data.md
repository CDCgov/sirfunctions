# Perform common cleaning tasks for ISS/eSURV data

ISS/eSURV data often needs to be cleaned and standardized before
analysis. Because these datasets may vary from country to country,
reviewing the data first and its columns is the first step. In general,
there are eight required columns. These are the parameters with a suffix
`_col`. Modify the passed arguments as necessary so the function can
successfully run. Priority levels are set to automatically detect high,
medium, low, and not a focal site. Ensure that priority level column
categories have these specification:

- `High`: begins with "h".

- `Medium`: begins with "m".

- `Low`: begins with "l".

- `Not Focal Site`: begins with "n" or "x".

## Usage

``` r
clean_iss_data(
  iss_data,
  start_date,
  end_date,
  priority_col = "priority_level",
  start_time_col = "starttime",
  unreported_cases_col = "num_unreportedcases",
  prov_col = "states",
  dist_col = "districts",
  hf_col = "name_of_facility_visited",
  today_col = "today",
  date_of_visit_col = "date_of_visit",
  ctry.data = lifecycle::deprecated()
)
```

## Arguments

- iss_data:

  `tibble` ISS data.

- start_date:

  `str` Start date of desk review.

- end_date:

  `str` End date of desk review.

- priority_col:

  `str` Column representing priority level.

- start_time_col:

  `str` Column representing start time.

- unreported_cases_col:

  `str` Column representing unreported cases.

- prov_col:

  `str` Column representing province.

- dist_col:

  `str` Column representing district.

- hf_col:

  `str` Column representing the health facility name.

- today_col:

  `str` Column representing when info was recorded.

- date_of_visit_col:

  `str` Column representing date of visit.

- ctry.data:

  `list` **\[deprecated\]** Please pass the ISS data directly to the
  iss.data parameter.

## Value

`tibble` Cleaned eSurv/ISS data.

## Examples

``` r
if (FALSE) { # \dontrun{
iss_path <- "C:/Users/ABC1/Desktop/iss_data.csv"
ctry.data <- init_dr("somalia", iss_data_path = iss_path)
ctry.data$iss.data <- clean_iss_data(ctry.data$iss.data, start_date, end_date)
} # }
```
