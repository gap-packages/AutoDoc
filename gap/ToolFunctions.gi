#############################################################################
##
##  ToolFunctions.gi                      AutoDoc package
##
##  Copyright 2007-2013,   Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, University of Kaiserslautern
##
##  Some tools
##
#############################################################################

##
InstallGlobalFunction( AutoDoc_CreateCompleteEntry,
                       
  function( argument_record )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream, grouping, is_grouped,
          option_record, label_list, current_rec_entry;
    
    if not AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        return true;
        
    fi;
    
    if not IsRecord( argument_record ) then
        
        Error( "First argument must be a record" );
        
        return fail;
        
    fi;
    
    for i in [ "type", "name", "tester", "description", "return_value" ] do
        
        if not IsBound( argument_record.(i) ) then
            
            Error( Concatenation( "Component ", i, " must be bound in record" ) );
            
            return fail;
            
        fi;
        
    od;
    
    name := argument_record.name;
    
    tester := argument_record.tester;
    
    if tester <> fail then
        
        if not IsList( tester ) then
            
            tester := [ tester ];
            
        fi;
        
        if IsString( tester ) then
            
            tester_names := tester;
            
        else
            
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
            
            tester_names := JoinStringsWithSeparator( tester_names, ", " );
            
            tester_names := Concatenation( "for ", tester_names );
            
        fi;
        
    else
        
        tester_names := fail;
        
    fi;
    
    description := argument_record.description;
    
    if IsString( description ) then
        
        description := [ description ];
        
    fi;
    
    if not ForAll( description, IsString ) then
        
        Error( "third argument must be a string or a list of strings" );
        
    fi;
    
    return_value := argument_record.return_value;
    
    for current_rec_entry in argument_record.optional_arguments do
        
        ##Check for option record
        if IsRecord( current_rec_entry ) then
            
            option_record := current_rec_entry;
            
            continue;
            
        fi;
        
        ##Check for chapter info
        if IsList( current_rec_entry ) and Length( current_rec_entry ) = 2 and ForAll( current_rec_entry, IsString ) then
            
            chapter_info := current_rec_entry;
            
            continue;
            
        fi;
        
        ##Check for arguments
        if IsString( current_rec_entry ) then
            
            arguments := current_rec_entry;
            
            continue;
            
        fi;
        
    od;
    
    ##Set standard values for chapter and arguments
    
    if not IsBound( chapter_info ) then
        
        if not IsBound( argument_record.doc_stream_type ) then
            
            Error( "Cannot figure out which chapter :(" );
            
            return fail;
            
        fi;
        
        chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.( argument_record.doc_stream_type );
        
    fi;
    
    if argument_record.type = "Var" then
        
        arguments := fail;
        
    fi;
    
    if not IsBound( arguments ) then
        
        if IsBound( tester ) then
            
            arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( "arg", String( i ) ) );
            
            arguments := JoinStringsWithSeparator( arguments, "," );
            
        else
            
            arguments := "";
            
        fi;
        
    fi;
    
    if not IsBound( option_record ) then
        
        option_record := rec( );
        
    fi;
    
    if IsBound( option_record.group ) then
        
        is_grouped := true;
        
        grouping := option_record.group;
        
        if not IsString( grouping ) then
            
            Error( "group name must be a string." );
            
        fi;
        
    else
        
        is_grouped := false;
        
    fi;
    
    if return_value <> fail and Length( return_value ) = 0 then
        
        return_value := "Nothing";
        
    fi;
    
    if IsBound( option_record.function_label ) and IsString( option_record.function_label ) then
        
        tester_names := option_record.function_label;
        
    fi;
    
    label_list := [ ];
    
    if IsBound( option_record.label ) and IsString( option_record.label ) then
        
        label_list := [ option_record.label ];
        
    fi;
    
    label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] },
                                          String( Random( GlobalMersenneTwister, 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
    
    if is_grouped and not IsBound( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping) ) then
        
        AUTOMATIC_DOCUMENTATION.grouped_items.(grouping) := rec( elements := [ ],
                                                                 description := [ ],
                                                                 label_rand_hash := label_rand_hash,
                                                                 chapter_info := chapter_info,
                                                                 return_value := "",
                                                                 label_list := label_list,
                                                                );
        
        CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    elif not is_grouped then
        
        CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
        
    if is_grouped then
        
        Add( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).elements, [ argument_record.type, arguments, name, tester_names ] );
        
        AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).description := Concatenation( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).description, description );
        
        AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).return_value := return_value;
        
        AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).label_list := Concatenation( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).label_list, label_list );
        
    else
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AutoDoc_WriteEntry( doc_stream, label_rand_hash, argument_record.type, arguments, name, tester_names, return_value, description, label_list );
    
    fi;
    
    return true;
    
