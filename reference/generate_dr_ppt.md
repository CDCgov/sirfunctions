# Generate the desk review slide deck

The original function to build the desk review PowerPoint. This function
has been superseded by
[`generate_dr_ppt2()`](https://cdcgov.github.io/sirfunctions/reference/generate_dr_ppt2.md).
The function outputs images to the PowerPoint directly from objects,
unlike
[`generate_dr_ppt2()`](https://cdcgov.github.io/sirfunctions/reference/generate_dr_ppt2.md)
which uses images saved in a folder.

## Usage

``` r
generate_dr_ppt(
  ctry.data,
  start_date,
  end_date,
  pop.map,
  pop.map.prov,
  afp.case.map,
  afp.epi.curve,
  surv.ind.tab,
  afp.dets.prov.year,
  pop.tab,
  npafp.map,
  npafp.map.dist,
  stool.ad.maps,
  stool.ad.maps.dist,
  inad.tab.flex,
  tab.60d,
  case.num.dose.g,
  timely_nation,
  timely_prov,
  mapt_all,
  es.site.det,
  es.det.map,
  es.timely,
  es.table,
  country = Sys.getenv("DR_COUNTRY"),
  ppt_template_path = NULL,
  ppt_output_path = Sys.getenv("DR_POWERPOINT_PATH")
)
```

## Arguments

- ctry.data:

  `list` List containing polio data for a country. Either the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- start_date:

  `str` Start date of desk review.

- end_date:

  `str` End date of desk review.

- pop.map:

  `ggplot` Country pop map.

- pop.map.prov:

  `ggplot` Prov pop map.

- afp.case.map:

  `ggplot` Map of afp cases.

- afp.epi.curve:

  `ggplot` AFP epicurve.

- surv.ind.tab:

  `flextable` Surveillance indicator table.

- afp.dets.prov.year:

  `ggplot` AFP detections for province.

- pop.tab:

  `flextable` Table of population.

- npafp.map:

  `ggplot` NPAFP map for country level.

- npafp.map.dist:

  `ggplot` NPAFP map for district level.

- stool.ad.maps:

  `ggplot` Stool adequacy maps at province.

- stool.ad.maps.dist:

  `ggplot` Stool adequacy maps at district.

- inad.tab.flex:

  `flextable` Inadequate table.

- tab.60d:

  `flextable` 60-day follow-up table.

- case.num.dose.g:

  `ggplot` Immunization rates per year.

- timely_nation:

  `ggplot` Timeliness at country level.

- timely_prov:

  `ggplot` Timeliness at province level.

- mapt_all:

  `ggplot` Map with all indicators.

- es.site.det:

  `ggplot` ES site viral detection.

- es.det.map:

  `ggplot` ES site detection maps.

- es.timely:

  `ggplot` ES timeliness.

- es.table:

  `flextable` ES table.

- country:

  `str` Name of the country.

- ppt_template_path:

  `str` Path to the PowerPoint template.

- ppt_output_path:

  `str` Path where the PowerPoint should be outputted.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assume all figures and tables are assigned to the appropriate variable.
template_path <- "C:/Users/ABC1/Desktop/deskreview_template.pptx"
generate_dr_ppt(
  template_path, ctry.data, start_date, end_date, pop.map,
  pop.map, pop.map.prov, afp.case.map, afp.epi.curve,
  surv.ind.tab, afp.dets.prov.year, pop.tab, npafp.map,
  npafp.map.dist, stool.ad.maps, stool.ad.maps.dist,
  inad.tab.flex, tab.60d, case.num.dose.g,
  timely_nation, timely_prov,
  mapt_all, es.site.det, es.det.map, es.timely,
  es.table
)
} # }
```
