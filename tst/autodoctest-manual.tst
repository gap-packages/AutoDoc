#############################################################################
##
##  AutoDoc package
##
##  Test the behavior of AutoDoc on the minimal AutoDocTest package
##
#############################################################################

gap> START_TEST( "autodoctest-manual.tst" );

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
gap> pkgdir := DirectoriesPackageLibrary( "AutoDoc", "tst/AutoDocTest" );;
gap> pkgdir := pkgdir[1];;
gap> pkgdir := Filename( pkgdir, "" );;
gap> if not StartsWith( pkgdir, "/" ) then
>   pkgdir := Concatenation( olddir, "/", pkgdir );
> fi;
gap> ReadPackage( "AutoDoc", "tst/utils.g" );
true

# baseline manual output
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "manual",
>   makedoc := "makedoc.g",
>   doc_expected := "tst/manual.expected",
> ) );

# entities option variants
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "entities-record",
>   makedoc := "makedoc-entities-record.g",
>   doc_expected := "tst/manual-entities-record.expected",
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "entities-list",
>   makedoc := "makedoc-entities-list.g",
>   doc_expected := "tst/manual-entities-list.expected",
> ) );

# title/main page combinations
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "title-main",
>   makedoc := "makedoc-title-main.g",
>   stub_gapdoc := true,
>   doc_present := [ "_entities.xml", "AutoDocTest.xml", "title.xml" ],
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "notitle-main",
>   makedoc := "makedoc-notitle-main.g",
>   stub_gapdoc := true,
>   doc_present := [ "_entities.xml", "AutoDocTest.xml" ],
>   doc_absent := [ "title.xml" ],
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "title-nomain",
>   makedoc := "makedoc-title-nomain.g",
>   stub_gapdoc := true,
>   doc_present := [ "_entities.xml", "title.xml" ],
>   doc_absent := [ "AutoDocTest.xml" ],
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "notitle-nomain",
>   makedoc := "makedoc-notitle-nomain.g",
>   stub_gapdoc := true,
>   doc_present := [ "_entities.xml" ],
>   doc_absent := [ "AutoDocTest.xml", "title.xml" ],
> ) );

# extract_examples variants
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "examples-chapter",
>   makedoc := "makedoc-examples-chapter.g",
>   tst_expected := "tst/examples-chapter.expected",
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "examples-section",
>   makedoc := "makedoc-examples-section.g",
>   tst_expected := "tst/examples-section.expected",
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "examples-section-keepempty",
>   makedoc := "makedoc-examples-section-keepempty.g",
>   tst_expected := "tst/examples-section-keepempty.expected",
> ) );
gap> AUTODOC_RunPackageScenario( pkgdir, olddir, rec(
>   name := "examples-section-skipempty",
>   makedoc := "makedoc-examples-section-skipempty.g",
>   tst_expected := "tst/examples-section-skipempty.expected",
> ) );

# restore info levels and current directory
gap> SetInfoLevel( InfoGAPDoc, oldGAPDocLevel );
gap> SetInfoLevel( InfoWarning, oldWarningLevel );
gap> ChangeDirectoryCurrent(olddir);
true

#
gap> STOP_TEST( "autodoctest-manual.tst" );
