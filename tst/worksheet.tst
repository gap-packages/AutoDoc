#############################################################################
##
##  AutoDoc package
##
##  Test the behavior of AutoDocWorksheet
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
## Licensed under the GPL 2 or later.
##
#############################################################################

gap> START_TEST( "AutoDoc package: worksheet.tst" );
gap> tmpdir := DirectoryTemporary();;
gap> SetInfoLevel( InfoGAPDoc, 0 );
gap> AutoDocWorksheet( "tst/worksheet.tst", rec( dir := tmpdir ) );
gap> chap1 := Filename( Directory(tmpdir), "_Chapter_Test.xml" );;
gap> IsReadableFile(chap1);
true
gap> ReadAll(InputTextFile(chap1));
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n<!-- This is an automatically g\
enerated file. -->\n<Chapter Label=\"Chapter_Test\">\n<Heading>Test</Heading>\
\n\nThis is dummy text\n<Example><![CDATA[\ngap> S5 := SymmetricGroup(5);\nSym\
( [ 1 .. 5 ] )\ngap> Size(S5);\n120\n]]></Example>\n\n\nAnd we wrap up with so\
me dummy text\n<Section Label=\"Chapter_Test_Section_Some_categories\">\n<Head\
ing>Some categories</Heading>\n\nIntro text\n<ManSection>\n  <Filt Arg=\"arg\"\
 Name=\"MyThings\" Label=\"for IsObject\"/>\n <Returns><C>true</C> or <C>false\
</C>\n</Returns>\n <Description>\n<P/>\n </Description>\n</ManSection>\n\n\n<M\
anSection>\n  <Filt Arg=\"obj\" Name=\"MyThingsCollection\" />\n <Returns><C>t\
rue</C> or <C>false</C>\n</Returns>\n <Description>\n<P/>\n </Description>\n</\
ManSection>\n\n\nAnd now we can test a variety of features of <Package>AutoDoc\
</Package>\nwhich are not tested by processing the main manual.\n<ManSection>\
\n  <Filt Arg=\"obj\" Name=\"IsMyIntersectionObj\" />\n <Description>\nThis ca\
tegory is implemented via a DeclareSynonym.\nYet it will show up properly\n </\
Description>\n</ManSection>\n\n\nTo see how this works, examine the following \
code\n<Listing Type=\"Code\"><![CDATA[\na := MyFirstObj( gens );\nif IsMySecon\
dObj( a ) then\n   b := IsMyIntersectionObj( a );\nfi;\n### b will only ever b\
e set to true, if it is set at all.\n]]></Listing>\n\nWe can also specify the \
type of methods\n<ManSection>\n  <Meth Arg=\"arg1,arg2\" Name=\"GeneralOp\" La\
bel=\"for IsAToughie, IsEvenWorse\"/>\n <Description>\nThis is a special metho\
d for handling tough cases.\n </Description>\n</ManSection>\n\n\nThe coverage \
of this test file could be extended further\n</Section>\n\n\n</Chapter>\n\n"
gap> STOP_TEST( "worksheet.tst", 10000 );
#! @Title Worksheet Test
#! @Date 2018/08/20
#! @Chapter Test
#! This is dummy text
#! @BeginExampleSession
#! gap> S5 := SymmetricGroup(5);
#! Sym( [ 1 .. 5 ] )
#! gap> Size(S5);
#! 120
#! @EndExampleSession
#! And we wrap up with some dummy text
#! @Section Some categories
#!  Intro text
DeclareCategory("MyThings", IsObject);
DeclareCategoryCollections("MyThings");
Now here is some text with a bunch of &!$%*!/ weird things in it. But that
should be OK, nothing should end up in a weird place.
#! And now we can test a variety of features of <Package>AutoDoc</Package>
#! which are not tested by processing the main manual.
#! @Description This category is implemented via a DeclareSynonym.
#!    Yet it will show up properly
#! @ItemType Filt
#! @Arguments obj
DeclareSynonym( "IsMyIntersectionObj", IsMyFirstObj and IsMySecondObj );
#! To see how this works, examine the following code
#! @HereCode
a := MyFirstObj( gens );
if IsMySecondObj( a ) then
   b := IsMyIntersectionObj( a );
fi;
### b will only ever be set to true, if it is set at all.
#! @EndCode
#! We can also specify the type of methods
#! @Description This is a special method for handling tough cases.
#! @ItemType Meth
InstallOtherMethod( GeneralOp, "for the tough cases",
  IsIdenticalObj,
  [IsAToughie, IsEvenWorse],
  function (t, w) return DoStuff(t, w);
end );
#! The coverage of this test file could be extended further