end );

##
InstallGlobalFunction( AutoDoc_WriteEntry,
                       
  function( doc_stream, label, type, arguments, name, tester_names, return_value, description, label_for_mansection )
    local i;
    
    AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label , "\">\n" );
    AppendTo( doc_stream, "##  <ManSection" );
    Perform( label_for_mansection, function( i ) AppendTo( doc_stream, " Label=\"", i, "\"" ); end );
    AppendTo( doc_stream, ">\n" );
    AppendTo( doc_stream, "##    <", type );
    
    if arguments <> fail then
        AppendTo( doc_stream, " Arg=\"", arguments, "\"" );
    fi;
    
    AppendTo( doc_stream, " Name=\"", name, "\"" );
    
    if tester_names <> fail then
        AppendTo( doc_stream, " Label=\"", tester_names, "\"" );
    fi;
    
    AppendTo( doc_stream, "/>\n" );
    
    if return_value <> fail then
        AppendTo( doc_stream, "##    <Returns>", return_value, "</Returns>\n" );
    fi;
    
    AppendTo( doc_stream, "##    <Description>\n" );
    
    for i in description do
        
        AppendTo( doc_stream, Concatenation( [ "##      ", i, "\n" ] ) );
        
    od;
    
    AppendTo( doc_stream, "##    </Description>\n" );
    AppendTo( doc_stream, "##  </ManSection>\n" );
    AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
    AppendTo( doc_stream, "##\n\n" );
    
end );

##
InstallGlobalFunction( AutoDoc_WriteGroupedEntry,
                       
  function( doc_stream, label, list_of_type_arg_name_testernames, return_value, description, label_list )
    local i;
    
    AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label , "\">\n" );
    AppendTo( doc_stream, "##  <ManSection" );
    Perform( label_list, function( i ) AppendTo( doc_stream, " Label=\"", i, "\"" ); end );
    AppendTo( doc_stream, ">\n" );
    
    for i in list_of_type_arg_name_testernames do
        
         AppendTo( doc_stream, "##    <", i[ 1 ], " " );
        
        if i[ 2 ] <> fail and i[ 1 ] <> "Var" then
            AppendTo( doc_stream, "Arg=\"", i[ 2 ], "\" " );
        fi;
        
        AppendTo( doc_stream, "Name=\"", i[ 3 ], "\" " );
        
        if i[ 4 ] <> fail then
            AppendTo( doc_stream, "Label=\"", i[ 4 ], "\"" );
        fi;
        
        AppendTo( doc_stream, "/>\n" );
        
    od;
    
    if return_value <> fail then
        AppendTo( doc_stream, "##    <Returns>", return_value, "</Returns>\n" );
    fi;
    
    AppendTo( doc_stream, "##    <Description>\n" );
    
    for i in description do
        
        AppendTo( doc_stream, Concatenation( [ "##      ", i, "\n" ] ) );
        
    od;
    
    AppendTo( doc_stream, "##    </Description>\n" );
    AppendTo( doc_stream, "##  </ManSection>\n" );
    AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
    AppendTo( doc_stream, "##\n\n" );
    
end );
