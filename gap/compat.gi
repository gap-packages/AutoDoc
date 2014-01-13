#############################################################################
##
##  compat.gi                                         AutoDoc package
##
##  Copyright 2013, Max Horn, JLU Giessen
##                  Sebastian Gutsche, University of Kaiserslautern
##
##  Compatability layer for old AutoDoc style.
##
#############################################################################


DeclareGlobalFunction( "DeclareCategoryWithDocumentation" );

DeclareGlobalFunction( "DeclareCategoryWithDoc" );

DeclareGlobalFunction( "DeclareOperationWithDocumentation" );

DeclareGlobalFunction( "DeclareOperationWithDoc" );

DeclareGlobalFunction( "InstallMethodWithDocumentation" );

DeclareGlobalFunction( "InstallMethodWithDoc" );

DeclareGlobalFunction( "DeclareRepresentationWithDocumentation" );

DeclareGlobalFunction( "DeclareRepresentationWithDoc" );

DeclareGlobalFunction( "DeclareAttributeWithDocumentation" );

DeclareGlobalFunction( "DeclareAttributeWithDoc" );

DeclareGlobalFunction( "DeclarePropertyWithDocumentation" );

DeclareGlobalFunction( "DeclarePropertyWithDoc" );

DeclareGlobalFunction( "DeclareGlobalFunctionWithDocumentation" );

DeclareGlobalFunction( "DeclareGlobalFunctionWithDoc" );

DeclareGlobalFunction( "DeclareGlobalVariableWithDocumentation" );

DeclareGlobalFunction( "DeclareGlobalVariableWithDoc" );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareCategoryWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareCategory( name, tester );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareRepresentationWithDocumentation,

  function( arg )
    local name, tester, req_entries;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    req_entries := arg[ 3 ];
    
    DeclareRepresentation( name, tester, req_entries );
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareOperation( name, tester );
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( DeclareAttributeWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareAttribute( name, tester );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclarePropertyWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareProperty( name, tester );
    
end );

##
## Call this with arguments name, return value, description, arguments as string, chapter and section as a list of two strings. The last two are optional
InstallGlobalFunction( DeclareGlobalFunctionWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalFunction( name );
    
end );

##
## Call this with arguments name, description, chapter and section as a list of two strings. The last one is optional
InstallGlobalFunction( DeclareGlobalVariableWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalVariable( name );
    
end );

##
## Call this with arguments function name, short description, list of tester, return value, description, arguments as list or string,
## chapter and section info, and function. 6 and 7 are optional
InstallGlobalFunction( InstallMethodWithDocumentation,

  function( arg )
    local name, short_descr, tester, func;
    
    name := arg[ 1 ];
    
    short_descr := arg[ 2 ];
    
    tester := arg[ 3 ];
    
    func := arg[ Length( arg ) ];
    
    InstallMethod( name, short_descr, tester, func );
    
end );

##
AutoDoc_InstallGlobalFunction_TempFunction := function( i )
    
    ##
    InstallGlobalFunction( ValueGlobal( Concatenation( "Declare", i, "WithDoc" ) ),
                          
      function( arg )
        
        CallFuncList( ValueGlobal( Concatenation( "Declare", i ) ), arg );
        
    end );
    
end;

##
BindGlobal( "AUTODOC_Create_certain_with_Options_functions",
  
  function()
    local i;

    for i in [ "Category", "Representation",
              "Property", "Attribute", "Operation",
              "GlobalFunction", "GlobalVariable" ] do

        
        ## And that's why we LOVE GAP.
        
        AutoDoc_InstallGlobalFunction_TempFunction( i );
        
    od;
    
end );

AUTODOC_Create_certain_with_Options_functions();

##
InstallGlobalFunction( InstallMethodWithDoc,
                       
  function( arg )
    
    CallFuncList( InstallMethod, arg );
    
end );

DeclareGlobalFunction( "CreateAutomaticDocumentation" );

InstallGlobalFunction( CreateAutomaticDocumentation,

  function( arg_rec )
    local path_to_xmlfiles, tree;
    
    path_to_xmlfiles := arg_rec.path_to_xmlfiles;
    
    if IsString( path_to_xmlfiles ) then
        path_to_xmlfiles := Directory( path_to_xmlfiles );
    fi;
    
    tree := arg_rec.tree;
    
    WriteDocumentation( tree, path_to_xmlfiles );
    
    return true;

end );
