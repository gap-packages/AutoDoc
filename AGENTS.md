# AGENTS.md

This repository contains the GAP package `AutoDoc`.

## AI disclosure

Any use of AI tools for preparing code, documentation, tests, commit messages,
pull requests, issue comments, or reviews for this repository must be
disclosed. Include a brief note saying which AI tool was used and what kind of
assistance it provided. Add the AI tool as a Git co-author on all commits
created by that tool (e.g. via an `Co-authored-by: ` line).

## Repository layout

- `PackageInfo.g`: package metadata, including the current version and manual
  settings.
- `Makefile`: convenience targets for building docs, regenerating fixtures,
  and running the test suite.
- `makedoc.g`: entry point for rebuilding the manual.
- `regen_tests.g`: entry point for regenerating test data.
- `tst/`: package test suite. Run `tst/testall.g` for the full suite, or a
  single `.tst` file for one test.
- `tst/AutoDocTest/`: minimal GAP package used as a package-context AutoDoc
  testbed, with its own `Makefile` for common doc and test commands.
- `README.md`: top-level package overview.

## Common commands

Run all commands from the repository root.

### Build the manual

```sh
make doc
```

### Build the HTML manual only

```sh
make html
```

### Run all tests

```sh
make check
```

### Run one test

```sh
gap -q --packagedirs . tst/misc.tst
```

Replace `tst/misc.tst` with any other test file in `tst/` as needed.

### Regenerate the tests

```sh
make regen
```

### Work with `tst/AutoDocTest`

Run these commands from inside `tst/AutoDocTest`:

```sh
make doc
make html
make check
```

## Tests

All new features and bug fixes should be accompanied by tests. We have the
following test locations:
- worksheets `tst/worksheets/*.sheet` which serve as integration tests
  - some existing fixtures come in pairs, one using XML and one using an
    `.autodoc` file; if editing one side of an existing `paired-*` fixture
    (e.g. `paired-examples.sheet`) then usually its partner (here:
    `paired-examples-autoplain.sheet`) should receive a matching change,
    unless this is impossible for fundamental reasons (e.g. a feature only
    exists in one format but not the other),
  - worksheet tests compare expected output files byte-for-byte, so changes to
    worksheet input usually also require updating
    `tst/worksheets/<name>.expected/`,
- the manual of the `tst/AutoDocTest` package, including its sources in
  `tst/AutoDocTest/doc/` as well as the GAP program files with AutoDoc
  comments inside `tst/AutoDocTest/gap`, also can be used to test features,
  especially features that don't work well in a worksheet or for other reasons
  require the context of an actual package.
- unit tests in `tst/*.tst` files (often in `tst/misc.tst`, but additional files
  can be added if needed / sensible)

In general prefer integration tests that modify one of the worksheets or
package manuals for end-to-end behavior. Regenerate expected output with
`make regen` when appropriate.

If specifically unit tests are needed for individual functions, these can and
should go into a `.tst` file. Temporary test files created from a `.tst` file
are acceptable when that is the most direct way to exercise unit-level parser
or helper behavior.

## Commit messages and pull requests

When writing commit messages, use the title format `component: Brief summary`
The title line should not exceed 60 characters.

In the body, give a brief prose summary of the purpose of the change. Do not
specifically call out added tests, comments, documentation, and similar
supporting edits unless that is the main purpose of the change. Do not include
the test plan unless it differs from the instructions in this file. If the
change fixes one or more issues, add `Fixes #...` at the end of the commit
message body, not in the title.

Don't write lines into the commit message that are wider than 70 characters.

Pull requests should follow the same style: a short summary up top, concise
prose describing the change, issue references when applicable, and an explicit
AI-disclosure note if AI tools were used.


## Changelog

This project keeps a changelog in `CHANGES.md`. Typically new features and
bug fixes should get a terse entry there. Changes which only refactor things,
change formatting, clean up stuff etc. usually do not have to be mentioned.
