# Creates polis folder to the data folder

Copies the updated POLIS data into the data folder. This function is
used inside get_all_polio_data().

## Usage

``` r
create_polis_data_folder(
  data_folder,
  polis_folder,
  core_ready_folder,
  use_edav,
  archive = TRUE,
  keep_n_archives = Inf
)
```

## Arguments

- data_folder:

  `str` Path to the data folder.

- polis_folder:

  `str` Path to the core ready folder

- core_ready_folder:

  `str` Which core ready folder to use. Defaults to
  `"Core_Ready_Files"`.

- use_edav:

  `logical` Are file paths on EDAV?

- archive:

  Logical. Whether to archive previous output directories before
  overwriting. Default is `TRUE`.

- keep_n_archives:

  Numeric. Number of archive folders to retain. Defaults to `Inf`, which
  keeps all archives. Set to a finite number (e.g., 3) to automatically
  delete older archives beyond the N most recent.
