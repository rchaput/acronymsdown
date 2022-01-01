# Acronymsdown: List of Acronyms support for RMarkdown documents

> Author: rchaput <rchaput.pro@gmail.com>

## Description

This package adds the ability to automatically generate a list of acronyms
inside [RMarkdown][rmarkdown] (Rmd) documents.

Throughout the document, acronyms are replaced by either their short name,
or their long name, depending on whether they appear for the first time.
In any case, they are also linked to their corresponding definition in
the List of Acronyms, so that readers can access the definition in one click.

## Features

- Generate a List of Acronyms based on your defined terms.
    + The place where this list will be generated can be specified (by
    default, at the beginning of the document).
- Automatic sorting of this list.
    + You can choose between the *alphabetical*, *usage* or *initial* order.
- Easily manage acronyms
    + Choose between multiple styles to replace acronyms.
    + By default, 1st occurrence is replaced by *long name (short name)*,
    and following occurrences are simply replaced by *short name*.
    + All occurrences are also linked to the acronym's definition in
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

``` r
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

```yaml
---
output:
  pdf_document:
    pandoc_args: !expr acronymsdown::add_filter()
---
```

2. Define your possible acronyms in the YAML metadata.

```yaml
---
acronyms:
  keys:
    - shortname: Rmd
      longname: R Markdown
    - shortname: YAML
      longname: YAML Ain't Markup Language
---
```

3. And finally, use your acronyms in your Rmd document with the `\acr{<KEY>}`
special command! Each `\acr{<KEY>}` is parsed by **acronymsdown**, where
`<KEY>` is an acronym key (usually its short name, see more in the 
Advanced usage section).

```md
Acronymsdown enhances your \acr{Rmd} documents. \acr{Rmd} is a great tool!
```

## Advanced usage (options)

The behavior of **acronymsdown** can be customized by several options,
which can be set in the YAML metadata of your Rmd document.

See the following example for a quick overview of all available options,
which are explained after:

```yaml
---
acronyms:
  loa_title: "List of Acronyms"
  include_unused: true
  insert_beginning: true
  id_prefix: "acronyms_"
  sorting: "alphabetical"
  inexisting_keys: "warn"
  style: "long-short"
  keys:
    - shortname: RL
      longname: Reinforcement Learning
    - key: morl
      shortname: MORL
      longname: Multi-Objective Reinforcement Learning
  fromfile:
    - ./acronyms.yml
---
```

* `loa_title`: Set the title of the generated List of Acronyms. 
  By default, it is set to "List of Acronyms".
  - If `loa_title` is set to `""` (the empty string), the title is
    disabled. The List of Acronyms will still be generated, but without
    a preceding header.
* `include_unused`: Whether unused acronyms should be included in the 
  generated List. Acronyms are considered unused if they are defined in 
  the `acronyms.keys` field, but their key does not appear in a single 
  `\acr{key}` command in the document.
* `insert_beginning`: Whether to automatically insert the List of Acronyms
  at the beginning of the document. If you wish to generate this List at
  a different place, you should set this to `false`, and use the
  `\printacronyms` command in your document (where you want the List to
  be generated). Note: `\printacronyms` needs to appear exactly as-is, in
  its own paragraph, with no other text.
* `id_prefix`: Set the prefix which is used to create the acronyms' ID
  (in order to link each acronym to their definition). By default, it is set
  to `acronyms_`. This option should be used if you detect a conflict
  between **acronymsdown** and another ID in your Rmd.
* `sorting`: Controls the order in which acronyms are displayed in the
  List of Acronyms. The following values are available:
  - `alphabetical`: (default) Acronyms are sorted by their short name, in
    alphabetical order.
  - `initial`: Acronyms are sorted by the order in which they are defined
    in the YAML metadata.
  - `usage`: Acronyms are sorted in the order in which they are first used
    in the Rmd document. For example, `\acr{RL} \acr{MORL}` means that
    the *RL* acronym appears before the *MORL* one.
    *Warning*: if this sorting is used, the `include_unused` option **MUST**
    be set to `false`! Otherwise, **acronymsdown** will raise an error.
* `inexisting_keys`: Controls what to do when an acronym key is not found.
  - `warn`: (default) A descriptive warning is printed, and the acronym
    is replaced by the key.
  - `ignore`: The acronym is simply replaced by the key.
  - `error`: A descriptive error is raised, and the parsing stops.
* `on_duplicate`: Controls what to do when two acronyms with the same key
  are defined.
  - `warn`: (default) A warning is issued, and the first defined acronym is kept.
  - `replace`: The first acronym is replaced by the new one (no warning).
  - `keep`: The first acronym is kept (no warning).
  - `error`: The program raises a descriptive error, and stops.
* `fromfile`: You can define your acronyms in external files. In this case,
  set these files' path in `fromfile` to make **acronymsdown** read them.
  These files must have a similar format to this YAML metadata, and in
  particular the `acronyms.key` field. Please refer to the tests-examples
  [06](tests/06-external-yaml/) and [07](tests/07-multiple-external-yaml/) 
  for more details.
* `style`: Controls how to replace acronyms. Styles are inspired from the
  LaTeX package [glossaries]. Available options are:
  - `long-short` (default)
  - `short-long`
  - `short-footnote`

On the notion of *key*: in the previous example, notice that the *MORL* 
acronym has an additional `key` field. If explicitly set, **acronymsdown**
will use this `key` to refer to the acronyms, e.g., `\acr{morl}`.
By default, if no `key` is specified, **acronymsdown** uses the short name
itself, e.g., `\acr{RL}`.

## FAQ

**Q: Are there any examples on how to use this?**

A: The [automated tests](tests/) are designed as Rmd documents
which also serve as examples of various configurations.
Each of the sub-directories is a specific example, where the `input.Rmd` is
the source Rmd document, and `expected.md` is the expected result.

**Q: This Readme shows an example of the `pdf_document` output format,
and the tests use `md_document`, are other formats available?**

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

To do so, simply pass the additional arguments directly to Pandoc:
```sh
pandoc --lua-filter /path/to/parse-acronyms.lua input.md
```
where `/path/to/parse-acronyms.lua` is the path to the 
[parse-acronyms.lua](inst/parse-acronyms.lua) script.

If the **acronymsdown** package is installed, you can use the R method
`system.file("parse-acronyms.lua", package = "acronymsdown")` to get the
path to this file on your system.

You can also download the Lua files (in the [inst/](inst/) folder) directly, 
and store them in a convenient location on your system.
Note: you must download *all* Lua files and store them in the same folder!
Otherwise, Lua will raise an error. The "main" script, which must be loaded
by Pandoc, is `parse-acronyms.lua`.

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
