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
#### (which function is in the core lib/package.gi, so was hard to track down)

gap> START_TEST( "AutoDoc package: dogfood.tst" );
gap> tmpdir := DirectoryTemporary();;
gap> SetInfoLevel( InfoGAPDoc, 0 );
gap> AutoDoc_just_a_test := true;
true
gap> Read("makedoc.g");
gap> autodoc_args_rec.dir := tmpdir;;
gap> pkgdir := DirectoryCurrent();;
gap> tutfile := Filename(pkgdir, "doc/Tutorials.xml");;
gap> tutcontents := ReadAll(InputTextFile(tutfile));;
gap> tutcopy := Filename(tmpdir, "Tutorials.xml");;
gap> WriteAll(OutputTextFile(tutcopy,false), tutcontents);
true
gap> bibfile := Filename(pkgdir, "doc/bib.xml");;
gap> bibcontents := ReadAll(InputTextFile(bibfile));;
gap> bibcopy := Filename(tmpdir, "bib.xml");;
gap> WriteAll(OutputTextFile(bibcopy,false), bibcontents);
true
gap> SetInfoLevel( InfoWarning, 0 );
gap> AutoDoc(autodoc_args_rec);
true
gap> SetInfoLevel( InfoWarning, 1 );
gap> chap2 := Filename( tmpdir, "_Chapter_Comments.xml" );;
gap> chap2ref := Filename( pkgdir, "tst/_Chapter_Comments.reference" );;
gap> chap2diff := Filename( tmpdir, "chap2.diff");;
gap> command := Concatenation( "diff ", chap2ref, " ", chap2, " > ", chap2diff );;
gap> Exec( command );
gap> ReadAll(InputTextFile(chap2diff));
"1d0\n< Intentional difference\n"
gap> chap3 := Filename( Directory(tmpdir), "_Chapter_AutoDoc_worksheets.xml" );;
gap> chap3ref := Filename( pkgdir, "tst/_Chapter_AutoDoc_worksheets.reference" );;
gap> chap3diff := Filename( tmpdir, "chap3.diff");;
gap> command := Concatenation( "diff ", chap3ref, " ", chap3, " > ", chap3diff );;
gap> Exec( command );
gap> ReadAll(InputTextFile(chap3diff));
"1d0\n< Intentional difference\n"
gap> chap4 := Filename( Directory(tmpdir), "_Chapter_AutoDoc.xml" );;
gap> chap4ref := Filename( pkgdir, "tst/_Chapter_AutoDoc.reference" );;
gap> chap4diff := Filename( tmpdir, "chap4.diff");;
gap> command := Concatenation( "diff ", chap4ref, " ", chap4, " > ", chap4diff );;
gap> Exec( command );
gap> ReadAll(InputTextFile(chap4diff));
"1d0\n< Intentional difference\n"
gap> STOP_TEST( "dogfood.tst", 10000 );
## No point in testing chapter 1 unless/until it is converted to autodoc
