# Calculate stool collection timeliness using only AFP data (DRAFT)

**\[deprecated\]**

Creates a table for timeliness by geographic unit including the number
of timely stool samples for each interval and percent timeliness.
Currently, the function will only work on `ctry.data` (output of
[`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)).

## Usage

``` r
f.timely.01(
  afp.data,
  admin.data,
  start.date,
  end.date,
  spatial.scale,
  intervals.manual = F
)
```

## Arguments

- afp.data:

  `tibble` AFP data which includes GUID at a given spatial scale
  formated as `adm(0,1,2)guid`, onset date as `date`.

- admin.data:

  `tibble` Full list of country administrative units by a given spatial
  scale including `year`, `adm(0,1,2)guid`, and `ctry/prov/dist` as
  appropriate.

- start.date:

  `str` Start date of the analysis formatted as `"YYYY-MM-DD"`.

- end.date:

  `str` End date of the analysis formatted as `"YYYY-MM-DD"`.

- spatial.scale:

  `str` Spatial scale to group analysis by. Valid values are: -`"prov"`
  Province level.

  - `"dist"` District level.

  - `"ctry"` Country level.

- intervals.manual:

  `logical` Should user input their own timeliness interval
  requirements? Default is `FALSE`. This is only required if timeliness
  column such as `noti.7d.on`, `inv.2d.noti` are not already calculated.
  This draft function will currently fail if this parameter is set to
  `TRUE`.

## Value

`tibble` A summary table of timeliness of stool collection.

## Details

This function is no longer maintained as it is not used in any of the
analytic pipelines. An equivalent function is
[`generate_int_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_int_data.md),
which expands and simplifies this function by also being able to take
lab data to calculate lab timeliness intervals.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
stool.summary <- f.timely.01(
  ctry.data$afp.all.2, ctry.data$ctry.pop,
  lubridate::as_date("2021-01-01"),
  lubridate::as_date("2023-12-31"),
  "ctry"
)
} # }
```
