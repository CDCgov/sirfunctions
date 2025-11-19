# Test network connection to the EDAV

Tests upload and download from EDAV by creating a temporary file of a
given size and testing the time it takes to upload and download the
file.

## Usage

``` r
test_EDAV_connection(
  azcontainer = suppressMessages(get_azure_storage_connection()),
  folder = "GID/PEB/SIR/Data",
  return_list = F,
  test_size = 1e+07
)
```

## Arguments

- azcontainer:

  Azure storage container provided by
  [`get_azure_storage_connection()`](https://cdcgov.github.io/sirfunctions/reference/get_azure_storage_connection.md).

- folder:

  `str` Location of folder in the EDAV environment that you want to
  download and upload data from.

- return_list:

  `logical` return a list of download time estimates. Defaults to
  `FALSE`.

- test_size:

  `int` byte size of a theoretical file to be uploaded or downloaded.

## Value

System message with download and update time, potentially a list.

## Examples

``` r
if (FALSE) { # \dontrun{
test_EDAV_connection()
} # }
```
