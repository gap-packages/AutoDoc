#############################################################################
##
##  AutoDoc package
##
##  Test the behavior of AutoDoc by generating its own manual
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
## Licensed under the GPL 2 or later.
##
#############################################################################
#### Note: we set InfoWarning to 0 temporarily below because we have to
#### suppress a message from GAPDocManualLabFromSixFile
#### (which function is in the core lib/package.gi)

gap> START_TEST( "AutoDoc package: dogfood.tst" );
gap> tstdir := DirectoriesPackageLibrary( "AutoDoc", "tst" )[ 1 ];;
gap> if IsWritableFile( Filename( tstdir, "" ) ) then
> outdir := Directory( Filename( tstdir, "manual.actual" ) );
> else outdir := DirectoryTemporary();
> fi;
gap> if IsExistingFile( Filename( outdir, "" ) ) then
> for fn in DirectoryContents( outdir ) do RemoveFile( Filename ( outdir, fn ) );
> od; fi;
gap> AUTODOC_CreateDirIfMissing( Filename( outdir, "" ) );;
gap> AutoDoc_just_a_test := true;
true
gap> mdf := Filename( DirectoriesPackageLibrary( "AutoDoc", "")[ 1 ], "makedoc.g" );;
gap> Read(mdf);
gap> autodoc_args_rec.dir := outdir;;
gap> docdir := DirectoriesPackageLibrary( "AutoDoc", "doc" )[ 1 ];;
gap> for fn in [ "Tutorials.xml", "Comments.xml", "bib.xml" ] do
> contents := ReadAll( InputTextFile( Filename( docdir, fn ) ) );
> WriteAll( OutputTextFile( Filename( outdir, fn ), false ), contents );
> od;
gap> SetInfoLevel( InfoGAPDoc, 0 );
gap> SetInfoLevel( InfoWarning, 0 );
gap> AutoDoc( "AutoDoc", autodoc_args_rec);
true
gap> SetInfoLevel( InfoWarning, 1 );
gap> ex_dir := Directory( Filename( tstdir, "manual.expected" ) );;
gap> chap3 := Filename( outdir, "_Chapter_AutoDoc_worksheets.xml" );;
gap> chap3ref := Filename( ex_dir, "_Chapter_AutoDoc_worksheets.xml" );;
gap> chap3diffout := Filename( outdir, "chap3.diff");;
gap> command := Concatenation( "diff -s -c ", chap3ref, " ", chap3, " > ", chap3diffout );;
gap> Exec( command );
gap> chap3diff := ReadAll( InputTextFile( chap3diffout ) );;
gap> chap3good := chap3diff = Concatenation( "Files ", chap3ref, " and ", chap3, " are identical\n" );
true
gap> if not chap3good then Print( chap3diff ); fi;
gap> chap4 := Filename( outdir, "_Chapter_AutoDoc.xml" );;
gap> chap4ref := Filename( ex_dir, "_Chapter_AutoDoc.xml" );;
gap> chap4diffout := Filename( outdir, "chap4.diff");;
gap> command := Concatenation( "diff -s -c ", chap4ref, " ", chap4, " > ", chap4diffout );;
gap> Exec( command );
gap> chap4diff := ReadAll( InputTextFile( chap4diffout ) );;
gap> chap4good := chap4diff = Concatenation( "Files ", chap4ref, " and ", chap4, " are identical\n" );
true
gap> if not chap4good then Print( chap4diff ); fi;
gap> STOP_TEST( "dogfood.tst", 10000 );
## No point in testing chapters 1 or 2 unless/until they are converted to autodoc
