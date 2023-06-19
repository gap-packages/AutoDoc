# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later


SetPackageInfo( rec(

PackageName := "AutoDoc",
Subtitle := "Generate documentation from GAP source code",
Version := "2023.06.19",

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( ~.Date{[ 9, 10 ]}, "/", ~.Date{[ 6, 7 ]}, "/", ~.Date{[ 1 .. 4 ]} ),
License := "GPL-2.0-or-later",

Persons := [
  rec(
    LastName      := "Gutsche",
    FirstNames    := "Sebastian",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "gutsche@mathematik.uni-siegen.de",
    WWWHome       := "https://algebra.mathematik.uni-siegen.de/gutsche/",
       PostalAddress := Concatenation(
               "Department Mathematik\n",
               "Universität Siegen\n",
               "Walter-Flex-Straße 3\n",
               "57072 Siegen\n",
               "Germany" ),
       Place := "Siegen",
       Institution := "Universität Siegen"
  ),

  rec( LastName := "Horn",
       FirstNames := "Max",
       IsAuthor := true,
       IsMaintainer := true,
       Email := "mhorn@rptu.de",
       WWWHome       := "https://www.quendi.de/math",
       PostalAddress := Concatenation(
               "Fachbereich Mathematik\n",
               "RPTU Kaiserslautern-Landau\n",
               "Gottlieb-Daimler-Straße 48\n",
               "67663 Kaiserslautern\n",
               "Germany" ),
       Place         := "Kaiserslautern, Germany",
       Institution   := "RPTU Kaiserslautern-Landau"
     ),

  # Contributors:
  rec( LastName := "Barakat",
       FirstNames := "Mohamed",
       IsAuthor := false,
       IsMaintainer := false,
     ),

  rec( LastName := "Pfeiffer",
       FirstNames := "Markus",
       IsAuthor := false,
       IsMaintainer := false,
     ),

  rec( LastName := "Skartsæterhagen",
       FirstNames := "Øystein",
       IsAuthor := false,
       IsMaintainer := false,
     ),

  rec( LastName := "Wensley",
       FirstNames := "Chris",
       IsAuthor := false,
       IsMaintainer := false,
     ),

  rec( LastName := "Whitney",
       FirstNames := "Glen",
       IsAuthor := false,
       IsMaintainer := false,
     ),

  rec( LastName := "Zickgraf",
       FirstNames := "Fabian",
       IsAuthor := false,
       IsMaintainer := false,
     ),
],

Status := "deposited",
PackageWWWHome := "https://gap-packages.github.io/AutoDoc/",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := Concatenation( "https://gap-packages.github.io/", ~.PackageName ),
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
ArchiveFormats := ".tar.gz",

AbstractHTML :=
  "",

PackageDoc := rec(
  BookName  := "AutoDoc",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0_mj.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Generate documentation from GAP source code",
),

Dependencies := rec(
  GAP := ">= 4.5",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.6.3" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

Keywords := [ "Automatic documentation, GAP, GAPDoc" ],

AutoDoc := rec(
    entities := rec(
        VERSION := ~.Version,
        DATE := ~.Date,
        io := "<Package>io</Package>",
        PackageName := "<Package>PackageName</Package>",
    ),
    TitlePage := rec(
        Copyright := Concatenation(
            "&copyright; 2012-2022 by Sebastian Gutsche and Max Horn<P/>\n\n",
            "This package may be distributed under the terms and conditions ",
            "of the GNU Public License Version 2 or (at your option) any later version.\n"
            ),
        Abstract := Concatenation(
            "&AutoDoc; is a &GAP; package whose purpose is to aid ",
            "&GAP; package authors in creating and maintaining the ",
            "documentation of their packages.\n"
            ),
        Acknowledgements := Concatenation(
            "This documentation was prepared using the ",
            "&GAPDoc; package <Cite Key='GAPDoc'/>.\n",
            "<P/>\n"
            ),
    ),
),

));

