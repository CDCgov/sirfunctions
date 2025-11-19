# Helper function to read and write key data to the EDAV environment

The function serves as the primary way to interact with the EDAV system
from R. It can read, write, create folders, check whether a file or a
folder exists, upload files, and list all files in a folder.

## Usage

``` r
edav_io(
  io,
  default_dir = "GID/PEB/SIR",
  file_loc = NULL,
  obj = NULL,
  azcontainer = suppressMessages(get_azure_storage_connection()),
  force_delete = F,
  local_path = NULL,
  ...
)
```

## Arguments

- io:

  `str` The type of operation to perform in EDAV.

  - `"read"` Read a file from EDAV, must be an rds, csv, rda, or
    xls/xlsx file.

  - `"write"` Write a file to EDAV, must be an rds, csv, rda, or
    xls/xlsx file. To write an Excel file with multiple sheets, pass a
    named list containing the tibbles of interest. See examples.

  - `"exists.dir"` Returns a boolean after checking to see if a folder
    exists.

  - `"exists.file"`Returns a boolean after checking to see if a file
    exists.

  - `"create"` Creates a folder and all preceding folders.

  - `"list"` Returns a tibble with all objects in a folder.

  - `"upload"` Moves a file of any type to EDAV.

  - `"delete"` Deletes a file.

  - `"delete.dir"` Deletes a folder.

- default_dir:

  `str` The default directory in EDAV. `"GID/PEB/SIR"` is the default
  directory for all SIR data in EDAV. Can be set to `NULL` if you
  provide the full directory path in `file_loc`.

- file_loc:

  `str` Location to "read", "write", "exists.dir", "exists.file",
  "create" or "list", can include the information in `default_dir` if
  you set that parameter to `NULL`.

- obj:

  `robj` Object to be saved, needed for `"write"`. Defaults to `NULL`.

- azcontainer:

  Azure container object returned from
  [`get_azure_storage_connection()`](https://cdcgov.github.io/sirfunctions/reference/get_azure_storage_connection.md).

- force_delete:

  `logical` Use delete io without verification in the command line.

- local_path:

  `str` Local file pathway to upload a file to EDAV. Default is `NULL`.
  This parameter is only required when passing `"upload"` in the `io`
  parameter.

- ...:

  Optional parameters that work with
  [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)
  or
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

## Value

Output dependent on argument passed in the `io` parameter.

## Examples

``` r
if (FALSE) { # \dontrun{
df <- edav_io("read", file_loc = "df1.csv") # read file from EDAV
# Passing parameters that work with read_csv or read_excel, like sheet or skip.
df2 <- edav_io("read", file_loc = "df2.xlsx", sheet = 1, skip = 2)
list_of_df <- list(df_1 = df, df_2 = df)
# Saves df to the test folder in EDAV
edav_io("write", file_loc = "Data/test/df.csv", obj = df)
# Saves list_of_df as an Excel file with multiple sheets.
edav_io("write", file_loc = "Data/test/df.xlsx", obj = list_of_df)
edav_io("exists.dir", "Data/nonexistentfolder") # returns FALSE
edav_io("exists.file", file_loc = "Data/test/df1.csv") # returns TRUE
edav_io("create", "Data/nonexistentfolder") # creates a folder called nonexistentfolder
edav_io("list") # list all files from the default directory
edav_io("upload", file_loc = "Data/test", local_path = "C:/Users/ABC1/Desktop/df2.csv")
} # }
```
