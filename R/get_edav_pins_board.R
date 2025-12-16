#' Obtain a pins board from EDAV
#'
#' @description
#' This is a convenience function to obtain a pins board in EDAV. After the pins
#' board is loaded, several functions from the pins package are available to explore
#' the board. Please see the pins package [get started](https://pins.rstudio.com/articles/pins.html) page.
#'
#' @param board_loc `str` Location of the pins board in Azure.
#' @param azcontainer `azcontainer` An Azure container.
#'
#' @returns `pins board` An Azure pins board.
#' @export
#'
#' @examples
#' \dontrun{
#' edav_board <- get_edav_pins_board()
#' }
get_edav_pins_board <- function(board_loc = "GID/PEB/SIR/pins_board",
                                azcontainer = get_azure_storage_connection()) {

  azboard <- pins::board_azure(azcontainer, board_loc)

  return(azboard)
}
