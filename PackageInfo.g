


SetPackageInfo( rec(

PackageName := "AutoDoc",

Subtitle := "Tools for generating automatic GAPDoc documentations",

Version := Maximum( [
  "2013.01.16", ## Sebas' version
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
    Email         := "sebastian.gutsche@rwth-aachen.de",
    WWWHome       := "http://wwwb.math.rwth-aachen.de/~gutsche/",
    PostalAddress := Concatenation( [
                       "Sebastian Gutsche\n",
                       "Lehrstuhl B fuer Mathematik, RWTH Aachen\n",
                       "Templergraben 64\n",
                       "52062 Aachen\n",
                       "Germany" ] ),
    Place         := "Aachen",
    Institution   := "RWTH Aachen University"
  ),
  rec( LastName := "Horn",
       FirstNames := "Max",
       IsAuthor := true,
       IsMaintainer := true,
       Email := "max@quendi.de",
       WWWHome := "http://www.quendi.de/math.php",
       PostalAddress := Concatenation(
               "AG Algebra\n",
               "Mathematisches Institut\n",
               "JLU Gießen\n",
               "Arndtstrasse 2\n",
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
  LongTitle := "Tools for generating automatic documentation",
  Autoload  := false
),


Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.0" ] ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := []
                      
),

AvailabilityTest := function()
    return true;
  end,

# BannerString := Concatenation( 
#   "----------------------------------------------------------------\n",
#   "Loading  AutoDoc ", ~.Version, "\n",
#   "by ", ~.Persons[1].FirstNames, " ", ~.Persons[1].LastName,
#         " (", ~.Persons[1].WWWHome, ")\n",
#   "   ", ~.Persons[2].FirstNames, " ", ~.Persons[2].LastName,
#         " (", ~.Persons[2].WWWHome, ")\n",
#   "Type:\n",
#   "  ?AutoDoc:        ## for the contents of the manual\n",
#   "  ?AutoDoc:x       ## for chapter/section/topic x\n",
#   "----------------------------------------------------------------\n" ),

Autoload := false,


Keywords := [  ]

));


