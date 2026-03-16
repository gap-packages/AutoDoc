#
# test worksheets
#
gap> START_TEST( "worksheets.tst" );

#
gap> AUTODOC_TestWorkSheet("general");
#I  Extracting manual examples for General Test package ...
#I  2 chapters detected
#I  Chapter 1...
#I  extracted 3 examples
#I  Chapter 2...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("consecutive-declarations");
#I  Extracting manual examples for Consecutive Declarations Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("item-type-metadata");
#I  Extracting manual examples for Item Type Metadata Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("autoplain");
#I  Extracting manual examples for Plain file.autodoc Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  extracted 3 examples

#
gap> AUTODOC_TestWorkSheet("label-entities");
#I  Extracting manual examples for Label Entities Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-structure");
#I  Extracting manual examples for Paired Structure Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-structure-autoplain");
#I  Extracting manual examples for Paired Structure Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-blocks");
#I  Extracting manual examples for Paired Blocks Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-blocks-autoplain");
#I  Extracting manual examples for Paired Blocks Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-examples");
#I  Extracting manual examples for Paired Examples Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  extracted 4 examples

#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-worksheet-subdir");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> sheetdir := DirectoriesPackageLibrary(
>   "AutoDoc", "tst/worksheets/paired-examples.sheet" )[1];;
gap> filenames := DirectoryContents(sheetdir);;
gap> filenames := Filtered(filenames, f -> f <> "." and f <> "..");;
gap> filenames := List(filenames, f -> Filename(sheetdir, f));;
gap> old := InfoLevel(InfoAutoDoc);;
gap> oldgapdoc := InfoLevel(InfoGAPDoc);;
gap> SetInfoLevel(InfoAutoDoc, 0);
gap> SetInfoLevel(InfoGAPDoc, 0);
gap> AutoDocWorksheet(
>   filenames,
>   rec(
>     dir := tmpdir_obj,
>     extract_examples := rec(subdir := "tst/generated")
>   ) : nopdf
> );
gap> SetInfoLevel(InfoAutoDoc, old);
gap> SetInfoLevel(InfoGAPDoc, oldgapdoc);
gap> expecteddir := DirectoriesPackageLibrary(
>   "AutoDoc", "tst/worksheets/paired-examples.expected/tst"
> )[1];;
gap> expected := Filename(expecteddir, "paired_examples_test01.tst");;
gap> actual := Filename(tmpdir_obj, "tst/generated/paired_examples_test01.tst");;
gap> if not IsReadableFile(actual) then
>   Error("missing generated file ", actual);
> fi;
gap> if IsReadableFile(Filename(tmpdir_obj, "tst/paired_examples_test01.tst")) then
>   Error("generated file was written to tst/ instead of the configured subdir");
> fi;
gap> if 0 <> AUTODOC_Diff("-u", expected, actual) then
>   Error("diff detected in generated file ", actual);
> fi;
gap> RemoveDirectoryRecursively(tmpdir);
true

#
gap> AUTODOC_TestWorkSheet("paired-examples-autoplain");
#I  Extracting manual examples for Paired Examples Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  extracted 4 examples

#
gap> AUTODOC_TestWorkSheet("paired-titlepage");
#I  Extracting manual examples for Paired Titlepage Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("paired-titlepage-autoplain");
#I  Extracting manual examples for Paired Titlepage Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
gap> AUTODOC_TestWorkSheet("punctuated-filenames");
#I  Extracting manual examples for Punctuated Filenames Test package ...
#I  1 chapters detected
#I  Chapter 1...
#I  no examples

#
#
gap> STOP_TEST( "worksheets.tst" );
