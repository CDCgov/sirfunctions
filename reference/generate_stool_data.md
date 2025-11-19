# Generate stool adequacy columns in the AFP dataset

The function adds the adequacy final column called `adequacy.final` and
`adequacy.final2` into the AFP linelist. The function borrows in part
from
[`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md),
so that the adequacy final column generated can match with how the stool
adequacy function treats bad or missing data and classify the adequacy
final column. `adequacy.final` contains the original classification of
the sample and `adequacy.final2` contains the final classification
according to how missing and bad data are treated.

## Usage

``` r
generate_stool_data(
  afp.data,
  start_date,
  end_date,
  missing = "good",
  bad.data = "inadequate"
)
```

## Arguments

- afp.data:

  `tibble` AFP linelist. Either `ctry.data$afp.all.2`

- start_date:

  `str` Start date of the analysis.

- end_date:

  `str` End date of the analysis.

- missing:

  `str` How to treat missing data. Valid values are:
  `"good", "bad", "remove"`. Defaults to `"good"`. When calculating the
  `adequacy.final` column:

  - `"good"` uses `adequacy.03`

  - `"bad"` uses `adequacy.01`

  - `"exclude"` uses `adequacy.02`

- bad.data:

  `str` How to treat bad data. Valid values
  are:`"remove", "inadequate"`. Defaults to `"inadequate"`.
  `"inadequate"` treats samples with bad data as inadequate.

## Value

`tibble` AFP linelist with stool adequacy columns.

## Details

Unlike the stool adequacy function, this will not filter out `NOT-AFP`
cases, as it is expected for other functions that use the output of this
function to do the filtering. For example,
[`generate_60_day_table_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md).

## See also

[`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
stool.data <- generate_stool_data(raw.data$afp, "2021-01-01", "2023-12-31")
} # }
```
