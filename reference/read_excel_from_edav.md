# Reads an Excel file from EDAV to the R environment

**\[experimental\]**

This function is an extension of the readxl() that adapts to files with
multiple tabs. If there are multiple tabs, each sheet are downloaded
into a named list with the corresponding tab name.

## Usage

``` r
read_excel_from_edav(src, sheet = NULL, ...)
```

## Arguments

- src:

  `str` Path to the Excel file.

- sheet:

  `int` or `str` Sheet to read. Either a string (the name of a sheet),
  or an integer (the position of the sheet). Ignored if the sheet is
  specified via range. If neither argument specifies the sheet, defaults
  to the first sheet.

- ...:

  Additional parameters of
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

## Value

`tibble` or `list` A tibble or a list of tibbles containing data from
the Excel file.

## Details

Actually, this function doesn't need to be used on EDAV files. It can
work with local files as well.
