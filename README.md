# Acronymsdown: List of Acronyms support for RMarkdown documents

> Author: rchaput <rchaput.pro@gmail.com>

![GitHub License](https://img.shields.io/github/license/rchaput/acronymsdown)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/rchaput/acronymsdown?display_name=tag&label=last%20release&logo=github&sort=semver)
![GitHub Release Date](https://img.shields.io/github/release-date/rchaput/acronymsdown?label=last%20release%20date&logo=github)
![GitHub Workflow testing Status](https://github.com/rchaput/acronymsdown/actions/workflows/testing.yml/badge.svg)
![GitHub Workflow pkgdown Status](https://img.shields.io/github/workflow/status/rchaput/acronymsdown/pkgdown?label=Documentation&logo=github)

## Description

This package adds the ability to automatically handle acronyms
inside [RMarkdown][rmarkdown] (Rmd) documents.

Throughout the document, acronyms are replaced by either their short name,
or their long name, depending on whether they appear for the first time.
They also may be linked to their corresponding definition in an automatically
generated List of Acronyms, so that readers can access the definition in one 
click.

The package documentation can be found online at 
https://rchaput.github.io/acronymsdown, or directly in your R console using
`vignette("acronymsdown")`.

## Features

- Tired of manually having to check whether the first occurrence of an
  acronym is correctly explained to your readers? **acronymsdown**
  automatically replaces acronyms, based on whether they appear for the
  first time.
- Generate a List of Acronyms based on your defined acronyms.
    + The place where this list will be generated can be specified (by
    default, at the beginning of the document).
- Automatic sorting of this list.
    + You can choose between the *alphabetical*, *usage* or *initial* order.
- Easily manage acronyms
    + Choose between multiple styles to replace acronyms.
    + By default, 1st occurrence is replaced by *long name (short name)*,
    and following occurrences are simply replaced by *short name*.
    + All occurrences can also be linked to the acronym's definition in
    the List of Acronyms.
- Define acronyms directly in your document or in external files.
- Extensive configuration
    + Most of this package's mechanisms can be configured: how to handle
    duplicate keys, whether to raise an error, print a warning or ignore an
    non-existing key, how to sort, ...
    + Sane defaults are included, such that this package can be used
    out-of-the-box.

## Installation

This package is only available on GitHub, you will therefore need to install 
`remotes` first:

```r
# Install the remotes package to install packages directly from GitHub
install.packages("remotes")
# Now, install the acronymsdown package from GitHub
remotes::install_github("rchaput/acronymsdown")
```

Alternatively, you can also use `devtools`:

```r
install.packages("devtools")
devtools::install_github("rchaput/acronymsdown")
```

Note that this package requires the `rmarkdown` package (which you should 
already have if you are writing Rmd documents).

It also requires to have at least [Pandoc][pandoc] >= "2.0", either installed 
on your system or bundled with [RStudio][rstudio].

## Usage

Using this package requires 3 simple steps:

1. Setup the custom Pandoc arguments for your document output format
  in the YAML metadata.

`pandoc_args: !expr acronymsdown::add_filter()`

2. Define your acronyms in the YAML metadata.

```yaml
---
acronyms:
  keys:
    - shortname: Rmd
      longname: RMarkdown
    - shortname: YAML
      longname: YAML Ain't Markup Language
---
```

3. And finally, use your acronyms in your Rmd document with the `\acr{<KEY>}`
special command!

`\acr{Rmd} can be used to write technical content. \acr{Rmd} uses \acr{YAML}.`

Please refer to the [Get started](https://rchaput.github.io/acronymsdown/articles/acronymsdown.html)
(`vignette("acronymsdown")`) guide for more details.

## FAQ

**Q: Are there any examples on how to use this?**

A: The [automated tests] are designed as Rmd documents which also serve as 
examples of various configurations.
Each of the sub-directories is a specific example, where the `input.Rmd` is
the source Rmd document, and `expected.md` is the expected result.

**Q: Which output formats are available?**

A: As long as it is possible to inject custom Pandoc arguments in the
output format, **acronymsdown** will work.

In particular, one can use the [bookdown] formats, with something like:
```yaml
---
output:
  bookdown::gitbook:
    pandoc_args: !expr acronymsdown::add_filter()
---
```

Of course, `bookdown::gitbook:` can be replaced by `bookdoown::pdf_book:`,
`bookdown::html_book:`, or even other formats from other packages.

**Q: Can I use this without RMarkdown?**

A: This package's features are actually implemented in a Pandoc
[Lua Filter], which means it can be used in "pure" Pandoc,
without requiring to use RMarkdown.

Please refer to `vignette("advanced_usage")` for details.

## Credits

This package was inspired from:

- an [issue on bookdown](https://github.com/rstudio/bookdown/issues/199) ;
- [a lua filter to sort a definition list](https://gist.github.com/RLesur/e81358c11031d06e40b8fef9fdfb2682) ;
- the [pagedown's insertion of a List of Figures/Tables](https://github.com/rstudio/pagedown/blob/main/inst/resources/lua/loft.lua) ;
- the [pandoc-abbreviations filter](https://github.com/dsanson/pandoc-abbreviations.lua/)


[rmarkdown]: https://rmarkdown.rstudio.com/
[pandoc]: https://pandoc.org/
[rstudio]: https://www.rstudio.com/
[bookdown]: https://bookdown.org/
[Lua Filter]: https://pandoc.org/lua-filters.html
[glossaries]: https://mirrors.chevalier.io/CTAN/macros/latex/contrib/glossaries-extra/samples/sample-abbr-styles.pdf
[automated tests]: https://github.com/rchaput/acronymsdown/tree/master/tests
[parse-acronyms.lua]: https://github.com/rchaput/acronymsdown/blob/master/inst/parse-acronyms.lua
[inst/]: https://github.com/rchaput/acronymsdown/tree/master/inst
