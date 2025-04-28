LoadPackage( "AutoDoc" );
SetInfoLevel(InfoAutoDoc, 1);
SetInfoLevel(InfoGAPDoc, 0);
TestDirectory( DirectoriesPackageLibrary("AutoDoc", "tst"), rec(exitGAP := true ) );
FORCE_QUIT_GAP(1);
