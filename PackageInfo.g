#############################################################################
##
##  AutoDoc package
##
##  Copyright 2012-2016
##    Sebastian Gutsche, University of Kaiserslautern
##    Max Horn, Justus-Liebig-Universität Gießen
##
##  Licensed under the GPL 2 or later.
##
#############################################################################


SetPackageInfo( rec(

PackageName := "AutoDoc",

Subtitle := "Generate documentation from GAP source code",

Version := Maximum( [
  "2018.02.14", ## Sebas' version
## This line prevents merge conflicts
  "2016.12.04", ## Max' version
## This line prevents merge conflicts
  "2013.11.01", ## Mohamed's version
] ),

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( ~.Date{[ 9, 10 ]}, "/", ~.Date{[ 6, 7 ]}, "/", ~.Date{[ 1 .. 4 ]} ),

Persons := [
  rec(
    LastName      := "Gutsche",
    FirstNames    := "Sebastian",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "gutsche@mathematik.uni-kl.de",
    WWWHome       := "http://wwwb.math.rwth-aachen.de/~gutsche/",
    PostalAddress := Concatenation( [
                       "Department of Mathematics\n",
                       "University of Kaiserslautern\n",
                       "67653 Kaiserslautern\n",
                       "Germany" ] ),
    Place         := "Kaiserslautern",
    Institution   := "University of Kaiserslautern"
  ),
  
  rec( LastName := "Horn",
       FirstNames := "Max",
       IsAuthor := true,
       IsMaintainer := true,
       Email := "max.horn@math.uni-giessen.de",
       WWWHome := "http://www.quendi.de/math",
       PostalAddress := Concatenation(
               "AG Algebra\n",
               "Mathematisches Institut\n",
               "Justus-Liebig-Universität Gießen\n",
               "Arndtstraße 2\n",
               "35392 Gießen\n",
               "Germany" ),
       Place := "Gießen",
       Institution := "Justus-Liebig-Universität Gießen"
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
README_URL      := Concatenation( ~.PackageWWWHome, "/README" ),
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
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Generate documentation from GAP source code",
),

Dependencies := rec(
  GAP := ">= 4.5",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.5" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := []
                      
),

AvailabilityTest := function()
    return true;
  end,

Autoload := false,

Keywords := [ "Automatic documentation, GAP, GAPDoc" ],

AutoDoc := rec(
    TitlePage := rec(
        Copyright := Concatenation(
            "&copyright; 2012-2017 by Sebastian Gutsche and Max Horn<P/>\n\n",
            "This package may be distributed under the terms and conditions ", 
            "of the GNU Public License Version 2.\n"
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
            ) 
    )
),

));

