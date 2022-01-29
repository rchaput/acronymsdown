all: check build doc install

check:
	R -q -e "library(devtools); check(cran = FALSE)"

build:
	# We want to build in the current working dir, rather than the parent dir
	R -q -e "library(devtools); build(path='.')"

doc:
	R -q -e "library(devtools); document()"

install:
	R -q -e "library(devtools); install()"

tests:
	R -q -e "testthat::test_file('tests/test_rmarkdown.R', stop_on_failure = TRUE)"

site:
	R -q -e "library(pkgdown); pkgdown::build_site()"

.PHONY: tests
