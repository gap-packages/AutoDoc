#
# AutoDocTest: A minimal GAP package for testing AutoDoc features
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "AutoDocTest",
Subtitle := "A minimal GAP package for testing AutoDoc features",
Version := "0.1",
Date := "11/03/2026", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Active",
    LastName := "Author",
    WWWHome := "https://AutoDocTest.gap-system.org/~author",
    Email := "a.author@AutoDocTest.gap-system.org",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := false,
    FirstNames := "Retired",
    LastName := "Author",
    Email := "r.author@AutoDocTest.gap-system.org",
  ),
  rec(
    IsAuthor := false,
    IsMaintainer := true,
    FirstNames := "Only",
    LastName := "Maintainer",
    WWWHome := "https://AutoDocTest.gap-system.org/~maintainer",
  ),
  rec(
    IsAuthor := false,
    IsMaintainer := false,
    FirstNames := "Some",
    LastName := "Contributor",
  ),
],

#SourceRepository := rec( Type := "TODO", URL := "URL" ),
#IssueTrackerURL := "TODO",
#SupportEmail := "TODO",

PackageWWWHome := "https://AutoDocTest.gap-system.org/",

PackageInfoURL := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL     := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL     := Concatenation( ~.PackageWWWHome,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "AutoDocTest",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A minimal GAP package for testing AutoDoc features",
),

Dependencies := rec(
  GAP := ">= 4.9",
  NeededOtherPackages := [ ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

));
