# Write prov AFP outputs to a PowerPoint

The title slide begins with the selected prov name. Figures are inserted
as editable vector graphics and flextables remain native PowerPoint
tables.

## Usage

``` r
write_prov_desk_review_ppt(
  prov_outputs,
  prov_name,
  start_date,
  end_date,
  ppt_output_file,
  ppt_template_path = NULL,
  master = "1_Office Theme",
  title_layout = "Title Slide",
  content_layout = "Title and Content"
)
```

## Arguments

- prov_outputs:

  Named list returned by
  [`generate_prov_desk_review_outputs()`](https://cdcgov.github.io/sirfunctions/reference/generate_prov_desk_review_outputs.md).

- prov_name:

  PROV name displayed on the first slide.

- start_date, end_date:

  Analysis dates.

- ppt_output_file:

  Full path and filename for the `.pptx` file.

- ppt_template_path:

  Optional desk-review PowerPoint template. `NULL` uses the template
  returned by
  [`get_ppt_template()`](https://cdcgov.github.io/sirfunctions/reference/get_ppt_template.md).

- master:

  PowerPoint master name used by the desk-review template.

- title_layout, content_layout:

  Layout names used by the template.

## Value

The normalized path of the PowerPoint file, invisibly.
