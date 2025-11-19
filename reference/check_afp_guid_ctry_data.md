# Check GUIDs present in the AFP linelist but not in the pop files

The function will run a check in the AFP linelist for GUIDs that are not
part of the spatial files. In these instances, typically, unknown GUIDs
are part of the new geodatabase from WHO that get released in the next
updated geodatabase. Therefore, this function should be used only if
necessary. For example, in instances where mapping an AFP case into a a
district is critical and the shapefile from
[`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
is not yet updated.

## Usage

``` r
check_afp_guid_ctry_data(ctry.data)
```

## Arguments

- ctry.data:

  `list` Country polio data, with spatial data attached. Output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

## Value

`list` A list containing errors in province and district GUIDs.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data() # must contain spatial data to run the function
ctry.data <- extract_country_data("algeria", raw.data)
error.list <- check_afp_guid_ctry_data(ctry.data)
} # }
```
