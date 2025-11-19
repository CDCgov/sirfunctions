# Function to calculate timeliness of detection

Calculates the overall timeliness of detection in AFP & ES POLIS data.

## Usage

``` r
f.timely.detection.01(
  afp.data,
  es.data,
  ctryseq.data,
  start.date,
  end.date,
  rolling = F
)
```

## Arguments

- afp.data:

  `tibble` AFP data which includes classification of AFP cases with
  onset date and date of notification to HQ.

- es.data:

  `tibble` ES data which includes classification of samples with
  collection date and date of notification to HQ.

- ctryseq.data:

  `tibble` A table consisting of the following columns for each country:

  - With sequencing capacity within or outside of the country

  - Country (`ADM0_NAME`)

  - Classification of AFP cases & ES samples

  - Onset date of AFP cases and collection date of ES samples

  - Date of notification to HQ (`date.notification.to.hq`)

  This table is the output of
  [`get_lab_locs()`](https://cdcgov.github.io/sirfunctions/reference/get_lab_locs.md).

- start.date:

  `str` Start date for evaluation with format `"YYYY-MM-DD"`.

- end.date:

  `str` End date for evaluation with format `"YYYY-MM-DD"`.

- rolling:

  `logical` Should timeliness be calculated in a rolling basis? Default
  `FALSE`.

## Value

`list` A list with two `tibble`s with global and sub-global AFP / ES
detection timeliness evaluation.

## Examples

``` r
if (FALSE) { # \dontrun{

raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
ctry.seq <- get_lab_locs()
global.summary <- f.timely.detection.01(
  raw.data$afp, raw.data$es, ctry.seq,
  "2021-01-01", "2023-12-31"
)
ctry.summary <- f.timely.detection.01(
  ctry.data$afp.all.2, ctry.data$es, ctry.seq,
  "2021-01-01", "2023-12-31"
)
} # }
```
