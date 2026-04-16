# Obtain a pins board from EDAV

This is a convenience function to obtain a pins board in EDAV. After the
pins board is loaded, several functions from the pins package are
available to explore the board. Please see the pins package [get
started](https://pins.rstudio.com/articles/pins.html) page.

## Usage

``` r
get_edav_pins_board(
  board_loc = "GID/PEB/SIR/pins_board",
  azcontainer = get_azure_storage_connection()
)
```

## Arguments

- board_loc:

  `str` Location of the pins board in Azure.

- azcontainer:

  `azcontainer` An Azure container.

## Value

`pins board` An Azure pins board.

## Examples

``` r
if (FALSE) { # \dontrun{
edav_board <- get_edav_pins_board()
} # }
```
