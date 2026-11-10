#
# warnings for plain text that ends up somewhere other than it appears to
#
gap> START_TEST( "text-placement.tst" );
gap> dir := DirectoryTemporary();;
gap> WriteFixture := function( name, lines )
>   FileString( Filename( dir, name ),
>               Concatenation( JoinStringsWithSeparator( lines, "\n" ), "\n" ) );
> end;;
gap> ParseFixtures := function( names )
>   local tree;
>   tree := DocumentationTree();
>   AutoDoc_Parser_ReadFiles(
>       List( names, n -> rec( path := Filename( dir, n ), display := n ) ),
>       tree, CreateDefaultChapterData( "Pkg" ) );
>   return tree;
> end;;

# text outside of a chapter is dropped; one warning per block of lines, none
# for blank lines and XML comments
gap> WriteFixture( "a.autodoc", [
>   "<!-- license header -->",
>   "",
>   "dropped",
>   "also dropped",
>   "@Chapter C",
>   "kept" ] );;
gap> tree := ParseFixtures( [ "a.autodoc" ] );;
#I  WARNING: ignoring text outside of any chapter, at a.autodoc:3

# each file starts without an active chapter
gap> WriteFixture( "b.autodoc", [ "dropped too", "@Chapter C", "kept" ] );;
gap> tree := ParseFixtures( [ "a.autodoc", "b.autodoc" ] );;
#I  WARNING: ignoring text outside of any chapter, at a.autodoc:3
#I  WARNING: ignoring text outside of any chapter, at b.autodoc:1

# text appended to a chapter or section after one of its sections or
# subsections is rendered as part of that child
gap> WriteFixture( "c.autodoc", [
>   "@Chapter C",
>   "chapter intro",
>   "@Section S1",
>   "s1 text",
>   "@Subsection T",
>   "t text",
>   "@Section S1",
>   "",
>   "after T",
>   "still after T",
>   "@Section S2",
>   "s2 text",
>   "@Chapter C",
>   "after S2" ] );;
gap> tree := ParseFixtures( [ "c.autodoc" ] );;
#I  WARNING: text after subsection T appears inside it, at c.autodoc:9
#I  WARNING: text after section S2 appears inside it, at c.autodoc:14

# text after a documented declaration follows its ManSection, not the
# subsection the declaration ended
gap> WriteFixture( "d.gd", [
>   "#! @Chapter C",
>   "#! @Section S",
>   "#! @Subsection T",
>   "#! t text",
>   "#! @Description d",
>   "DeclareGlobalFunction( \"f\" );",
>   "#! after the declaration" ] );;
gap> tree := ParseFixtures( [ "d.gd" ] );;

# blocks separated by code get one warning each
gap> WriteFixture( "e.gd", [
>   "#! dropped",
>   "x := 1;",
>   "#! dropped too" ] );;
gap> tree := ParseFixtures( [ "e.gd" ] );;
#I  WARNING: ignoring text outside of any chapter, at e.gd:1
#I  WARNING: ignoring text outside of any chapter, at e.gd:3

#
gap> STOP_TEST( "text-placement.tst" );
