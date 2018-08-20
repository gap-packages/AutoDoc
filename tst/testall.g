#############################################################################
##
##  AutoDoc package
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
## Licensed under the GPL 2 or later.
##
#############################################################################

LoadPackage( "AutoDoc" );

TestDirectory( DirectoriesPackageLibrary( "AutoDoc", "tst" ),
               rec( exitGAP := true )
             );

FORCE_QUIT_GAP(1); # should only be reached in case of error
