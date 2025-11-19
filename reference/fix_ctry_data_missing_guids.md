# Fix unknown GUIDs in the AFP linelist

Fix unknown GUIDs in the AFP linelist by obtaining GUIDs found in the
pop files. It attempts to replace the unknown GUIDs from the AFP
linelist by using geographic info for a specific year that coincides
with the case date and uses the GUIDs contained in the current spatial
data instead.

## Usage

``` r
fix_ctry_data_missing_guids(afp.data, pop.data, guid_list, spatial_scale)
```

## Arguments

- afp.data:

  `tibble` AFP linelist (afp.all.2).

- pop.data:

  `tibble` Population file (prov.pop or dist.pop).

- guid_list:

  `str list` Unknown GUIDs from the AFP linelist. This is the output of
  [`check_afp_guid_ctry_data()`](https://cdcgov.github.io/sirfunctions/reference/check_afp_guid_ctry_data.md).

- spatial_scale:

  `str` The spatial scale to impute data. Either `"prov"` or `"dist"`.

## Value

`tibble` AFP data with corrected GUIDs based on the population files.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data()
ctry.data <- extract_country_data("algeria", raw.data)
error.list <- check_afp_guid_ctry_data(ctry.data)
ctry.data$afp.all.2 <- fix_ctry_data_missing_guids(
  ctry.data$afp.all.2,
  ctry.data$dist.pop,
  error.list$dist_mismatches_pop,
  "dist"
)
} # }
```
