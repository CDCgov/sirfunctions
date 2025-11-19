# Export stool adequacy data

The function combines the stool adequacy summary tables from
[`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
and exports to an Excel file, with each geographic level on its own tab.

## Usage

``` r
create_stool_adequacy_export(
  cstool,
  pstool,
  dstool,
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- cstool:

  `tibble` Stool adequacy at country level.

- pstool:

  `tibble` Stool adequacy at province level.

- dstool:

  `tibble` Stool adequacy at district level.

- excel_output_path:

  `str` Output path.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
cstool <- f.stool.ad.01(
  ctry.data$afp.all.2, ctry.data$ctry.pop,
  "2021-01-01", "2023-01-01", "ctry"
)
pstool <- f.stool.ad.01(
  ctry.data$afp.all.2, ctry.data$prov.pop,
  "2021-01-01", "2023-01-01", "prov"
)
dstool <- f.stool.ad.01(
  ctry.data$afp.all.2, ctry.data$dist.pop,
  "2021-01-01", "2023-01-01", "dist"
)
create_stool_adequacy_export(cstool, pstool, dstool)
} # }
```
