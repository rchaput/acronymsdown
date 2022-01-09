library(testthat)
library(rmarkdown)
library(acronymsdown)

# Each sub-directory in this `tests` directory contains an example
# of a Rmd document (`input.Rmd`), and an expected output (`expected.md`).
# For each of these directories, we test in this file that the rendered
# output, using `rmarkdown::render` and our `acronymsdown` package,
# actually corresponds to the expected file.

# Helper function which tests that a single directory works correctly.
test_dir <- function(dirname) {

  out_path <- tempfile(dirname, fileext = ".md")
  input_path <- file.path(getwd(), dirname, "input.Rmd")
  expected_path <- file.path(getwd(), dirname, "expected.md")

  rmarkdown::render(input_path,
                    output_file = out_path,
                    quiet = TRUE,
  )

  lines_expected <- readLines(expected_path)
  lines_out <- readLines(out_path)

  testthat::expect_identical(lines_out, lines_expected)
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
  "12-missing-??"
)

for (folder in folders) {
  # The first argument is the test's name (which is set to the folder's
  # name for readability).
  testthat::test_that(folder, {
    test_dir(folder)
  })
}
