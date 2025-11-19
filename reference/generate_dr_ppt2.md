# Generate the desk review slide deck from the figures folder

Generating the PowerPoint from the figures folder is generally faster
and allows figures to remain consistent. Tables remain as PowerPoint
tables.

## Usage

``` r
generate_dr_ppt2(
  ctry.data,
  start_date,
  end_date,
  surv.ind.tab,
  inad.tab.flex,
  tab.60d,
  pop.tab,
  es.table,
  ppt_template_path = NULL,
  fig.path = Sys.getenv("DR_FIGURE_PATH"),
  country = Sys.getenv("DR_COUNTRY"),
  ppt_output_path = Sys.getenv("DR_POWERPOINT_PATH")
)
```

## Arguments

- ctry.data:

  `list` Country polio data. Either the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- start_date:

  `str` Start date of desk review.

- end_date:

  `str` End date of desk review.

- surv.ind.tab:

  `flextable` Surveillance indicator table

- inad.tab.flex:

  `flextable` Inadequates table.

- tab.60d:

  `flextable` 60-day follow-up table.

- pop.tab:

  `flextable` Population table.

- es.table:

  `flextable` ES table.

- ppt_template_path:

  `str` Path to the PowerPoint template.

- fig.path:

  `str` File path to the figures folder.

- country:

  `str` Name of the country.

- ppt_output_path:

  `str` Path where the PowerPoint should be outputted.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assume all figures and tables are assigned to the appropriate variable.
ppt_template <- "C:/Users/ABC1/Desktop/deskreview_template.pptx"
generate_dr_ppt2(ctry.data, start_date, end_date,
  surv.ind.tab, inad.tab.flex, tab.60d, es.table,
  ppt_template_path = ppt_template
)
} # }
```
