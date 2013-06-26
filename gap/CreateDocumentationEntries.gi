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
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method CreateDocEntryForCategory must be called with 3, 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "third argument must be a string or a list of strings" );
            
        fi;
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments := arg[ 4 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
                
            elif IsList( arg[ 4 ] ) and not IsString( arg[ 4 ] ) then
                
                chapter_info := arg[ 4 ];
                
                arguments := "arg";
                
            else
                
                Error( "the 4th argument is unrecognized" );
                
            fi;
            
        elif Length( arg ) = 5 then
            
            arguments := arg[ 4 ];
            
            chapter_info := arg[ 5 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Filt", arguments, name, tester_names, "<C>true</C> or <C>false</C>", description );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForRepresentation,

  function( arg )
    local name, tester, req_entries, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method DeclareCategoryWithDocumentation must be called with 4, 5 or 6 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    req_entries := arg[ 3 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 4 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "4th argument must be a string or a list of strings" );
            
        fi;
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments := arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := "arg";
                
            else
                
                Error( "the 4th argument is unrecognized" );
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Filt", arguments, name, tester_names, "<C>true</C> or <C>false</C>", description );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );

##
InstallGlobalFunction( CreateDocEntryForOperation,

  function( arg )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method CreateDocEntryForOperation must be called with 4, 5, or 6 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "third argument must be a string or a list of strings" );
            
        fi;
        
        return_value := arg[ 4 ];
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments :=  arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
                
                arguments := JoinStringsWithSeparator( arguments );
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
            
            arguments := JoinStringsWithSeparator( arguments );
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
            
        fi;
        
        tester_names := List( tester, i -> ShallowCopy( NamesFilter( i ) ) );
        
        for j in [ 1 .. Length( tester_names ) ] do
            
            for i in [ 1 .. Length( tester_names[ j ] ) ] do
                
                if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                    
                    Remove( tester_names[ j ], i );
                    
                fi;
                
            od;
            
            
            if Length( tester_names[ j ] ) = 0 then
                
                tester_names[ j ] := "IsObject";
                
            else
                
                tester_names[ j ] := JoinStringsWithSeparator( tester_names[ j ], " and " );
                
            fi;
            
        od;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        tester_names := JoinStringsWithSeparator( tester_names, ", " );
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Oper", arguments, name, tester_names, return_value, description );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( CreateDocEntryForAttribute,

  function( arg )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method CreateDocEntryWithAttribute must be called with 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    return_value := arg[ 4 ];
    
    if Length( arg ) = 5 then
        
        arguments := arg[ 5 ];
        
    else
        
        arguments := "arg";
        
    fi;
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "third argument must be a string or a list of strings" );
            
        fi;
        
        return_value := arg[ 4 ];
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments :=  arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.attributes;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := "arg";
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.attributes;
            
        fi;
      
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Attr", arguments, name, tester_names, return_value, description );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );

InstallGlobalFunction( CreateDocEntryForProperty,

  function( arg )
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method CreateDocEntryWithProperty must be called with 3, 4, or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "third argument must be a string or a list of strings" );
            
        fi;
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments := arg[ 4 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.properties;
                
            elif IsList( arg[ 4 ] ) and not IsString( arg[ 4 ] ) then
                
                chapter_info := arg[ 4 ];
                
                arguments := "arg";
                
            else
                
                Error( "the 4th argument is unrecognized" );
                
            fi;
            
        elif Length( arg ) = 5 then
            
            arguments := arg[ 4 ];
            
            chapter_info := arg[ 5 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.properties;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Prop", arguments, name, tester_names, "<C>true</C> or <C>false</C>", description );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );
