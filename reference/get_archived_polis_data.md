# Gets the path to the archived version of the polis folder

Obtains the path to the archived version of a polis folder within the
data folder.

## Usage

``` r
get_archived_polis_data(data_folder_path, edav, keep_n_archives = Inf)
```

## Arguments

- data_folder_path:

  `str` Path to the data folder

- edav:

  `logical` Whether to use EDAV or not.

- keep_n_archives:

  Numeric. Number of archive folders to retain. Defaults to `Inf`, which
  keeps all archives. Set to a finite number (e.g., 3) to automatically
  delete older archives beyond the N most recent.

## Value

`str` Path to the archived polis folder
