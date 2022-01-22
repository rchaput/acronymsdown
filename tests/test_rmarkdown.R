library(testthat)
library(rmarkdown)
library(acronymsdown)

# Each sub-directory in this `tests` directory contains an example
# of a Rmd document (`input.Rmd`), and an expected output (`expected.md`).
# For each of these directories, we test in this file that the rendered
# output, using `rmarkdown::render` and our `acronymsdown` package,
# actually corresponds to the expected file.

# Load our custom shared library to be able to redirect errors.
# If the lib isn't available, simply disable the "error-catching" behaviour.
lib_path <- paste0("../dup2_helper", .Platform$dynlib.ext)
dup2_available <- FALSE
if (file.exists(lib_path)) {
  tryCatch({
    dyn.load(lib_path)
    dup2_available <- TRUE
  })
}

# This function is used to wrap a block of code with redirection of stderr.
with_capture <- function(error_path, code) {
    # We name the last argument to retrieve it easily.
    # The value (0) is a simple placeholder.
    res <- .C("begin_dup2",
              as.character(error_path),
              stderr_result = as.integer(0))
    stderr_result <- res[['stderr_result']]
    eval(code)
    .C("end_dup2", as.integer(stderr_result))
    invisible(NULL)
}

# This function returns elements that are missing from expected, and
# the `remaining`, i.e., additional elements not in expected.
missing_and_remaining <- function(actual, expected) {
  missing <- c()
  for (elem in expected) {
    index <- match(elem, actual)
    if (is.na(index)) {
      # This (expected) error is missing from the captured messages
      missing <- c(missing, elem)
    } else {
      # Remove this (single) captured error. This avoids problems with
      # duplicates (e.g., if we have 2 times the same expected error,
      # we want to make sure we captured it twice as well).
      actual <- actual[- index]
    }
  }
  # Return missing and remaining elements.
  # missing = those in expected but not in actual
  # remaining = those in actual but not in expected
  return(c(missing = missing, remaining = actual))
}

# Helper function which tests that a single directory works correctly.
test_dir <- function(dirname) {

  out_path <- tempfile(dirname, fileext = ".md")
  err_path <- tempfile(dirname, fileext = ".stderr")
  input_path <- file.path(getwd(), dirname, "input.Rmd")
  expected_out_path <- file.path(getwd(), dirname, "expected.md")
  expected_err_path <- file.path(getwd(), dirname, "expected.stderr")

  if (dup2_available) {
    with_capture(err_path, {
      rmarkdown::render(input_path,
                        output_file = out_path,
                        quiet = TRUE,
          )
      })
  } else {
    rmarkdown::render(input_path,
                      output_file = out_path,
                      quiet = TRUE,
    )
  }

  lines_expected <- readLines(expected_out_path)
  lines_out <- readLines(out_path)
  testthat::expect_identical(lines_out, lines_expected)

  if (dup2_available) {
    lines_err <- readLines(err_path)
    lines_err_expected <- if (file.exists(expected_err_path)) readLines(expected_err_path)
                          else c()
    res <- missing_and_remaining(lines_err, lines_err_expected)
    missing <- res['missing']
    remaining <- res['remaining']

    # At this point, if there are any elements in `missing`, we need to raise
    # an error: we expected but did not capture them.
    if (!is.na(missing)) {
        message <- paste(c("The following messages were expected but not captured:",
                           missing), collapse = '\n')
        testthat::fail(message)
    }

    # If there are any remaining elements in `lines_err`, we should emit a
    # warning: we did not expect them, but maybe they are not an error.
    if (!is.na(remaining)) {
      warning(paste(c("The following messages were captured but not expected:",
                      remaining), collapse = "\n"))
    }
  }
}

folders <- c(
  "01-simple",
  "02-custom-title",
  "03-no-title",
  "04-replace-duplicates",
  "05-keep-duplicates",
  "06-external-yaml",
  "07-multiple-external-yaml",
  "08-style-short-long",
  "09-style-footnote",
  "10-no-links",
  "11-missing-key",
  "12-missing-unknown",
  "13-insert-loa-end",
  "14-insert-loa-false",
  "15-insert-loa-false-printacronyms",
  "16-not-include-unused",
  "17-sorting-alphabetical",
  "18-sorting-initial",
  "19-sorting-usage"
)

for (folder in folders) {
  # The first argument is the test's name (which is set to the folder's
  # name for readability).
  testthat::test_that(folder, {
    test_dir(folder)
  })
}
