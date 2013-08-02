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
    local argument_rec;
    
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
                         optional_arguments := arg{ [ 4 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForRepresentation,

  function( arg )
    local argument_rec;
    
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
                         optional_arguments := arg{ [ 5 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
InstallGlobalFunction( CreateDocEntryForOperation,

  function( arg )
    local argument_rec;
    
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
                         optional_arguments := arg{ [ 5 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForAttribute,

  function( arg )
    local argument_rec;
    
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
                         optional_arguments := arg{ [ 5 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
InstallGlobalFunction( CreateDocEntryForProperty,

  function( arg )
    local argument_rec;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := arg[ 2 ],
                         description := arg[ 3 ],
                         return_value := "<C>true</C> or <C>false</C>",
                         type := "Prop",
                         doc_stream_type := "properties",
                         optional_arguments := arg{ [ 4 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
InstallGlobalFunction( CreateDocEntryForGlobalFunction,
                       
  function( arg )
    local argument_rec;
    
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
                         optional_arguments := arg{ [ 4 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
InstallGlobalFunction( CreateDocEntryForGlobalVariable,
                       
  function( arg )
    local argument_rec;
    
    if not Length( arg ) in [ 2 .. 5 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := arg[ 1 ],
                         tester := fail,
                         description := arg[ 2 ],
                         return_value := fail,
                         type := "Var",
                         doc_stream_type := "global_variables",
                         optional_arguments := arg{ [ 3 .. Length( arg ) ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );

##
InstallGlobalFunction( CreateDocEntryForInstallMethod,
                       
  function( arg )
    local argument_rec;
    
    if not Length( arg ) in [ 6 .. 9 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    argument_rec := rec( name := NameFunction( arg[ 1 ] ),
                         tester := arg[ 3 ],
                         description := arg[ 4 ],
                         return_value := arg[ 5 ],
                         type := "Meth",
                         doc_stream_type := "methods",
                         # Ignore the last argument, which is the function being installed
                         optional_arguments := arg{ [ 6 .. Length( arg ) - 1 ] },
                       );
    
    return AutoDoc_CreateCompleteEntry( argument_rec );
    
end );
