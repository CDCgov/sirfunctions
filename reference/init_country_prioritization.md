# Initialize a country-prioritization analysis

Creates a run folder and writes an editable country-prioritization
template.

## Usage

``` r
init_country_prioritization(path = getwd(), name = NULL, edav = TRUE)
```

## Arguments

- path:

  `str` Parent folder for country-prioritization runs.

- name:

  `str` Name of the run folder. Defaults to today's date.

- edav:

  `logical` Retained for compatibility with earlier templates. Data are
  not downloaded or saved by this initializer; the generated template
  calls
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)
  directly.

## Value

Invisibly returns the run folder path.
