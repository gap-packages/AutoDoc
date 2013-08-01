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
    
    return CallFuncList( CreateDocEntryForCategory, arg );
    
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
    
    return CallFuncList( CreateDocEntryForRepresentation, arg );
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareOperation( name, tester );
    
    return CallFuncList( CreateDocEntryForOperation, arg );
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( DeclareAttributeWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareAttribute( name, tester );
    
    return CallFuncList( CreateDocEntryForAttribute, arg );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclarePropertyWithDocumentation,

  function( arg )
    local name, tester;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareProperty( name, tester );
    
    return CallFuncList( CreateDocEntryForProperty, arg );
    
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
    
    return true;
    
end );
