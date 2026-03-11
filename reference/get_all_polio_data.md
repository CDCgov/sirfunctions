# Retrieve all pre-processed polio data

Download POLIS data from the CDC pre-processed endpoint. By default this
function will return a "small" or recent dataset. This is primarily for
data that is from the past six years. You can specify a "medium" sized
dataset for data that is from the past nine years. Finally the "large"
sized dataset will provide information from 2000 onwards. Regular pulls
form the data will recreate the "small" dataset when new information is
available and the Data Management Team can force the creation of the
"medium" and "large" static datasets as necessary.

## Usage

``` r
get_all_polio_data(
  size = "small",
  data_folder = "GID/PEB/SIR/Data",
  polis_folder = "GID/PEB/SIR/POLIS",
  core_ready_folder = "Core_Ready_Files",
  force.new.run = FALSE,
  recreate.static.files = FALSE,
  attach.spatial.data = TRUE,
  use_edav = TRUE,
  use_archived_data = FALSE,
  archive = TRUE,
  keep_n_archives = Inf,
  output_format = "rds",
  local_caching = TRUE
)
```

## Arguments

- size:

  `str` Size of data to download. Defaults to `"small"`.

  - `"small"`: Data from the last six years.

  - `"medium"`: Data from the last nine years.

  - `"large"`: Data from 2000-present.

- data_folder:

  `str` Location of the data folder containing pre-processed POLIS data,
  spatial files, coverage data, and population data. Defaults to
  `"GID/PEB/SIR/Data"`.

- polis_folder:

  `str` Location of the POLIS folder. Defaults to `"GID/PEB/SIR/POLIS"`.

- core_ready_folder:

  `str` Which core ready folder to use. Defaults to
  `"Core_Ready_Files"`.

- force.new.run:

  `logical` Default `FALSE`, if `TRUE` will run recent data and cache.

- recreate.static.files:

  `logical` Default `FALSE`, if `TRUE` will run all data and cache.

- attach.spatial.data:

  `logical` Default `TRUE`, adds spatial data to downloaded object.

- use_edav:

  `logical` Build raw data list using EDAV files. Defaults to `TRUE`.

- use_archived_data:

  `logical` Allows the ability to recreate the raw data file using
  previous preprocessed data. If

- archive:

  Logical. Whether to archive previous output directories before
  overwriting. Default is `TRUE`.

- keep_n_archives:

  Numeric. Number of archive folders to retain. Defaults to `Inf`, which
  keeps all archives. Set to a finite number (e.g., 3) to automatically
  delete older archives beyond the N most recent.

- output_format:

  str: output_format to save files as. Available formats include 'rds'
  and 'qs2'. Defaults is 'rds'.

- local_caching:

  `logical` Enable local caching so data is stored locally and only
  downloaded when there is updated data from EDAV.

## Value

Named `list` containing polio data that is relevant to CDC.

## Examples

``` r
if (FALSE) { # \dontrun{
raw.data <- get_all_polio_data() # downloads data for last 6 years, including spatial files
raw.data <- get_all_polio_data(size = "small", attach.spatial.data = FALSE) # exclude spatial data
} # }
```
