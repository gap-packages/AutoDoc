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
# AutoDoc_Parser_ReadFiles: multiline InstallMethod parsing
#
gap> tree := DocumentationTree();;
gap> AutoDoc_Parser_ReadFiles( [ "tst/autodoc-parser-installmethod.g" ], tree, rec() );
gap> section := SectionInTree( tree, "Parser", "InstallMethod" );;
gap> item := section!.content[ 1 ];;
gap> item!.item_type;
"Oper"
gap> item!.name;
"MyOp"
gap> item!.tester_names;
"for IsInt,IsString"
gap> item!.arguments;
"x,y"

#
# fenced code blocks in Markdown-like text
#
gap> CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML([
>   "Before",
>   "```gap",
>   "if x = 2 then",
>   "  Print(\"ok\\n\");",
>   "fi;",
>   "```",
>   "After"
> ]) = [
>   "Before",
>   "<Listing><![CDATA[",
>   "if x = 2 then",
>   "  Print(\"ok\\n\");",
>   "fi;",
>   "]]></Listing>",
>   "After"
> ];
true
gap> CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML([
>   "~~~",
>   "gap> [[2]]>[[1]];",
>   "~~~"
> ]) = [
>   "<Listing><![CDATA[",
>   "gap> [[2]]]]><![CDATA[>[[1]];",
>   "]]></Listing>"
> ];
true
gap> CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML([
>   "```@example",
>   "gap> 1 + 1;",
>   "2",
>   "```"
> ]) = [
>   "<Example><![CDATA[",
>   "gap> 1 + 1;",
>   "2",
>   "]]></Example>"
> ];
true
gap> CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML([
>   "```@log",
>   "#I  some log message",
>   "```"
> ]) = [
>   "<Log><![CDATA[",
>   "#I  some log message",
>   "]]></Log>"
> ];
true
gap> CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML([
>   "```@listing",
>   "#! @BeginCode Increment",
>   "i := i + 1;",
>   "#! @EndCode",
>   "",
>   "#! @InsertCode Increment",
>   "## Code is inserted here.",
>   "```"
> ]) = [
>   "<Listing><![CDATA[",
>   "#! @BeginCode Increment",
>   "i := i + 1;",
>   "#! @EndCode",
>   "",
>   "#! @InsertCode Increment",
>   "## Code is inserted here.",
>   "]]></Listing>"
> ];
true
gap> rendered := "";;
gap> stream := OutputTextString(rendered, true);;
gap> SetPrintFormattingStatus(stream, false);
gap> WriteDocumentation([
>   "```@listing",
>   "#! @BeginCode Increment",
>   "i := i + 1;",
>   "#! @EndCode",
>   "",
>   "#! @InsertCode Increment",
>   "## Code is inserted here.",
>   "```"
> ], stream, 0);
gap> CloseStream(stream);
gap> rendered = Concatenation(
>   "<Listing><![CDATA[\n",
>   "#! @BeginCode Increment\n",
>   "i := i + 1;\n",
>   "#! @EndCode\n",
>   "\n",
>   "#! @InsertCode Increment\n",
>   "## Code is inserted here.\n",
>   "]]></Listing>\n"
> );
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
gap> WriteDocumentation(tree2, Directory(tmpdir), 0);
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
gap> WriteDocumentation(tree3, Directory(tmpdir), 0);
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
gap> STOP_TEST( "misc.tst" );
