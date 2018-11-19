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

gap> START_TEST( "dogfood.tst" );

# need IO package for ChangeDirectoryCurrent
gap> LoadPackage("io", false);
true

# temporarily change info levels to suppress all GAPDoc output
gap> oldGAPDocLevel := InfoLevel( InfoGAPDoc );;
gap> oldWarningLevel := InfoLevel( InfoWarning );;
gap> SetInfoLevel( InfoGAPDoc, 0 );
gap> SetInfoLevel( InfoWarning, 0 );

# change into the package directory
gap> olddir := AUTODOC_CurrentDirectory();;
gap> pkgdir := DirectoriesPackageLibrary( "AutoDoc", "");;
gap> ChangeDirectoryCurrent(Filename(pkgdir, ""));
true

# regenerate the manual using AutoDoc
gap> Read("makedoc.g");

# restore info levels and current directory
gap> SetInfoLevel( InfoGAPDoc, oldGAPDocLevel );
gap> SetInfoLevel( InfoWarning, oldWarningLevel );
gap> ChangeDirectoryCurrent(olddir);
true

# prepare to compare the output to the reference output
# No point in testing chapters 1 or 2 unless/until they are converted to autodoc
gap> docdir := DirectoriesPackageLibrary( "AutoDoc", "doc" );;
gap> ex_dir := DirectoriesPackageLibrary( "AutoDoc", "tst/manual.expected" );;

# check chapter 3
gap> chap3 := Filename( docdir, "_Chapter_AutoDoc_worksheets.xml" );;
gap> chap3ref := Filename( ex_dir, "_Chapter_AutoDoc_worksheets.xml" );;
gap> AUTODOC_Diff("-u", chap3ref, chap3);
0

# check chapter 4
gap> chap4 := Filename( docdir, "_Chapter_AutoDoc.xml" );;
gap> chap4ref := Filename( ex_dir, "_Chapter_AutoDoc.xml" );;
gap> AUTODOC_Diff("-u", chap4ref, chap4);
0

#
gap> STOP_TEST( "dogfood.tst" );
