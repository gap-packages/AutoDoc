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
gap> Scan_for_AutoDoc_Part( "plain text @Section   Intro", true );
[ "@Section", "Intro" ]
gap> Scan_for_AutoDoc_Part( "   @Chapter   My Chapter", true );
[ "@Chapter", "My Chapter" ]
gap> Scan_for_AutoDoc_Part( "   @NoArg", true );
[ "@NoArg", "" ]
gap> Scan_for_AutoDoc_Part( "no command here", true );
[ "STRING", "no command here" ]

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
gap> STOP_TEST( "misc.tst" );
