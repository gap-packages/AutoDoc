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

autodoc_args_rec := rec(
    autodoc := true,
    scaffold := rec(
        includes := [ "Tutorials.xml", 
                      "Comments.xml" ],
        bib := "bib.xml", 
        gapdoc_latex_options := rec( EarlyExtraPreamble := """
            \usepackage{a4wide} 
            \newcommand{\bbZ} {\mathbb{Z}}
        """ ),  
        entities := rec( 
            io := "<Package>io</Package>", 
            PackageName := "<Package>PackageName</Package>",
        )
    )
);

if not IsBound( AutoDoc_just_a_test ) or not AutoDoc_just_a_test then
    LoadPackage( "AutoDoc" );
    AutoDoc( "AutoDoc", autodoc_args_rec );
    QUIT_GAP();
fi;
