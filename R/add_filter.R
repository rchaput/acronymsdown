#' Acronyms and Glossaries support in RMarkdown
#'
#' This method allows to easily register the 'parse-acronyms' Lua filter
#' in a RMarkdown document.
#' This filter is ultimately responsible for every functionality of this
#' package: loading the list of acronyms, creating the glossary in the
#' document, and linking acronyms to their definition.
#'
#' It should be used inside the YAML metadata of a RMarkdown document.
#' For example,
#' \preformatted{
#' ---
#' output:
#'     html_document:
#'     pandoc_args: !expr acronymsdown::add_filter()
#' ---
#' }
#'
#' This method is largely inspired from 'rmdfiltr'
#' (https://github.com/crsh/rmdfiltr/)
#'
#' @param error Whether to raise an error if the required version of pandoc
#' is not found
#'
#' @export
#'

add_filter <- function(error = TRUE) {

    # Lua filters require pandoc >= 2.0 ; check if it is available
    tryCatch(
        rmarkdown::pandoc_available("2.0", error = error)
        , error = function(e) stop(paste("For Lua filters,", e$message), call. = FALSE)
    )

    # Path to the Lua filter in this package
    filter_path <- system.file("parse-acronyms.lua", package = "acronymsdown")

    args <- c("--lua-filter", filter_path)

    return(args)
}
