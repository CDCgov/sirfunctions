# Country map with province populations

The map displays the U15 population for each province for a country.

## Usage

``` r
generate_pop_map(
  ctry.data,
  ctry.shape,
  prov.shape,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  caption_size = 11
)
```

## Arguments

- ctry.data:

  `list` Large list containing country polio data. This is the output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- ctry.shape:

  `sf` Country shape file in long format.

- prov.shape:

  `sf` Province shape file in long format.

- end_date:

  `str` End date of the analysis.

- output_path:

  `str` Local path where to save the figure.

- caption_size:

  `numeric` Size of the caption. Default is `11`.

## Value

`ggplot` A map of U15 province populations and population centers.

## See also

[`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md),
[`load_clean_prov_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_prov_sp.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_pop_map(ctry.data, ctry.shape, prov.shape, "2023-12-31")
} # }
```
