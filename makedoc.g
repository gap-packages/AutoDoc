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

LoadPackage("AutoDoc");

AutoDoc(rec( 
    autodoc := true,
    scaffold := rec(
        includes := [ "Tutorials.xml", 
                      "Comments.xml" ],
        bib := "bib.xml", 
        gapdoc_latex_options := rec( EarlyExtraPreamble := """
            \usepackage[all]{xy} 
            \newcommand{\bbZ} {\mathbb{Z}}
        """ ),  
        entities := rec( 
            VERSION := "2017.09.15", 
            io := "<Package>io</Package>", 
            PackageName := "<Package>PackageName</Package>" 
        )
    )
));

# Create VERSION file for "make towww"
PrintTo( "VERSION", GAPInfo.PackageInfoCurrent.Version );

QUIT;
