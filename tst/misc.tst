#
# test miscellaneous stuff
#
gap> START_TEST( "misc.tst" );

# AUTODOC_SetIfMissing
gap> r:=rec();
rec(  )
gap> AUTODOC_SetIfMissing(r, "foo", 1);
gap> r;
rec( foo := 1 )
gap> AUTODOC_SetIfMissing(r, "foo", 2);
gap> r;
rec( foo := 1 )

#
# AUTODOC_ParseDate
#
gap> AUTODOC_ParseDate("2019-03-01");
rec( day := 1, month := 3, year := 2019 )
gap> AUTODOC_ParseDate("01/03/2019");
rec( day := 1, month := 3, year := 2019 )
gap> AUTODOC_ParseDate("01.03.2019");
fail

#
# AUTODOC_FormatDate
#

#
gap> AUTODOC_FormatDate(2019);
"2019"
gap> AUTODOC_FormatDate(2019, 3);
"March 2019"
gap> AUTODOC_FormatDate(2019, 3, 1);
"1 March 2019"
gap> AUTODOC_FormatDate("2019", "3", "1");
"1 March 2019"
gap> AUTODOC_FormatDate("2019-03-01");
"1 March 2019"
gap> AUTODOC_FormatDate("01/03/2019");
"1 March 2019"
gap> AUTODOC_FormatDate(rec(year:=2019));
"2019"
gap> AUTODOC_FormatDate(rec(year:=2019, month:=3));
"March 2019"
gap> AUTODOC_FormatDate(rec(year:=2019, month:=3, day:=1));
"1 March 2019"
gap> AUTODOC_FormatDate(rec(year:="2019", month:="3", day:="1"));
"1 March 2019"

# error handling
gap> AUTODOC_FormatDate();
Error, Invalid arguments
gap> AUTODOC_FormatDate(2019, 3, 40);
Error, <day> must be an integer in the range [1..31], or a string representing\
 such an integer
gap> AUTODOC_FormatDate(2019, 13, 1);
Error, <month> must be an integer in the range [1..12], or a string representi\
ng such an integer
gap> AUTODOC_FormatDate(fail, 3, 1);
Error, <year> must be an integer >= 2000, or a string representing such an int\
eger

#
# AUTODOC_PositionPrefixShebang
#
gap> AUTODOC_PositionPrefixShebang( "#! @Chapter Intro" );
1
gap> AUTODOC_PositionPrefixShebang( "   #! @Section One" );
4
gap> AUTODOC_PositionPrefixShebang( "\t#! @Subsection Two" );
2
gap> AUTODOC_PositionPrefixShebang( "" );
fail
gap> AUTODOC_PositionPrefixShebang( "#" );
fail
gap> AUTODOC_PositionPrefixShebang( "    " );
fail
gap> AUTODOC_PositionPrefixShebang( "x #! @Chapter NotPrefix" );
fail
gap> AUTODOC_PositionPrefixShebang( "  x#! @Chapter NotPrefix" );
fail
gap> AUTODOC_PositionPrefixShebang( "  # ! not-a-shebang" );
fail

#
# Scan_for_AutoDoc_Part: robust command splitting
#
gap> Scan_for_AutoDoc_Part( "plain text @Section   Intro" );
[ "STRING", "plain text @Section   Intro" ]
gap> Scan_for_AutoDoc_Part( "   @Chapter   My Chapter" );
[ "@Chapter", "My Chapter" ]
gap> Scan_for_AutoDoc_Part( "   @Section   My Section" );
[ "@Section", "My Section" ]
gap> Scan_for_AutoDoc_Part( "   @Subsection   My Subsection" );
[ "@Subsection", "My Subsection" ]
gap> Scan_for_AutoDoc_Part( "   @NoArg" );
[ "@NoArg", "" ]
gap> Scan_for_AutoDoc_Part( "no command here" );
[ "STRING", "no command here" ]
gap> Scan_for_AutoDoc_Part( "# Heading chapter" );
[ "@Chapter", "Heading chapter" ]
gap> Scan_for_AutoDoc_Part( "## Heading section" );
[ "@Section", "Heading section" ]
gap> Scan_for_AutoDoc_Part( "### Heading subsection" );
[ "@Subsection", "Heading subsection" ]

