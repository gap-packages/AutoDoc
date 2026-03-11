#
# AutoDocTest: A minimal GAP package for testing AutoDoc features
#
# Declarations
#

#!
#! @Chapter Source API
#! @ChapterLabel SourceAPI
#! @Section Declarations
#! @SectionLabel SourceDeclarations
#! `AutoDocTest_GlobalFunction` is a documented placeholder used by the
#! package-context regression manual.
DeclareGlobalFunction( "AutoDocTest_GlobalFunction" );

#!
#! `AutoDocTest_Operation` takes an object together with a positive integer
#! and returns that integer unchanged.
DeclareOperation( "AutoDocTest_Operation", [ IsObject, IsInt ] );

#!
#! `AutoDocTest_Attribute` records a small attribute entry for solvable groups.
DeclareAttribute( "AutoDocTest_Attribute", IsGroup );

#!
#! `AutoDocTest_Property` is a tiny property used to exercise method docs.
DeclareProperty( "AutoDocTest_Property", IsGroup );
