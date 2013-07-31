#############################################################################
##
##  CreateDocumentationEntry.gd                      AutoDoc package
##
##  Copyright 2007-2013,   Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, University of Kaiserslautern
##
##  A new way to create Methods.
##
#############################################################################

##
InstallGlobalFunction( CreateDocEntryForCategory,
                       
  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 3 ],
                         return_value := "<C>true</C> or <C>false</C>",
                         type := "Filt",
                         doc_stream_type := "categories",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 3 then
        
        for i in [ 4 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 3 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForRepresentation,

  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 4 ],
                         return_value := "<C>true</C> or <C>false</C>",
                         type := "Filt",
                         doc_stream_type := "categories",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 4 then
        
        for i in [ 5 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 4 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForOperation,

  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 3 ],
                         return_value := arg[ 4 ],
                         type := "Oper",
                         doc_stream_type := "methods",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 4 then
        
        for i in [ 5 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 4 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForAttribute,

  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 3 ],
                         return_value := arg[ 4 ],
                         type := "Attr",
                         doc_stream_type := "attributes",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 4 then
        
        for i in [ 5 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 4 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForProperty,

  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 3 ],
                         return_value := "<C>true</C> or <C>false</C>",
                         type := "Prop",
                         doc_stream_type := "properties",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 3 then
        
        for i in [ 4 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 3 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForGlobalFunction,
                       
  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := "",
                         description := arg[ 2 ],
                         return_value := arg[ 3 ],
                         type := "Func",
                         doc_stream_type := "global_functions",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 3 then
        
        for i in [ 4 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 3 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForGlobalVariable,
                       
  function( arg )
    local name_list, argument_rec, i;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not Length( arg ) in [ 2 .. 5 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := [ ],
                         description := arg[ 2 ],
                         return_value := fail,
                         type := "Var",
                         doc_stream_type := "global_variables",
                       );
    
    name_list := [ "first", "second", "third" ];
    
    if Length( arg ) > 2 then
        
        for i in [ 3 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i - 2 ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForInstallMethod,
                       
  function( arg )
    local argument_rec, i, name_list;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    argument_rec := rec( name := NameFunction( arg[ 1 ] ),
                         tester := arg[ 3 ],
                         description := arg[ 4 ],
                         return_value := arg[ 5 ],
                         type := "Meth",
                         doc_stream_type := "operations" );
    
    if Length( arg ) > 6 then
        
        name_list := [ "first", "second", "third" ];
        
        arg := arg{ [ 6 .. Length( arg ) - 1 ] };
        
        for i in [ 1 .. Length( arg ) ] do
            
            argument_rec.( Concatenation( name_list[ i ], "_optional_argument" ) ) := arg[ i ];
            
        od;
        
    fi;
    
    AutoDoc_CreateCompleteEntry( argument_rec );
    
    return true;
    
end );
