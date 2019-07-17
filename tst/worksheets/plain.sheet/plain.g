#############################################################################
##
##  AutoDoc package
##
##  Test the behavior of AutoDoc in plain text mode
##
#############################################################################
Print( "Pretend this is a code file.\n" );
Print( "(Even though we never use it that way.)\n" );
#! @Title Plain Text Mode Test
#! @Date 30/08/2018
#! @AutoDocPlainText
@Chapter Test
This is dummy text
@BeginExampleSession
gap> S5 := SymmetricGroup(5);
Sym( [ 1 .. 5 ] )
gap> Size(S5);
120
@EndExampleSession
Some text between two examples
@BeginExampleSession
gap> A5 := AlternatingGroup(5);
Alt( [ 1 .. 5 ] )
gap> Size(A5);
60
@EndExampleSession
And we wrap up with some dummy text
@EndAutoDocPlainText
Print( "This line in the file should not be processed.\n" );
#! But this should produce more text.
