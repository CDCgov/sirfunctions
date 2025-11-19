# Exports NPAFP indicator data summary tables

The function combines the NPAFP rate summary tables from
[`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
and exports to an Excel file, with each geographic level on its own tab.

## Usage

``` r
create_npafp_export(
  ctry.case.ind,
  prov.case.ind,
  dist.case.ind,
  excel_output_path = Sys.getenv("DR_TABLE_PATH")
)
```

## Arguments

- ctry.case.ind:

  `tibble` Country NPAFP indicator summary table.

- prov.case.ind:

  `tibble` Province NPAFP indicator summary table.

- dist.case.ind:

  `tibble` District NPAFP indicator summary table.

- excel_output_path:

  `str` Output path of the Excel file.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.case.ind <- f.npafp.rate.01(
  ctry.data$afp.all.2, ctry.data$ctry.pop,
  "2021-01-01", "2023-01-01", "ctry"
)
prov.case.ind <- f.npafp.rate.01(
  ctry.data$afp.all.2, ctry.data$prov.pop,
  "2021-01-01", "2023-01-01", "prov"
)
dist.case.ind <- f.npafp.rate.01(
  ctry.data$afp.all.2, ctry.data$dist.pop,
  "2021-01-01", "2023-01-01", "dist"
)
create_npafp_export(ctry.case.ind, prov.case.ind, dist.case.ind)
} # }
```
