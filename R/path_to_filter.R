#' Path to the Lua Filter
#'
#' This method returns the path to the *parse-acronyms.lua* Lua Filter
#' inside the **acronymsdown** package.
#'
#' @details
#' The main purpose of this function is to be used either internally by
#' **acronymsdown** to register this Lua Filter with Pandoc, or by external
#' custom output formats, so that they can integrate the Lua Filter by
#' default.
#'
#' In the 2nd case, this function's result must be concatenated to the
#' `lua_filters` attribute of the base format.
#'
#' For example,
#' \preformatted{
#' custom_format <- function(...) {
#'   base_format <- rmarkdown::html_document(...)
#'   # prepending a new Lua filter to html_document() ones
#'   base_format$pandoc$lua_filters <- c(
#'     acronymsdown::path_to_filter(),
#'     base_format$pandoc$lua_filters
#'   )
#'   base_format
#' }
#' }
#'
#'
#' @return A string representing the path to the Lua filter. The string
#' will have the following format: `'/path/to/parse-acronyms.lua'`.
#'
#' @export
#' @md
#'

path_to_filter <- function() {
  system.file("parse-acronyms.lua", package = "acronymsdown")
}

