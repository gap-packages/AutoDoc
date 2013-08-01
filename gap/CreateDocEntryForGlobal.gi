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