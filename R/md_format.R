#' Sample output format for Acronymsdown documents
#'
#' Format for converting R Markdown documents to (pandoc) markdown documents.
#' This format is primarily used for testing purposes.
#'
#' @param ... Additional arguments, which will be passed to the base
#' [rmarkdown::md_document()] format.
#'
#' @return A rmarkdown output format, which can be used in
#' [rmarkdown::render()].
#'
#' @details
#' This output format was meant for testing the Acronymsdown package.
#' You may use it in your documents, but be warned that there are some
#' opinionated choices. In particular, this format:
#' - ensures that headings use the ATX syntax (e.g., `# Title`, `## Subtitle`) ;
#' - preserves line wrappings ;
#' - forces the pandoc variant of *markdown* (instead of the default,
#'   strict markdown) ;
#' - includes the *acronymsdown* Lua Filter.
#'
#' These choices make sense in order to facilitate the automated testing
#' of Acronymsdown, by ensuring a reliable (and reproducible) result,
#' even for older versions of pandoc.
#'
#' @export
#' @md
#'

md_format <- function (...) {
  if (rmarkdown::pandoc_version() >= "2.11.2")
    args <- "--markdown-headings=atx"
  else
    args <- "--atx-headers"
  args <- c(args, "--wrap=preserve")
  rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(),
    pandoc = rmarkdown::pandoc_options(to = "markdown", args = args,
                                       lua_filters = path_to_filter()),
    base_format = rmarkdown::md_document(variant = "markdown", ...)
  )
}
