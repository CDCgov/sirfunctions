# Pull new data and write to the specified file path

Pull new data and write to the specified file path

## Usage

``` r
update_data(
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

- data_size:

  `str` size of polio data to pull. "small" (\>= 2019), "medium" (\>=
  2016), large" (full)

- country_name:

  `str` name of the country to pull data from

- dr_data_path:

  `str` path to save the data set to. Expected path is
  ./country/year/data

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
