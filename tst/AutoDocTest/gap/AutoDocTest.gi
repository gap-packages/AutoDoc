#
# AutoDocTest: A minimal GAP package for testing AutoDoc features
#
# Implementations
#

#!
#! @Chapter Source API
#! @ChapterLabel SourceAPI
#! @Section Implementations
#! @SectionLabel SourceImplementations
#! The global function prints a stable sentence so it is easy to mention in the
#! mock manual.
InstallGlobalFunction( AutoDocTest_GlobalFunction,
function()
    Print( "This is a placeholder function, replace it with your own code.\n" );
end );

#!
#! The method for `AutoDocTest_Operation` returns the second argument.
InstallMethod( AutoDocTest_Operation, [ IsGroup, IsPosInt ], { G, n } -> n );

#!
#! The attribute method simply returns the group itself.
InstallMethod( AutoDocTest_Attribute, [ IsSolvableGroup ], G -> G );

#!
#! The property method reuses `IsAbelian` for nilpotent groups.
InstallMethod( AutoDocTest_Property, [ IsNilpotentGroup ], IsAbelian );
