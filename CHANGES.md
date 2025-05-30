This file describes changes in the AutoDoc package.

2025.05.09
  - Add `InfoAutoDoc` info class for messages
  - Various janitorial changes

2023.06.19
  - Revise handling of chunks XML file
  - Remove `AUTODOC_AbsolutePath`
  - Don't build PDF docs if `NOPDF` environment variable is set
  - Various janitorial changes

2022.10.20
  - Prevent some file descriptor leaks
  - Do not try to read non-existing file `gap/ContextObject.gd`

2022.07.10
  - Output all entities defined via either the `scaffold.entities` option
    to AutoDoc  (or equivalently via the `AutoDoc.entities` record in
    `PackageInfo.g`) into a file `_entities.xml`, so that they can also
    be used with a hand-made main XML file (and not just when AutoDoc
    generated the main page)
  - Remove `&see;` entity from the default list of entities

2022.03.10
  - Strip trailing newlines in `PostalAddress` and some TitlePage elements
  - Allow AutoDoc record in `PackageInfo.g` to not contain a TitlePage entry

2022.02.24
  - true/false are keywords, not just code: use K tags
  - extract examples: do not flush pkgname.tst
  - remove duplicate entries in autodoc.files

2020.08.11
  - Add support for using the string `]]>` in examples
  - Add support for `DeclareGlobalName` (new in GAP 4.12)
  - Add `extract_examples.skip_empty_in_numbering` option
  - Enhance `extract_examples` to remove outdated .tst files (e.g. if chapter
    number changes, we won't leave outdated extracted .tst examples behind)
  - Fix a warning about a missing file `/doc/_Chunks.xml` which appeared
    when building the documentation of some packages

2019.09.04
  - Deprecate `@BeginAutoDoc` and `@EndAutoDoc`; they will be removed in a future
    AutoDoc version
  - Deprecate `@BeginAutoDocPlainText` and `@EndAutoDocPlainText`; they will be
    removed in a future AutoDoc version
  - Fix `@BeginCode` / `@EndCode` / `@InsertCode`, which were broken in version 2019.07.03

2019.07.24
  - Add support for ISO 8601 dates in package metadata (to prepare for GAP adding
    official support for this in the future)
  - Remove undocumented and long-unused support entities specified using a raw
    `<!ENTITY NAME CONTENT>` entity string
  - Fix the `&see;` entity we always generate (for legacy support) to display
    the correct output in LaTeX / PDF mode
  - Fix support for chunks with names / labels that contain spaces (GAPDoc does
    not like these, so we replace the spaces by underscores)

2019.07.17
  - Fix bug in `extract_examples` option that could result in invalid .tst files

2019.07.03
  - Make Chunks compatible with GAPDoc chunks
  - Tweak two error messages, add two more error checks
  - Check that gapdoc.files is a list of strings
  - Add `@GroupTitle` command (thanks to Glen Whitney)
  - Make @Begin.../@EndExampleSession respect plain_text_mode (thanks to Glen Whitney)
  - Handle documentation of DeclareCategoryCollection declarations (thanks to Glen Whitney)
  - Repair minor omissions/imprecisions in AutoDoc() function doc (thanks to Glen Whitney)
  - Improve manual further

2019.05.20
  - Ensure that starting a "manpage" (= documentation for a filter, function, property,
    ...) ends any active subsection (in GAPDoc, manpages are equivalent to subsections
    internally, and hence cannot be nested in each other)
  - Add deprecation warnings for @InsertSystem, @System, @BeginSystem, @EndSystem
    (use @Chunk etc. instead), and also @EndSection, @EndSubsection
  - Rename scaffold.gapdoc_latex_options to gapdoc.LaTeXOptions. The old name is still
    supported, but triggers a deprecation warning.
  - Update copyright information and author's contact data
  - Minor fixes in the manual

2019.04.10
  - Add opt.extract_examples to AutoDoc function
  - Add @NotLatex command to complement @LatexOnly
  - Allow disabling title page creation, by teaching `AutoDoc()` to correctly
    handle `scaffold := rec( TitlePage := false )` instead of raising an error
  - When generating a manual title page, only include persons as authors
    for which IsAuthor is set to true in PackageInfo.g
  - Some improvements to the manual
  - Various internal changes

2019.02.22
  - Updated changes file

2019.02.21
  - Removed possibility to mark function arguments via curly braces, as {A},
    as it caused problems with writing {} in math mode.

2019.02.20
  - Accept single backticks to indicate inline code spans
  - Added possibility to mark function arguments via curly braces, as {A}

2018.09.20
  - Scan bracket `\[\]` declarations correctly (PR #162)
  - Removed the hardcoded utf8 option, make it overridable via gapdoc_latex_option
  - Allow AutoDoc() to take absolute dirs and run from any dir (thanks to Glen Whitney)
  - Add a test suite for AutoDoc (thanks to Glen Whitney)
  - Fix documenting DeclareInfoClass

2018.02.14
  - Added @*Title commands to specify titles for Chapters etc.
  - Document @BeginExampleSession instead of @ExampleSession
  - Document the aliases @Example, @ExampleSession, @Log, and @LogSession
  - Improve manual (thanks to Chris Wensley):
    - fix a few typos
    - added abstract and acknowledgments
    - added bibliography file AutoDoc.bib
    - added checklist subsection 1.3.3
    - added some index entries
    - change makedoc.g to highlight some useful features of the AutoDoc() function
  - Various other tweaks and fixes

2017.09.08
  - Add ChapterLabel, SectionLabel, and SubsectionLabel
  - Add ExampleSession environment to support GAPDoc-Style examples
  - Add support for documenting DeclareConstructor
  - Empty lines in AutoDoc comments start a new paragraph, as in TeX
  - Improve @Example documentation
  - Fix some spelling mistakes in the manual
  - Fix support for KeyDependendOperations (see issue #124)
  - Don't show a return value if no @Returns is given
  - Various other tweaks and fixes

2016.12.04:
  - Revise and officially document the `entities` option for AutoDoc()

2016.11.26:
  - Use english month names on title pages
  - Ignore empty dependency lists in PackageInfo.g files
  - Better error message when .six file is not available

2016.03.08:
  - Fix the "empty index" workaround from the previous release

2016.03.04:
  - Improved the manual.
  - AutoDoc can now be instructed to invoke GAPDoc in such a way that links
    in the generated documentation to the GAP reference manual use relative
    paths.
  - Also scan for .autodoc files (Issue #104)
  - Workaround a problem with GAPDoc where an empty index could lead to an error.
  - Allow entities in chapter and section titles.
  - Fix a bug where the indentation for code blocks was not preserved.

2016.02.24:
  - Again improved the error messages produced by the parser.
  - Document worksheets (and fix them -- the previous release broke them).
  - Removed the @URL documentation comment command.
  - Add current directory to default list of directories which are scanned
    for *.{g,gi,gd} files containing documentation.
  - Fixed various typos and other mistakes in the documentation.
  - Make it possible to tell AutoDoc to build manuals with relative paths
    (issue #103).

2016.02.16:
  - AutoDoc does not anymore produce an error when invoked on a new project
    which has no documentation yet (issue #65)
  - Various errors in the parser now produce much better error messages,
    with information in which file and line the error occurred, and what
    the error is (issue #89)
  - Files generated by AutoDoc for chapters as well as the "main" file
    now have names starting with an underscore, to make it easy to
    distinguish generated files from those maintained by hand.
  - Removed the old "Declare*WithDoc" API. Any packages still using it
    must upgrade to use documentation comments.

2016.01.31:
  - Improved the documentation of AutoDoc itself
  - Some code is now more robust, detects more error conditions and reports
    them clearly to the user, instead of triggering some weird error later on.
  - Lots of minor tweaks, fixes and cleanip

2016-01-21:
  - The AutoDoc() function now accepts IsDirectory() objects
    as first argument, and you can omit the first argument
    (it then defaults to the current directory).
    Packages using AutoDoc may want to adapt their makedoc.g
    to use this new facility for improved robustness.
