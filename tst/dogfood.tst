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

# prepare a temporary package copy and run there
gap> olddir := AUTODOC_CurrentDirectory();;
gap> pkgdir := DirectoriesPackageLibrary( "AutoDoc", "");;

# run in a temporary copy, so the package source tree can stay read-only
gap> tempdir := Filename(DirectoryTemporary(), "autodoc-dogfood");;
gap> if IsDirectoryPath(tempdir) then RemoveDirectoryRecursively(tempdir); fi;
gap> Exec(Concatenation("cp -R \"", Filename(pkgdir, ""), "\" \"", tempdir, "\""));
gap> ChangeDirectoryCurrent(tempdir);
true

# regenerate the manual using AutoDoc
gap> Read("makedoc.g" : nopdf);

# restore info levels and current directory
gap> SetInfoLevel( InfoGAPDoc, oldGAPDocLevel );
gap> SetInfoLevel( InfoWarning, oldWarningLevel );
gap> ChangeDirectoryCurrent(olddir);
true

# prepare to compare the output to the reference output
gap> docdir := Directory(Concatenation(tempdir, "/doc"));;
gap> ex_dir := DirectoriesPackageLibrary( "AutoDoc", "tst/manual.expected" );;
gap> ex_dir := ex_dir[1];;

# check all expected generated files
gap> files := DirectoryContents(ex_dir);;
gap> files := Filtered(files, f -> f <> "." and f <> "..");;
gap> Sort(files);
gap> for f in files do
> expected := Filename(ex_dir, f);;
> actual := Filename(docdir, f);;
> if not IsReadableFile(actual) then
>   Error("missing generated file ", f);
> fi;
> if 0 <> AUTODOC_Diff("-u", expected, actual) then
>   Error("diff detected in file ", f);
> fi;
> od;

#
gap> RemoveDirectoryRecursively(tempdir);
true

#
gap> STOP_TEST( "dogfood.tst" );
