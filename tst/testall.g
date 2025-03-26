LoadPackage( "AutoDoc" );
SetInfoLevel(InfoAutoDoc, 0);
TestDirectory( DirectoriesPackageLibrary("AutoDoc", "tst"), rec(exitGAP := true ) );
FORCE_QUIT_GAP(1);
