#############################################################################
##
##  AutoDoc package
##
#############################################################################
Print( "Pretend this is a code file.\n" );
Print( "(Even though we never use it that way.\n" );
#! @Title General Test
#! @Date 30/08/2018

#! @Chapter SomeChapter
#! This is dummy text
#! @BeginExampleSession
#! gap> S5 := SymmetricGroup(5);
#! Sym( [ 1 .. 5 ] )
#! gap> Size(S5);
#! 120
#! @EndExampleSession
#! Some text between two examples
#! @BeginExampleSession
#! gap> A5 := AlternatingGroup(5);
#! Alt( [ 1 .. 5 ] )
#! gap> Size(A5);
#! 60
#! @EndExampleSession
#! And we wrap up with some dummy text

#############################################################################
#! @Section Some categories
#!  Intro text
DeclareCategory("MyThings", IsObject);
DeclareCategoryCollections("MyThings");
DeclareCategoryCollections("MyThingsColl");
DeclareCategoryCollections("MyThingsCollection");
Now here is some text with a bunch of &!$%*!/ weird things in it. But that
should be OK, nothing should end up in a weird place.
#! Let's wrap up with something, though.

#############################################################################
#! @Section SomeSection

#! Some test just inside a section.

#! @Subsection SomeSubsection
#! This is a subsection!

#! @Subsection MarkDown support
#!
#! We can use test some markdown features here:
#! * This is a list item.
#!   * This is a subitem
#!   * We can also use math mode here: $a^2+b^2=c^2$.
#! * This is __emphasized__ text in a list item.
#! * This is also **emphasized** text in a list item.
#! * This is `inline code` in a list item.
#!
#! All of this can **also** be __used__ outside of a `list`.

#! @Description
#!   An info class
DeclareInfoClass("InfoTESTCLASS");

#! @LatexOnly This text will only appear in the \LaTeX version.
#! @BeginLatexOnly
#! This text will only appear in the \LaTeX version, too.
#! @EndLatexOnly

#! @NotLatex This text will only appear in the HTML version and the text version.
#! @BeginNotLatex
#! This text will only appear in the HTML version and the text version, too.
#! @EndNotLatex

#############################################################################
#! @Section Testing the group commands

#! @BeginGroup Group1
#! @GroupTitle A family of operations

#! @Description
#!  First sentence.
DeclareOperation( "FirstOperation", [ IsInt ] );

#! @Description
#!  Second sentence.
DeclareOperation( "SecondOperation", [ IsInt, IsGroup ] );

#! @EndGroup

## .. Stuff ..

#! @Description
#!  Third sentence.
#! @Group Group1
KeyDependentOperation( "ThirdOperation", IsGroup, IsInt, "prime );

#############################################################################
#! @Section Testing chunks

#! @BeginChunk MyChunk
#! Hello, world.
#!   This line is indented!
#! @EndChunk

#! This test comes after the chunk is declared, but before it is inserted.

#! @InsertChunk MyChunk

#! The text "Hello, world." is inserted right before this.

#############################################################################
#! @Section Testing code chunks

#! @BeginCode MyCode
#! Hello, world.
x := 1 + 1;
if x = 2 then
  Print("1 + 1 = 2 holds, all is good\n");
else
  Error("1+1 <> 2");
fi;
#! @EndCode

#! This test comes after the code chunk is declared, but before it is inserted.

#! @InsertCode MyCode

#! The text "Hello, world." is inserted right before this.
