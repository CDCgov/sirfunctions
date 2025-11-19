# Interactive loading of EDAV data

**\[experimental\]**

This function is a way to interactively work with files in the EDAV
environment, which is convenient as we don't have to search for files
within Azure Storage Explorer.

## Usage

``` r
explore_edav(
  path = get_constant("DEFAULT_EDAV_FOLDER"),
  azcontainer = suppressMessages(get_azure_storage_connection())
)
```

## Arguments

- path:

  `str` Path to start at initially.

- azcontainer:

  Azure storage container provided by
  [`get_azure_storage_connection()`](https://cdcgov.github.io/sirfunctions/reference/get_azure_storage_connection.md).

## Value

`tibble` Data from the EDAV environment.

## Details

There are Excel files that may need additional formatting before it can
be read properly into an R object. For example, skipping columns or
rows. For complicated Excel files, it would be best to directly call
[`edav_io()`](https://cdcgov.github.io/sirfunctions/reference/edav_io.md)
in "read" mode, and pass additional parameters via `...`. See
[`edav_io()`](https://cdcgov.github.io/sirfunctions/reference/edav_io.md)
examples for details.

## Examples

``` r
if (FALSE) { # \dontrun{
test <- explore_edav()
} # }
```
