#
# test parser error reporting with ErrorWithPos
gap> ParseFixture := function( arg )
> local tree, default_chapter_data;
> tree := DocumentationTree();
> if Length( arg ) > 1 then
>   default_chapter_data := arg[ 2 ];
> else
>   default_chapter_data := CreateDefaultChapterData( "Pkg" );
> fi;
> AutoDoc_Parser_ReadFiles( [ arg[ 1 ] ], tree, default_chapter_data );
> return tree;
> end;;

#
# control: valid parser input still works
#
gap> tree := ParseFixture( "tst/errorwithpos/valid.g" );;
gap> section := SectionInTree( tree, "Parser", "Valid" );;
gap> item := section!.content[ 1 ];;
gap> item!.name;
"MyOp"

#
# structural command/context errors
#
gap> ParseFixture( "tst/errorwithpos/chapterlabel-no-chapter.g" );
Error, found @ChapterLabel with no active chapter,
at tst/errorwithpos/chapterlabel-no-chapter.g:1
gap> ParseFixture( "tst/errorwithpos/chaptertitle-no-chapter.g" );
Error, found @ChapterTitle with no active chapter,
at tst/errorwithpos/chaptertitle-no-chapter.g:1
gap> ParseFixture( "tst/errorwithpos/section-without-chapter.g" );
Error, found @Section with no active chapter,
at tst/errorwithpos/section-without-chapter.g:1
gap> ParseFixture( "tst/errorwithpos/sectionlabel-no-section.g" );
Error, found @SectionLabel with no active section,
at tst/errorwithpos/sectionlabel-no-section.g:2
gap> ParseFixture( "tst/errorwithpos/sectiontitle-no-section.g" );
Error, found @SectionTitle with no active section,
at tst/errorwithpos/sectiontitle-no-section.g:2
gap> ParseFixture( "tst/errorwithpos/subsection-no-section.g" );
Error, found @Subsection with no active section,
at tst/errorwithpos/subsection-no-section.g:2
gap> ParseFixture( "tst/errorwithpos/subsectionlabel-no-subsection.g" );
Error, found @SubsectionLabel with no active subsection,
at tst/errorwithpos/subsectionlabel-no-subsection.g:3
gap> ParseFixture( "tst/errorwithpos/subsectiontitle-no-subsection.g" );
Error, found @SubsectionTitle with no active subsection,
at tst/errorwithpos/subsectiontitle-no-subsection.g:3

#
# declaration parsing errors
#
gap> ParseFixture( "tst/errorwithpos/declaration-outside-section.g",
>     rec(
>         categories := [ ],
>         methods := [ ],
>         attributes := [ ],
>         properties := [ ],
>         global_functions := [ ],
>         global_variables := [ ],
>         info_classes := [ ] ) );
Error, declarations must be documented within a section,
at tst/errorwithpos/declaration-outside-section.g:2
gap> ParseFixture( "tst/errorwithpos/declaration-unterminated-header.g" );
Error, unterminated declaration header,
at tst/errorwithpos/declaration-unterminated-header.g:4
gap> ParseFixture( "tst/errorwithpos/declaration-unterminated-filter-list.g" );
Error, unterminated declaration filter list,
at tst/errorwithpos/declaration-unterminated-filter-list.g:5
gap> ParseFixture( "tst/errorwithpos/declaration-unrecognized-type.g" );
Error, Unrecognized scan type,
at tst/errorwithpos/declaration-unrecognized-type.g:3

#
# InstallMethod parsing errors
#
gap> ParseFixture( "tst/errorwithpos/installmethod-unterminated-header.g" );
Error, unterminated InstallMethod declaration header,
at tst/errorwithpos/installmethod-unterminated-header.g:4
gap> ParseFixture( "tst/errorwithpos/installmethod-unterminated-filter-list.g" );
Error, unterminated InstallMethod filter list,
at tst/errorwithpos/installmethod-unterminated-filter-list.g:5
gap> ParseFixture( "tst/errorwithpos/installmethod-unterminated-declaration.g" );
Error, unterminated InstallMethod declaration,
at tst/errorwithpos/installmethod-unterminated-declaration.g:4
gap> ParseFixture( "tst/errorwithpos/installmethod-unterminated-arguments.g" );
Error, unterminated argument list in InstallMethod declaration,
at tst/errorwithpos/installmethod-unterminated-arguments.g:4
gap> ParseFixture( "tst/errorwithpos/itemtype-unknown.g" );
Error, unknown @ItemType Method; expected one of Attr, Cat, Coll, Constr, Fam,\
 Filt, Func, InfoClass, Meth, Oper, Prop, Repr, Var,
at tst/errorwithpos/itemtype-unknown.g:3

#
# GroupTitle, Index, BREAK, and unknown command errors
#
gap> ParseFixture( "tst/errorwithpos/grouptitle-no-group.g" );
Error, found @GroupTitle with no Group set,
at tst/errorwithpos/grouptitle-no-group.g:3
gap> ParseFixture( "tst/errorwithpos/grouptitle-outside-section.g" );
Error, can only set @GroupTitle within a Chapter and Section.,
at tst/errorwithpos/grouptitle-outside-section.g:2
gap> ParseFixture( "tst/errorwithpos/index-no-item.g" );
Error, found @Index with no active documentation item,
at tst/errorwithpos/index-no-item.g:1
gap> ParseFixture( "tst/errorwithpos/index-no-arguments.g" );
Error, found @Index without arguments,
at tst/errorwithpos/index-no-arguments.g:4
gap> ParseFixture( "tst/errorwithpos/index-unterminated-quoted-key.g" );
Error, found @Index with unterminated quoted key,
at tst/errorwithpos/index-unterminated-quoted-key.g:4
gap> ParseFixture( "tst/errorwithpos/index-empty-key.g" );
Error, found @Index with empty key,
at tst/errorwithpos/index-empty-key.g:4
gap> ParseFixture( "tst/errorwithpos/break.g" );
Error, parser requested failure,
at tst/errorwithpos/break.g:1
gap> ParseFixture( "tst/errorwithpos/unknown-command.g" );
Error, unknown AutoDoc command @NotACommand,
at tst/errorwithpos/unknown-command.g:1
