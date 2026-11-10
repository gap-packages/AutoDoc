#
# AutoDoc and AutoDocWorksheet with GAPDoc or the scaffold disabled
#
gap> START_TEST( "disabled-steps.tst" );
gap> scaffolded := [ "General_Test.xml", "_AutoDocMainFile.xml",
>   "_Chapter_SomeChapter.xml", "_Chapter_labelChapter.xml", "_Chunks.xml",
>   "_entities.xml", "title.xml" ];;
gap> sheet := Filename( DirectoriesPackageLibrary( "AutoDoc",
>   "tst/worksheets/general.sheet" )[1], "worksheet.g" );;
gap> RunInTempDir := function( name, run )
>   local tmpdir, files;
>   tmpdir := Filename( DirectoryTemporary(), name );
>   AUTODOC_CreateDirIfMissing( tmpdir );
>   run( Directory( tmpdir ) );
>   files := Filtered( DirectoryContents( tmpdir ), f -> f[1] <> '.' );
>   RemoveDirectoryRecursively( tmpdir );
>   return SortedList( files );
> end;;
gap> old := InfoLevel( InfoAutoDoc );;
gap> SetInfoLevel( InfoAutoDoc, 0 );

# worksheet with GAPDoc disabled still gets its scaffold
gap> RunInTempDir( "ws-nogapdoc",
>   function( dir ) AutoDocWorksheet( sheet, rec( dir := dir, gapdoc := false ) ); end )
> = scaffolded;
true

# worksheet with the scaffold disabled, or enabled via true
gap> RunInTempDir( "ws-noscaffold",
>   function( dir ) AutoDocWorksheet( sheet,
>     rec( dir := dir, scaffold := false, gapdoc := false ) ); end )
> = Difference( scaffolded, [ "General_Test.xml", "_entities.xml", "title.xml" ] );
true
gap> RunInTempDir( "ws-scaffoldtrue",
>   function( dir ) AutoDocWorksheet( sheet,
>     rec( dir := dir, scaffold := true, gapdoc := false ) ); end )
> = scaffolded;
true

# package with GAPDoc disabled still gets its scaffold
gap> pkgdir := DirectoriesPackageLibrary( "AutoDoc", "tst/AutoDocTest" )[1];;
gap> files := RunInTempDir( "pkg-nogapdoc",
>   function( dir ) AutoDoc( pkgdir,
>     rec( dir := dir, scaffold := true, gapdoc := false ) ); end );;
gap> IsSubset( files, [ "_entities.xml", "_main.xml", "title.xml" ] );
true

#
gap> SetInfoLevel( InfoAutoDoc, old );
gap> STOP_TEST( "disabled-steps.tst" );
