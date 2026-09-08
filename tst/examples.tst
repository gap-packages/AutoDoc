#
# test example extraction
#
gap> START_TEST( "examples.tst" );

#
# Extracted tests must point at the file the example was written in, not at
# the intermediate XML file AutoDoc generated from it.
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-examples-sources");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> sheetdir := DirectoriesPackageLibrary(
>   "AutoDoc", "tst/worksheets/paired-examples.sheet" )[1];;
gap> filenames := DirectoryContents(sheetdir);;
gap> filenames := Filtered(filenames, f -> f <> "." and f <> "..");;
gap> filenames := List(filenames, f -> Filename(sheetdir, f));;
gap> old := InfoLevel(InfoAutoDoc);; oldgapdoc := InfoLevel(InfoGAPDoc);;
gap> SetInfoLevel(InfoAutoDoc, 0); SetInfoLevel(InfoGAPDoc, 0);
gap> AutoDocWorksheet(filenames,
>   rec( dir := Directory(tmpdir), extract_examples := true ) : nopdf );
gap> SetInfoLevel(InfoAutoDoc, old); SetInfoLevel(InfoGAPDoc, oldgapdoc);
gap> lines := SplitString(StringFile(
>   Filename(Directory(tmpdir), "tst/paired_examples_test01.tst")), "\n");;

# The four examples start on lines 8, 13, 18 and 23 of worksheet.g.
gap> Perform(Filtered(lines,
>   l -> StartsWith(l, "# ") and PositionSublist(l, ":") <> fail), Display);
# worksheet.g:8-11
# worksheet.g:13-16
# worksheet.g:18-21
# worksheet.g:23-26

# No location may name a generated file.
gap> ForAny(lines, l -> PositionSublist(l, "_Chapter_") <> fail);
false
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# Fenced markdown examples are recorded too, wherever the parser tracks
# source positions for the surrounding text.
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-examples-fence");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(Concatenation(tmpdir, "/src"));
true
gap> source := Concatenation(tmpdir, "/src/fence.g");;
gap> FileString(source, Concatenation(
>   "#! @Title Fence Test\n",
>   "#! @Date 2026-01-01\n",
>   "#! @Chapter Ch\n",
>   "#! @Section Sec\n",
>   "\n",
>   "#! @Description\n",
>   "#!  Some description text.\n",
>   "#!  ```@example\n",
>   "#!  gap> 1+1;\n",
>   "#!  2\n",
>   "#!  ```\n",
>   "#! @Arguments x\n",
>   "DeclareOperation( \"AutoDocFenceDemo\", [ IsInt ] );\n" )) <> fail;
true
gap> old := InfoLevel(InfoAutoDoc);; oldgapdoc := InfoLevel(InfoGAPDoc);;
gap> SetInfoLevel(InfoAutoDoc, 0); SetInfoLevel(InfoGAPDoc, 0);
gap> AutoDocWorksheet([ source ],
>   rec( dir := Directory(Concatenation(tmpdir, "/out")),
>        extract_examples := true ) : nopdf );
gap> SetInfoLevel(InfoAutoDoc, old); SetInfoLevel(InfoGAPDoc, oldgapdoc);
gap> lines := SplitString(StringFile(Filename(Directory(tmpdir),
>   "out/tst/fence_test01.tst")), "\n");;

# The fence opens on line 8 and closes on line 11.
gap> Perform(Filtered(lines,
>   l -> StartsWith(l, "# ") and PositionSublist(l, ":") <> fail), Display);
# fence.g:8-11
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# AutoDocExtractExamples runs a package's own makedoc.g in extract-only mode:
# no manual is built, and nothing is written into the package directory.
#
gap> pkgdir := DirectoriesPackageLibrary( "AutoDoc", "tst/AutoDocTest" )[1];;
gap> docdir := Directory( Filename( pkgdir, "doc" ) );;
gap> before := Set( DirectoryContents( docdir ) );;
gap> old := InfoLevel(InfoAutoDoc);; oldgapdoc := InfoLevel(InfoGAPDoc);;
gap> SetInfoLevel(InfoAutoDoc, 0); SetInfoLevel(InfoGAPDoc, 0);
gap> tstdir := AutoDocExtractExamples( pkgdir, "makedoc-examples-chapter.g" );;
gap> SetInfoLevel(InfoAutoDoc, old); SetInfoLevel(InfoGAPDoc, oldgapdoc);
gap> IsDirectory( tstdir );
true

# The package directory must be untouched: no generated XML, no .tst files.
gap> Set( DirectoryContents( docdir ) ) = before;
true
gap> Filtered( DirectoryContents( Directory( Filename( pkgdir, "tst" ) ) ),
>              f -> EndsWith( f, ".tst" ) );
[  ]

# The extracted tests match the reference output of a full manual build.
gap> expected := Filename( pkgdir,
>   "tst/examples-chapter.expected/autodoctest01.tst" );;
gap> AUTODOC_Diff( "-u", expected, Filename( tstdir, "autodoctest01.tst" ) );
0

#
# Extraction must work when the package directory cannot be written to, as
# happens for packages installed system-wide.
#
gap> frozen := Filename(DirectoryTemporary(), "autodoc-examples-frozen");;
gap> if IsDirectoryPath(frozen) then RemoveDirectoryRecursively(frozen); fi;
gap> Exec(Concatenation("cp -R \"", Filename(pkgdir, ""), "\" \"", frozen, "\""));
gap> Exec(Concatenation("chmod -R a-w \"", frozen, "\""));

