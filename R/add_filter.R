#' Acronyms and Glossaries support in RMarkdown
#'
#' This method allows to easily register the **parse-acronyms** Lua filter
#' in a *RMarkdown* document.
#' This filter is ultimately responsible for every functionality of this
#' package: loading the list of acronyms, creating the glossary in the
#' document, and linking acronyms to their definition.
#'
#' @details
#' The main purpose of this function is to be used inside the *YAML* metadata
#' of a *RMarkdown* document.
#'
#' Specifically, it should be added in the
#' `output.<format name>.pandoc_args` field, where
#' `<format name>` is the name of your desired output format,
#' e.g., `pdf_document`, `bookdown::html_book`, etc.
#'
#' If several output formats are used, `pandoc_args` should be duplicated
#' for each of the formats.
#'
#' This method is largely inspired from
#' [rmdfiltr](https://github.com/crsh/rmdfiltr/)
#'
#' @details
#' # Examples
#'
#' `pandoc_args` support several syntaxes, which are shown below.
#' Since `add_filter` returns a single string, it can be combined with
#' other arguments.
#'
#' Note that `!expr` must be used to execute the function and insert its
#' result in the *YAML*.
#'
#' To simply use `add_filter` as the sole argument:
#' \preformatted{
#' ---
#' output:
#'   html_document:
#'     pandoc_args: !expr acronymsdown::add_filter()
#' ---
#' }
#'
#' To allow using other arguments:
#' \preformatted{
#' ---
#' output:
#'   html_document:
#'     pandoc_args:
#'       - !expr acronymsdown::add_filter()
#'       - additional arguments here ...
#' ---
#' }
#'
#' With several output formats:
#' \preformatted{
#' ---
#' output:
#'   html_document:
#'     pandoc_args:
#'       - !expr acronymsdown::add_filter()
#'   bookdown::pdf_book:
#'     pandoc_args:
#'       - !expr acronymsdown::add_filter()
#' ---
#' }
#'
#' @param error Whether to raise an error if the required version of pandoc
#' is not found
#'
#' @return A string representing the pandoc argument that loads the Lua
#' filter. The string will have the following format:
#' `'--lua-filter=/path/to/parse-acronyms.lua'`.
#'
#' @export
#' @md
#'

add_filter <- function(error = TRUE) {

    # Lua filters require pandoc >= 2.0 ; check if it is available
    tryCatch(
        rmarkdown::pandoc_available("2.0", error = error)
        , error = function(e) stop(paste("For Lua filters,", e$message), call. = FALSE)
    )

    # Path to the Lua filter in this package
    filter_path <- system.file("parse-acronyms.lua", package = "acronymsdown")

    args <- paste0("--lua-filter=", filter_path)

    return(args)
}
