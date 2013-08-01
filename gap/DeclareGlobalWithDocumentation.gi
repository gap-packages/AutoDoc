#############################################################################
##
##  AutoDoc package
##
##  Copyright 2007-2013,   Sebastian Gutsche, University of Kaiserslautern
##                         Max Horn, Justus-Liebig-Universität Gießen
##
##  
##
#############################################################################

##
## Call this with arguments name, return value, description, arguments as string, chapter and section as a list of two strings. The last two are optional
InstallGlobalFunction( DeclareGlobalFunctionWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalFunction( name );
    
    CallFuncList( CreateDocEntryForGlobalFunction, arg );
    
    return true;
    
end );

##
## Call this with arguments name, description, chapter and section as a list of two strings. The last one is optional
InstallGlobalFunction( DeclareGlobalVariableWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalVariable( name );
    
    CallFuncList( CreateDocEntryForGlobalVariable, arg );
    
    return true;
    
end );