# Running as root defeats chmod, so only assert when the dir really is locked.
gap> locked := not IsWritableFile(Concatenation(frozen, "/doc"));;
gap> if locked then
>   SetInfoLevel(InfoAutoDoc, 0); SetInfoLevel(InfoGAPDoc, 0);
>   tstdir := AutoDocExtractExamples(
>       Directory(frozen), "makedoc-examples-chapter.g" );
>   SetInfoLevel(InfoAutoDoc, old); SetInfoLevel(InfoGAPDoc, oldgapdoc);
>   if AUTODOC_Diff( "-u", expected, Filename(tstdir, "autodoctest01.tst") ) <> 0 then
>     Error("extraction from a read-only package dir gave unexpected output");
>   fi;
> fi;
gap> Exec(Concatenation("chmod -R u+w \"", frozen, "\""));
gap> RemoveDirectoryRecursively(frozen);
true

#
# AUTODOC_SourceMarker renders an example's provenance, and declines when it
# cannot: "--" may not appear inside an XML comment.
#
gap> node := DocumentationExample( "Example" );;
gap> node!.source_position := rec( filename := "gap/Foo.gd", line := 5 );;
gap> node!.source_end_position := rec( filename := "gap/Foo.gd", line := 9 );;
gap> AUTODOC_SourceMarker( node );
"<!--AutoDocSource gap/Foo.gd:5-9-->"
gap> listing := DocumentationVerbatim( "Listing", rec( ), [ ] );;
gap> listing!.source_position := node!.source_position;;
gap> AUTODOC_SourceMarker( listing );
fail
gap> node!.source_position := rec( filename := "gap/a--b.gd", line := 5 );;
gap> SetInfoLevel( InfoAutoDoc, 0 );
gap> AUTODOC_SourceMarker( node );
fail
gap> SetInfoLevel( InfoAutoDoc, old );

#
# AUTODOC_RemapSourcePositions rewrites GAPDoc's origin list, so that the
# start and end of the example both resolve into the original source.
#
gap> str := Concatenation(
>   "<!--AutoDocSource gap/Foo.gd:5-9-->\n",
>   "<Example><![CDATA[\n",
>   "gap> 1+1;\n",
>   "2\n",
>   "]]></Example>\n" );;
gap> starts := Concatenation( [ 1 ], List( Positions( str, '\n' ), p -> p + 1 ) );;
gap> src := List( [ 1 .. Length( starts ) ],
>                 i -> [ starts[i], "_Chapter_Generated.xml", i ] );;
gap> AUTODOC_RemapSourcePositions( str, src );
gap> OriginalPositionDocument( src, PositionSublist( str, "<Example" ) );
[ "gap/Foo.gd", 5 ]
gap> OriginalPositionDocument( src, PositionSublist( str, "]]></Example>" ) );
[ "gap/Foo.gd", 9 ]

# Text past the example keeps its own origin.
gap> Last( src );
[ 82, "_Chapter_Generated.xml", 6 ]

#
# AUTODOC_CommonParentDirectory anchors recorded paths on the inputs alone.
#
gap> AUTODOC_CommonParentDirectory( [ "/a/b/c.g", "/a/b/d.g" ] );
"/a/b/"
gap> AUTODOC_CommonParentDirectory( [ "/a/b/c.g", "/a/x/d.g" ] );
"/a/"
gap> AUTODOC_CommonParentDirectory( [ "/a/b/c.g" ] );
"/a/b/"

# Inputs sharing no directory have no anchor, and neither has no input at all.
gap> AUTODOC_CommonParentDirectory( [ "c.g", "d.g" ] );
fail
gap> AUTODOC_CommonParentDirectory( [ ] );
fail

#
# AUTODOC_ExtractOnlyDirectory decides whether to build the manual normally.
#
gap> AUTODOC_ExtractOnlyDirectory();
fail
gap> AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := false );
fail
gap> IsDirectory( AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := true ) );
true
gap> IsDirectory( AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := "1" ) );
true
gap> scratch := Filename( DirectoryTemporary(), "autodoc-extract-only" );;
gap> AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := scratch ) =
>    Directory( scratch );
true
gap> IsDirectoryPath( scratch );
true
gap> AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := Directory( scratch ) ) =
>    Directory( scratch );
true
gap> AUTODOC_ExtractOnlyDirectory( : AutoDocExtractOnly := 42 );
Error, AutoDocExtractOnly must be true, a path, or a directory object

# An error raised inside a call does not always pop the options stack, which
# would leak the option above into every later test in this session.
gap> if not IsEmpty( OptionsStack ) then ResetOptionsStack(); fi;

#
# AutoDocExtractExamples rejects what it cannot turn into a package.
#
gap> AutoDocExtractExamples( 42 );
Error, pkg must be a package name or a directory object
gap> AutoDocExtractExamples( "no-such-package-here" );
Error, could not locate package no-such-package-here
gap> AutoDocExtractExamples( Directory( "tst" ), "no-such-script.g" );
Error, could not read tst/no-such-script.g

#
gap> STOP_TEST( "examples.tst" );