#
# AUTODOC_CreateDirIfMissing: nested paths and `..` normalization
#
gap> LoadPackage("io", false);
true
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-createdir-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "alpha/beta/gamma"));
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "alpha"));
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "alpha/beta"));
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "alpha/beta/gamma"));
true
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "one/two/../three"));
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "one/three"));
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "one/two"));
false
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "work/current"));
true
gap> olddir := AUTODOC_CurrentDirectory();;
gap> ChangeDirectoryCurrent(Filename(tmpdir_obj, "work/current"));
true
gap> AUTODOC_CreateDirIfMissing("../sibling/nested");
true
gap> ChangeDirectoryCurrent(olddir);
true
gap> IsDirectoryPath(Filename(tmpdir_obj, "work/sibling/nested"));
true
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# AUTODOC_FindMatchingFiles: recursive scan_dirs traversal
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-findmatchingfiles-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "gap"));
true
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "gap/sub"));
true
gap> AUTODOC_CreateDirIfMissing(Filename(tmpdir_obj, "lib"));
true
gap> stream := OutputTextFile(Filename(tmpdir_obj, "gap/top.gd"), false);;
gap> CloseStream(stream);
gap> stream := OutputTextFile(Filename(tmpdir_obj, "gap/sub/nested.gi"), false);;
gap> CloseStream(stream);
gap> stream := OutputTextFile(Filename(tmpdir_obj, "lib/extra.g"), false);;
gap> CloseStream(stream);
gap> stream := OutputTextFile(Filename(tmpdir_obj, "gap/sub/ignore.txt"), false);;
gap> CloseStream(stream);
gap> AUTODOC_FindMatchingFiles(tmpdir_obj, ["gap", "lib"], ["g", "gi", "gd"]);
[ "gap/sub/nested.gi", "gap/top.gd", "lib/extra.g" ]
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# AutoDoc_Parser_ReadFiles: multiline InstallMethod parsing
#
gap> tree := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles( [ "tst/autodoc-parser-installmethod.g" ], tree, rec() );
gap> section := SectionInTree( tree, "Parser", "InstallMethod" );;
gap> item := section!.content[ 1 ];;
gap> item!.item_type;
"Func"
gap> item!.name;
"MyOp"
gap> item!.tester_names;
"for IsInt,IsString"
gap> item!.arguments;
"x,y"

