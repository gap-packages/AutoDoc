#############################################################################
##
##  AutoDoc package
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
##  Licensed under the GPL 2 or later.
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
#! And we wrap up with some dummy text

#! @Section SomeSection

#! Some test just inside a section. We can use test some markdown features here:
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
