# Table of information regarding testing labs in each country

Imports information on testing labs for each country, either from a CSV
file or downloaded from EDAV. If no argument is passed, the function
will download the table from EDAV.

## Usage

``` r
get_lab_locs(lab_locs_path = NULL, use_edav = TRUE)
```

## Arguments

- lab_locs_path:

  `str` Location of testing lab locations. Default is `NULL`. Will
  download from EDAV, if necessary.

- use_edav:

  `logical` Whether to obtain data from EDAV. Defaults to `TRUE`.

## Value

`tibble` A table containing the test lab location information.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.seq <- get_lab_locs()
} # }
```
