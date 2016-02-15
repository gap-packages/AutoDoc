#############################################################################
##
##  AutoDoc package
##
##  Copyright 2012-2016
##    Sebastian Gutsche, University of Kaiserslautern
##    Max Horn, Justus-Liebig-Universität Gießen
##
## Licensed under the GPL 2 or later.
##
#############################################################################

LoadPackage("AutoDoc");

AutoDoc(rec( 
    autodoc := true,
    scaffold := rec(
        includes := [
            "Tutorials.xml",
            "Comments.xml"
            ],
        entities := [
            "SomePackage",
        ],
    )
));

# Create VERSION file for "make towww"
PrintTo( "VERSION", GAPInfo.PackageInfoCurrent.Version );

QUIT;
