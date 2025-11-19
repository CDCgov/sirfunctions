# Calculate percent stool adequacy

Creates a summary table of stool adequacy. The `missing` parameter
defines how missing data is treated. `"good"` classifies missing data as
good quality (POLIS method). `"bad"` classifies all missing as bad
quality. `"missing"` excludes missing from the calculations.

## Usage

``` r
f.stool.ad.01(
  afp.data,
  pop.data,
  start.date,
  end.date,
  spatial.scale,
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = T,
  admin.data = lifecycle::deprecated()
)
```

## Arguments

- afp.data:

  `tibble` AFP data which includes GUID at a given spatial scale
  formatted as `adm(0,1,2)guid`, onset date as `date` and
  `cdc.classification.all2` which includes "NOT-AFP".

- pop.data:

  `tibble` Full list of country administrative units by a given spatial
  scale including `year`, `adm(0,1,2)guid`, and `ctry/prov/dist` (as
  appropriate).

- start.date:

  `str` Starting date for analysis formatted as "YYYY-MM-DD".

- end.date:

  `str` Ending date for analysis as "YYYY-MM-DD".

- spatial.scale:

  `str` Geographic level to group analysis on.

  - `"prov"` Province level.

  - `"dist"` District level.

  - `"ctry"` Country level.

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

- rolling:

  `logical` Should data be analyzed on a rolling bases? Defaults to
  `FALSE`.

- sp_continuity_validation:

  `logical` Should GUIDs not present in all years of the dataset be
  excluded? Default `TRUE`.

- admin.data:

  `tibble` Population data. Renamed in favor of `pop.data`.

## Value

`tibble` Long format stool adequacy evaluations.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
stool.ads <- f.stool.ad.01(raw.data$afp, raw.data$ctry.pop,
  "2021-01-01", "2023-12-31",
  "ctry",
  sp_continuity_validation = FALSE
)
} # }
```
