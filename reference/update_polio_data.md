# Update a local dataset with new data

**\[experimental\]**

Update a local global polio data (raw.data) with new data.

## Usage

``` r
update_polio_data(local_dataset, overwrite = T)
```

## Arguments

- local_dataset:

  `str` File path to the global polio data RDS file.

- overwrite:

  `logical` Should the file be overwritten? Default `TRUE`.

## Value

None.

## Examples

``` r
if (FALSE) { # \dontrun{
local_raw_data <- "C:/Users/ABC1/Desktop/raw.data.rds"
update_polio_data(local_raw_data, overwrite = FALSE)
} # }
```
