library(testthat)
library(acronymsdown)

# test_check("acronymsdown")

# Instead of creating a sub-directory as it is traditionally done with
# `testhat`, I prefer to implement all my tests in a single file.
testthat::test_file('test_rmarkdown.R')
