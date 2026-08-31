# Generate one AFP desk-review PowerPoint per prov

Generate one AFP desk-review PowerPoint per prov

## Usage

``` r
generate_all_prov_desk_review_ppts(
  ctry.data,
  dist.extract,
  pstool,
  dstool,
  cases.need60day,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  ppt_output_dir,
  prov_names = list_desk_review_prov(ctry.data),
  ppt_template_path = NULL,
  master = "1_Office Theme",
  title_layout = "Title Slide",
  content_layout = "Title and Content",
  es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
  es_end_date = end_date
)
```

## Arguments

- ctry.data:

  Country data returned by
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- dist.extract:

  District output from
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md).

- pstool, dstool:

  Province and district outputs from
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md).

- cases.need60day:

  Output from
  [`generate_60_day_table_data()`](https://cdcgov.github.io/sirfunctions/reference/generate_60_day_table_data.md).

- prov.shape, dist.shape:

  Long-format PROV and DIST geometry.

- start_date, end_date:

  Analysis dates.

- ppt_output_dir:

  Existing directory where the prov decks are written.

- prov_names:

  Character vector of prov_names. Defaults to every prov returned by
  `list_desk_review_prov(ctry.data)`.

- ppt_template_path:

  Optional PowerPoint template path.

- master, title_layout, content_layout:

  Template master and layout names.

- es_start_date, es_end_date:

  ES analysis dates. Defaults to the year ending on `end_date`.

## Value

A named character vector of generated PowerPoint paths.
