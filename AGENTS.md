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
- `makedoc.g`: entry point for rebuilding the manual.
- `regen_tests.g`: entry point for regenerating test data.
- `tst/`: package test suite. Run `tst/testall.g` for the full suite, or a
  single `.tst` file for one test.
- `tst/AutoDocTest/`: minimal GAP package used as a package-context AutoDoc
  testbed.
- `README.md`: top-level package overview.

## Common commands

Run all commands from the repository root.

### Build the manual

```sh
gap -q --packagedirs . makedoc.g
```

### Run all tests

```sh
gap -q --packagedirs . tst/testall.g
```

### Run one test

```sh
gap -q --packagedirs . tst/misc.tst
```

Replace `tst/misc.tst` with any other test file in `tst/` as needed.

### Regenerate the tests

```sh
gap -q --packagedirs . regen_tests.g
```

### Work with `tst/AutoDocTest`

Run these commands from inside `tst/AutoDocTest`:

```sh
gap -q --packagedirs . makedoc.g
gap -q --packagedirs . tst/testall.g
```

## Commit messages and pull requests

When writing commit messages, use the title format `component: Brief summary`.
In the body, give a brief prose summary of the purpose of the change. Do not
specifically call out added tests, comments, documentation, and similar
supporting edits unless that is the main purpose of the change. Do not include
the test plan unless it differs from the instructions in this file. If the
change fixes one or more issues, add `Fixes #...` at the end of the commit
message body, not in the title.

Pull requests should follow the same style: a short summary up top, concise
prose describing the change, issue references when applicable, and an explicit
AI-disclosure note if AI tools were used.


## Changelog

This project keeps a changelog in `CHANGES.md`. Typically new features and
bug fixes should get a terse entry there. Changes which only refactor things,
change formatting, clean up stuff etc. usually do not have to be mentioned.
