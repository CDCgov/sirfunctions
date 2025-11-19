# sirfunctions i/o handler

**\[experimental\]**

Manages read/write/list/create/delete functions for sirfunctions. This
function is adapted from
[tidypolis_io](https://github.com/nish-kishore/tidypolis/blob/4e2f75e5ee3205b84c5b78f4b1776e2270e1f9ec/R/dal.R#L15).

## Usage

``` r
sirfunctions_io(
  io,
  default_folder = "GID/PEB/SIR",
  file_loc,
  obj = NULL,
  edav = TRUE,
  azcontainer = suppressMessages(sirfunctions::get_azure_storage_connection()),
  full_names = T,
  ...
)
```

## Arguments

- io:

  `str` The type of operation to use. Valid values include:

  - `"read"`: reads data from the specified `file_path`.

  - `"write"`: writes data to the specified `file_path`.

  - `"list"`: lists the files in the specified `file_path`.

  - `"exists.dir"`: determines whether a directory is present.

  - `"exists.file"`: determines whether a file is present.

  - `"create.dir"`: creates a directory to the specified `file_path`.

  - `"delete"`: deletes a file in the specified `file_path`.

  - `"delete.dir"`: deletes a folder in the specified `file_path.`

- default_folder:

  `str` The default folder to use. Defaults to `"GID/PEB/SIR`.

- file_loc:

  `str` Path of file relative to the `default_folder`.

- obj:

  `str` Object to be loaded into EDAV

- edav:

  `logical` Whether the function should interact with the EDAV
  environment. Defaults to `TRUE`, otherwise, interacts with files
  locally.

- azcontainer:

  `Azure container` A container object returned by
  [`get_azure_storage_connection()`](https://cdcgov.github.io/sirfunctions/reference/get_azure_storage_connection.md).

- full_names:

  `logical` If `io="list"`, include the full reference path. Default
  `TRUE`.

- ...:

  Optional parameters that work with
  [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)
  or
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

## Value

Conditional on `io`. If `io` is `"read"`, then it will return a tibble.
If `io` is `"list"`, it will return a list of file names. Otherwise, the
function will return `NULL`. `exists.dir` and `exists.file` will return
a `logical`.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- sirfunctions_io("read", file_loc = "df1.csv") # read file from EDAV
# Passing parameters that work with read_csv or read_excel, like sheet or skip.
df2 <- sirfunctions_io("read", file_loc = "df2.xlsx", sheet = 1, skip = 2)
list_of_df <- list(df_1 = df, df_2 = df)
# Saves df to the test folder in EDAV
sirfunctions_io("write", file_loc = "Data/test/df.csv", obj = df)
# Saves list_of_df as an Excel file with multiple sheets.
sirfunctions_io("write", file_loc = "Data/test/df.xlsx", obj = list_of_df)
sirfunctions_io("exists.dir", "Data/nonexistentfolder") # returns FALSE
sirfunctions_io("exists.file", file_loc = "Data/test/df1.csv") # returns TRUE
sirfunctions_io("create", "Data/nonexistentfolder") # creates a folder called nonexistentfolder
sirfunctions_io("list") # list all files from the default directory
} # }
```
