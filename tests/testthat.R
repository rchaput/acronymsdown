library(testthat)
library(acronymsdown)

# test_check("acronymsdown")

# Instead of creating a sub-directory as it is traditionally done with
# `testhat`, I prefer to implement all my tests in this file.

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
    )

    lines_expected <- readLines(expected_path)
    lines_out <- readLines(out_path)

    testthat::expect_identical(lines_out, lines_expected)
}


testthat::test_that("01-simple", {
    test_dir("01-simple")
})

testthat::test_that("02-custom-title", {
    test_dir("02-custom-title")
})

testthat::test_that("03-no-title", {
    test_dir("03-no-title")
})

testthat::test_that("04-replace-duplicates", {
    test_dir("04-replace-duplicates")
})

testthat::test_that("05-keep-duplicates", {
    test_dir("05-keep-duplicates")
})

testthat::test_that("06-external-yaml", {
    test_dir("06-external-yaml")
})

testthat::test_that("07-multiple-external-yaml", {
    test_dir("07-multiple-external-yaml")
})

testthat::test_that("08-style-short-long", {
    test_dir("08-style-short-long")
})

testthat::test_that("09-style-footnote", {
    test_dir("09-style-footnote")
})
