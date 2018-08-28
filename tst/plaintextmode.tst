#############################################################################
##
##  AutoDoc package
##
##  Test the behavior of AutoDoc in plain text mode
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
## Licensed under the GPL 2 or later.
##
#############################################################################

gap> START_TEST( "AutoDoc package: plaintextmode.tst" );
gap> tmpdir := DirectoryTemporary();;
gap> SetInfoLevel( InfoGAPDoc, 0 );
gap> AutoDocWorksheet( "tst/plaintextmode.tst", rec( dir := tmpdir ) );
gap> chap1 := Filename(tmpdir, "_Chapter_Test.xml");;
gap> IsReadableFile(chap1);
true
gap> ReadAll(InputTextFile(chap1));
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<!-- This is an automatically g\
enerated file. -->\n<Chapter Label=\"Chapter_Test\">\n<Heading>Test</Heading>\
\n\nThis is dummy text\n<Example><![CDATA[\ngap> S5 := SymmetricGroup(5);\nSym\
( [ 1 .. 5 ] )\ngap> Size(S5);\n120\n\n# This next command is present to preve\
nt Test() from\n# being misled by the remaining AutoDoc markup.\ngap> STOP_TES\
T( \"dummy.tst\", 10000 );\n]]></Example>\n\n\nAnd we wrap up with some dummy \
text\nBut this should produce more text.\n</Chapter>\n\n"
gap> STOP_TEST( "plaintextmode.tst", 10000 );
#! @AutoDocPlainText
@Title Plain Text Mode Test
@Date 2018/08/17
@Chapter Test
This is dummy text
@BeginExampleSession
gap> S5 := SymmetricGroup(5);
Sym( [ 1 .. 5 ] )
gap> Size(S5);
120

# This next command is present to prevent Test() from
# being misled by the remaining AutoDoc markup.
gap> STOP_TEST( "dummy.tst", 10000 );
@EndExampleSession
And we wrap up with some dummy text
@EndAutoDocPlainText
This line in the file should be completely ignored.
#! But this should produce more text.