#
# AutoDoc_Parser_ReadFiles: DeclareGlobalName defaults and overrides
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-globalname-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file := Filename(tmpdir_obj, "globalname.gd");;
gap> stream := OutputTextFile(file, false);;
gap> AppendTo(stream, "#! @Chapter Parser\n");;
gap> AppendTo(stream, "#! @Section GlobalName\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "DeclareGlobalName( \"DefaultGlobalName\" );\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "#! @Arguments x\n");;
gap> AppendTo(stream, "DeclareGlobalName( \"ArgumentGlobalName\" );\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "#! @Returns a value\n");;
gap> AppendTo(stream, "DeclareGlobalName( \"ReturnGlobalName\" );\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "#! @ItemType Var\n");;
gap> AppendTo(stream, "DeclareGlobalName( \"VariableGlobalName\" );\n");;
gap> CloseStream(stream);
gap> tree := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles( [ file ], tree, rec() );
gap> section := SectionInTree( tree, "Parser", "GlobalName" );;
gap> section!.content[ 1 ]!.item_type;
"Var"
gap> section!.content[ 1 ]!.arguments = fail;
true
gap> section!.content[ 2 ]!.item_type;
"Func"
gap> section!.content[ 2 ]!.arguments;
"x"
gap> section!.content[ 3 ]!.item_type;
"Func"
gap> section!.content[ 3 ]!.arguments;
"arg"
gap> section!.content[ 4 ]!.item_type;
"Var"
gap> section!.content[ 4 ]!.arguments = fail;
true
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# AutoDoc_Parser_ReadFiles: bare tester label keeps an empty argument list
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-empty-args-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file := Filename(tmpdir_obj, "emptyargs.gd");;
gap> stream := OutputTextFile(file, false);;
gap> AppendTo(stream, "#! @Chapter Parser\n");;
gap> AppendTo(stream, "#! @Section Empty Arguments\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "DeclareOperation( \"EmptyArgsOp\", [ ] );\n");;
gap> CloseStream(stream);
gap> tree := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles( [ file ], tree, rec() );
gap> section := SectionInTree( tree, "Parser", "Empty Arguments" );;
gap> item := section!.content[ 1 ];;
gap> item!.tester_names = fail;
true
gap> item!.arguments;
""
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# warn about defined-but-never-inserted chunks
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-unusedchunk-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tree2 := DocumentationTree();;
gap> chunk := DocumentationChunk(tree2, "NeverUsed");;
gap> chunk!.is_defined := true;;
gap> Add(chunk!.content, "Some text");;
gap> WriteDocumentation(tree2, Directory(tmpdir));
#I  WARNING: chunk NeverUsed was defined but never inserted
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# warn about inserted-but-never-defined chunks
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-missingchunk-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tree3 := DocumentationTree();;
gap> chunk := DocumentationChunk(tree3, "MissingChunk");;
gap> chunk!.is_inserted := true;;
gap> WriteDocumentation(tree3, Directory(tmpdir));
#I  WARNING: chunk MissingChunk was inserted but never defined
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# mixed explicit and implicit chapter info with grouped declarations
# see <https://github.com/gap-packages/AutoDoc/issues/279>
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-mixed-context-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file1 := Filename(tmpdir_obj, "explicit.gd");;
gap> stream := OutputTextFile(file1, false);;
gap> AppendTo(stream, "#! @Chapter Explicit\n");;
gap> AppendTo(stream, "#! @Section Intro\n");;
gap> CloseStream(stream);
gap> file2 := Filename(tmpdir_obj, "implicit.gd");;
gap> stream := OutputTextFile(file2, false);;
gap> AppendTo(stream, "#! @BeginGroup grouped\n");;
gap> AppendTo(stream, "DeclareOperation( \"MixedOp\", [ IsObject ] );\n");;
gap> CloseStream(stream);
gap> tree4 := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles([file1, file2], tree4, CreateDefaultChapterData("Pkg"));
gap> auto_section := SectionInTree(tree4,
>     "Pkg_automatic_generated_documentation",
>     "Pkg_automatic_generated_documentation_of_methods");;
gap> group := auto_section!.content[1];;
gap> Label(group);
"GROUP_grouped"
gap> group!.content[1]!.name;
"MixedOp"
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# context stack drives nested parser targets
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-context-stack-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file1 := Filename(tmpdir_obj, "context.gd");;
gap> stream := OutputTextFile(file1, false);;
gap> AppendTo(stream, "#! @Title Parser Stack Test\n");;
gap> AppendTo(stream, "#! @Chapter Parser\n");;
gap> AppendTo(stream, "#! @Section Context Stack\n");;
gap> AppendTo(stream, "#! Intro before chunk.\n");;
gap> AppendTo(stream, "#! @BeginChunk Stored\n");;
gap> AppendTo(stream, "#! chunk line 1\n");;
gap> AppendTo(stream, "#! @BeginLatexOnly\n");;
gap> AppendTo(stream, "#! latex only\n");;
gap> AppendTo(stream, "#! @EndLatexOnly\n");;
gap> AppendTo(stream, "#! chunk line 2\n");;
gap> AppendTo(stream, "#! @EndChunk\n");;
gap> AppendTo(stream, "#! @InsertChunk Stored\n");;
gap> AppendTo(stream, "#! Outro after chunk.\n");;
gap> CloseStream(stream);
gap> tree5 := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles([file1], tree5, rec());
gap> tree5!.TitlePage.Title;
[ "Parser Stack Test" ]
gap> section := SectionInTree(tree5, "Parser", "Context_Stack");;
gap> section!.content[1];
" Intro before chunk.\n"
gap> chunk := section!.content[2];;
gap> HasLabel(chunk);
true
gap> chunk!.content[1];
" chunk line 1\n"
gap> chunk!.content[2]!.element_name;
"Alt"
gap> chunk!.content[2]!.attributes;
rec( Only := "LaTeX" )
gap> chunk!.content[2]!.content;
[ " latex only\n" ]
gap> chunk!.content[3];
" chunk line 2\n"
gap> section!.content[3];
" Outro after chunk.\n"
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# only the first declaration after an AutoDoc comment is documented
# see https://github.com/gap-packages/AutoDoc/issues/169
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-consecutive-declarations-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file1 := Filename(tmpdir_obj, "consecutive.gd");;
gap> stream := OutputTextFile(file1, false);;
gap> AppendTo(stream, "#! @Chapter Parser\n");;
gap> AppendTo(stream, "#! @Section Consecutive Declarations\n");;
gap> AppendTo(stream, "#! @Description\n");;
gap> AppendTo(stream, "#!  Only this declaration should be documented.\n");;
gap> AppendTo(stream, "DeclareGlobalFunction( \"Foo\" );\n");;
gap> AppendTo(stream, "DeclareGlobalFunction( \"Bar\" );\n");;
gap> CloseStream(stream);
gap> tree6 := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles([file1], tree6, rec());
gap> section := SectionInTree(tree6, "Parser", "Consecutive_Declarations");;
gap> Length(section!.content);
1
gap> item := section!.content[1];;
gap> item!.name;
"Foo"
gap> item!.description;
[ "  Only this declaration should be documented.\n" ]
gap> RemoveDirectoryRecursively(tmpdir);
true

#
# example and log blocks require matching end markers
#
gap> tmpdir := Filename(DirectoryTemporary(), "autodoc-example-end-marker-test");;
gap> if IsDirectoryPath(tmpdir) then RemoveDirectoryRecursively(tmpdir); fi;
gap> AUTODOC_CreateDirIfMissing(tmpdir);
true
gap> tmpdir_obj := Directory(tmpdir);;
gap> file1 := Filename(tmpdir_obj, "example-end-markers.gd");;
gap> stream := OutputTextFile(file1, false);;
gap> AppendTo(stream, "#! @Chapter Parser\n");;
gap> AppendTo(stream, "#! @Section End Markers\n");;
gap> AppendTo(stream, "#! @BeginExample\n");;
gap> AppendTo(stream, "1 + 1;\n");;
gap> AppendTo(stream, "#! @EndLog\n");;
gap> AppendTo(stream, "#! still example output\n");;
gap> AppendTo(stream, "#! @EndExample\n");;
gap> AppendTo(stream, "#! @BeginExampleSession\n");;
gap> AppendTo(stream, "#! gap> 2 + 2;\n");;
gap> AppendTo(stream, "#! @EndLogSession\n");;
gap> AppendTo(stream, "#! 4\n");;
gap> AppendTo(stream, "#! @EndExampleSession\n");;
gap> CloseStream(stream);
gap> tree7 := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles([file1], tree7, rec());
gap> section := SectionInTree(tree7, "Parser", "End_Markers");;
gap> example := section!.content[1];;
gap> example!.element_name;
"Example"
gap> example!.content;
[ "gap> 1 + 1;", "@EndLog", "still example output" ]
gap> session_example := section!.content[2];;
gap> session_example!.element_name;
"Example"
gap> session_example!.content;
[ "gap> 2 + 2;", "@EndLogSession", "4" ]
gap> RemoveDirectoryRecursively(tmpdir);
true

#
gap> STOP_TEST( "misc.tst" );
