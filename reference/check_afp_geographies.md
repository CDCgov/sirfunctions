# Check whether the AFP geography matches those of the population dataset

**\[experimental\]**

In rare cases, the GUIDs assigned for a case may be incorrect. For
example, it may have a GUID that is incorrect for a specific year. This
function checks each AFP record for such instances.

## Usage

``` r
check_afp_geographies(afp_data, pop_data, spatial_scale, fix_afp = FALSE)
```

## Arguments

- afp_data:

  `tibble` AFP dataset

- pop_data:

  `tibble` Population dataset

- spatial_scale:

  `str` Any of the following: `"ctry", "prov", "dist`.

- fix_afp:

  `logical` Whether to update the results to show corrected GUIDs based
  on the population dataset.

## Value

`tibble` Tibble with a column used for checking accuracy.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data(attach.spatial.data = FALSE)
check_afp <- check_afp_geographies(raw_data$afp, raw_data$ctry.pop, "ctry")
} # }
```
