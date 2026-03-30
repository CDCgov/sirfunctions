
#' Clear local polio data cache
#'
#' @description
#' The local polio cache is created when `get_all_polio_data()` is called with
#' `local_caching = TRUE`. The function clears the cache by deleting all the files within it.
#'
#' @returns `NULL`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' clear_local_polio_data_cache()
#' }
clear_local_polio_data_cache <- function() {

  cache <- rappdirs::user_data_dir("sirfunctions")
  # Check if the cache exists
  if (!dir.exists(cache)) {
    cli::cli_alert_info("No local cache to clear")
    return(invisible())
  }

  files <- list.files(cache, full.names = TRUE)

  if (length(files) > 0) {
    purrr::walk(files, \(x) file.remove(x))
    cli::cli_alert_success("Local polio data cache cleared")
  } else {
    cli::cli_alert_info("Polio data cache already cleared")
  }

  return(invisible())
}
