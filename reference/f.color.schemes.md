# Utility function for colors

Utility function to return SIR color schemes used in various graphs and
visualizations.

## Usage

``` r
f.color.schemes(type)
```

## Arguments

- type:

  `str` Type of colors we can return. Accepted values include:

  - `"epicurve"` Mapped to different `cdc.classification.all2` values.

  - `"para.case"` A subset of `"epicurve"` representing paralytic cases.

  - `"afp.prov"` Mapped for case counts at the province level.

  - `"afp.dist"` Mapped for case counts at the province level.

  - `"pot.comp"` Colors for categories of compatibles and potentially
    compatibles.

  - `"silence"` Colors to use to map silent populations.

  - `"silence.v2"` Colors to use to map silent populations.

  - `"cases"` Values to map case type.

  - `"es"` Values used in ES data.

  - `"mapval"` Values used for creating maps with percentages.

  - `"timeliness.col.vars"` Mapping intervals used for lab timeliness
    intervals graphs.

  - `"emergence.groups"` Standard emergence group colors. Used primarily
    with
    [`generate_adhoc_map()`](https://cdcgov.github.io/sirfunctions/reference/generate_adhoc_map.md).

  - `"es.vaccine.types"` Default vaccine types. Used primarily with
    [`generate_es_site_det()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_site_det.md).

  - `"es.detections"` Default detection types. Used primarily with
    [`generate_es_site_det()`](https://cdcgov.github.io/sirfunctions/reference/generate_es_site_det.md).

  - `"vpd.critical.ctry"`: Priority VPD countries

  - `"vpd.binary.ctry"`: Priority and non-priority VPD countries binary
    designation.

  - `"vpd.colors"`: VPD colors.

## Value

Named `list` with color sets.

## Examples

``` r
color_list <- f.color.schemes("epicurve")
```
