SetPackageInfo( rec(

PackageName := "AutoDoc",

Subtitle := "Generate documentation from GAP source code",

Version := Maximum( [
  "2013.08.08.15:45", ## Sebas' version
## This line prevents merge conflicts
  "2013.07.30", ## Max' version
## This line prevents merge conflicts
  "2013.08.08.20:20", ## Mohamed's version
] ),

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( ~.Date{[ 9, 10 ]}, "/", ~.Date{[ 6, 7 ]}, "/", ~.Date{[ 1 .. 4 ]} ),

ArchiveURL := Concatenation( "http://wwwb.math.rwth-aachen.de/~gutsche/gap_packages/AutoDoc/AutoDoc-", ~.Version ),

ArchiveFormats := ".tar.gz",

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
               "JLU Gießen\n",
               "Arndtstraße 2\n",
               "D-35392 Gießen\n",
               "Germany" ),
       Place := "Gießen",
       Institution := "Justus-Liebig-Universität Gießen"
     ),
  
],

Status := "deposited",

README_URL := 
  "http://wwwb.math.rwth-aachen.de/~gutsche/gap_packages/AutoDoc/README.AutoDoc",
PackageInfoURL := 
  "http://wwwb.math.rwth-aachen.de/~gutsche/gap_packages/AutoDoc/PackageInfo.g",

AbstractHTML := 
  "",
PackageWWWHome := "http://wwwb.math.rwth-aachen.de/~gutsche/gap_packages/AutoDoc",
PackageDoc := rec(
  BookName  := "AutoDoc",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Generate documentation from GAP source code",
  Autoload  := false
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

Keywords := [ "Automatic documentation, GAP, GAPDoc" ]

));


