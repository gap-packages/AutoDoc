#############################################################################
##
##  InstallMethodWithDocumentation.gi         AutoDoc package
##
##  Copyright 2007-2012, Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, RWTH-Aachen University
##                  Markus Lange-Hegermann, RWTH-Aachen University
##
##  A new way to create Methods.
##
#############################################################################

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareCategoryWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareCategory( name, tester );
    
    CallFuncList( CreateDocEntryForCategory, arg );
    
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
    
    CallFuncList( CreateDocEntryForRepresentation, arg );
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareOperation( name, tester );
    
    CallFuncList( CreateDocEntryForOperation, arg );
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( DeclareAttributeWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareAttribute( name, tester );
    
    CallFuncList( CreateDocEntryForAttribute, arg );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclarePropertyWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareProperty( name, tester );
    
    CallFuncList( CreateDocEntryForProperty, arg );
    
end );

##
## Call this with arguments name, return value, description, arguments as string, chapter and section as a list of two strings. The last two are optional
InstallGlobalFunction( DeclareGlobalFunctionWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalFunction( name );
    
    CallFuncList( CreateDocEntryForGlobalFunction, arg );
    
end );

##
## Call this with arguments name, description, chapter and section as a list of two strings. The last one is optional
InstallGlobalFunction( DeclareGlobalVariableWithDocumentation,

  function( arg )
    local name;
    
    name := arg[ 1 ];
    
    DeclareGlobalVariable( name );
    
    CallFuncList( CreateDocEntryForGlobalVariable, arg );
    
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
    
    CallFuncList( CreateDocEntryForInstallMethod, arg );
    
end );

##FIXME: This should be easier:

AutoDoc_InstallGlobalFunction_TempFunction := function( i )
    
    ##
    InstallGlobalFunction( ValueGlobal( Concatenation( "Declare", i, "WithDoc" ) ),
                          
      function( arg )
        
        CallFuncList( ValueGlobal( Concatenation( "Declare", i ) ), arg );
        
        CallFuncList( ValueGlobal( Concatenation( "CreateDocEntryFor", i, "_WithOptions" ) ), arg );
        
    end );
    
end;

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
    
    CallFuncList( CreateDocEntryForInstallMethod_WithOptions, arg );
    
end );
