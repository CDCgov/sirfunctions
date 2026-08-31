# Generate and write one prov AFP desk-review PowerPoint

This is the one-call interface: it creates all prov figures and tables
in memory, then writes them to a PowerPoint. No separate figure files
are required.

## Usage

``` r
generate_prov_desk_review_ppt(
  ctry.data,
  prov_name,
  dist.extract,
  pstool,
  dstool,
  cases.need60day,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  ppt_output_file,
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

- prov_name:

  PROV name.

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

- ppt_output_file:

  Full output filename.

- ppt_template_path:

  Optional PowerPoint template path.

- master, title_layout, content_layout:

  Template master and layout names.

- es_start_date, es_end_date:

  ES analysis dates. Defaults to the year ending on `end_date`.

## Value

The normalized path of the PowerPoint file, invisibly.
