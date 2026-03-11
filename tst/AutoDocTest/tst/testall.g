LoadPackage( "AutoDocTest" );

TestDirectory(DirectoriesPackageLibrary( "AutoDocTest", "tst" ),
  rec(exitGAP := true));

ForceQuitGap(1); # if we ever get here, there was an error
