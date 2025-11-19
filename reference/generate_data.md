# Handles the logic of which files to load in the current R session

Handles the logic of which files to load in the current R session

## Usage

``` r
generate_data(
  data_path,
  data_size,
  country_name,
  dr_data_path,
  attach_spatial_data,
  .data_folder,
  .polis_folder,
  .use_edav
)
```

## Arguments

- data_path:

  path of the data folder used in the desk review

- data_size:

  `str` "small", "medium", or "large"

- country_name:

  `str` name of the country

- dr_data_path:

  `str` path to the dataset

- attach_spatial_data:

  whether to attach spatial data

- .data_folder:

  `str` Path to the data folder.

- .polis_folder:

  `str` Path to the POLIS folder.

- .use_edav:

  `logical` Whether to use EDAV or not.

## Value

`list` large list containing polio data
