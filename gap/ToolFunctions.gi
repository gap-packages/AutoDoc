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

InstallGlobalFunction( "AUTODOC_OutputTextFile",
                       
function( arg )
    local filename, filestream;
    if Length( arg ) = 1 then
        filename := arg[1];
    else
        filename := Filename( arg[1], arg[2] );
    fi;
    
    filestream := OutputTextFile( filename, false );
    SetPrintFormattingStatus( filestream, false );
    
    return filestream;
    
end );


##
InstallGlobalFunction( AutoDoc_CreateCompleteEntry,
                       
  function( argument_record )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, doc_stream, grouping, is_grouped,
          option_record, label_list, current_rec_entry, entry_record;
    
    if not ( AUTOMATIC_DOCUMENTATION.enable_documentation and AUTOMATIC_DOCUMENTATION.package_name = CURRENT_NAMESPACE() ) then
        
        return true;
        
    fi;
    
    if not IsRecord( argument_record ) then
        
        Error( "First argument must be a record" );
        
        return fail;
        
    fi;
    
    entry_record := rec( );
    
    for i in [ "type", "name", "tester", "description", "return_value" ] do
        
        if not IsBound( argument_record.(i) ) then
            
            Error( Concatenation( "Component ", i, " must be bound in record" ) );
            
            return fail;
            
        fi;
        
    od;
    
    entry_record.type := argument_record.type;
    
    entry_record.name := argument_record.name;
    
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
                
                i := 1;
                
                while i <= Length( tester_names[j] ) do
                    
                    if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                        
                        Remove( tester_names[ j ], i );
                        
                    else
                        
                        i := i + 1;
                        
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
    
    entry_record.tester_names := tester_names;
    
    description := argument_record.description;
    
    if IsString( description ) then
        
        description := [ description ];
        
    fi;
    
    if not ForAll( description, IsString ) then
        
        Error( "third argument must be a string or a list of strings" );
        
    fi;
    
    entry_record.description := description;
    
    entry_record.return_value := argument_record.return_value;
    
    for current_rec_entry in argument_record.optional_arguments do
        
        ##Check for option record
        if IsRecord( current_rec_entry ) then
            
            option_record := current_rec_entry;
            
            continue;
            
        fi;
        
        ##Check for chapter info
        if IsList( current_rec_entry ) and Length( current_rec_entry ) = 2 and ForAll( current_rec_entry, IsString ) then
            
            chapter_info := List( current_rec_entry, i -> ReplacedString( i, " ", "_" ) );
            
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
        
        if IsBound( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name ) and
           IsBound( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name ) then
            
            chapter_info := [ AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name,
                              AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name ];
        
        elif IsBound( argument_record.doc_stream_type ) then
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.( argument_record.doc_stream_type );
            
        else
            
            Error( "Cannot figure out which chapter :(" );
            
            return fail;
            
        fi;
        
    fi;
    
    entry_record.chapter_info := chapter_info;
    
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
    
    entry_record.arguments := arguments;
    
    if not IsBound( option_record ) then
        
        option_record := rec( );
        
    fi;
    
    if IsBound( option_record.group ) then
        
        is_grouped := true;
        
        entry_record.group := option_record.group;
        
        if not IsString( entry_record.group ) then
            
            Error( "group name must be a string." );
            
        fi;
        
    else
        
        is_grouped := false;
        
    fi;
    
    if IsBound( option_record.function_label ) and IsString( option_record.function_label ) then
        
        entry_record.tester_names := option_record.function_label;
        
    fi;
    
    entry_record.label_list := [ ];
    
    if IsBound( option_record.label ) and IsString( option_record.label ) then
        
        entry_record.label_list := [ option_record.label ];
        
    fi;
    
    Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationItem( entry_record ) );
    
end );

##
InstallGlobalFunction( AutoDoc_CreateCompleteEntry_WithOptions,
                       
  function( arg )
    local return_record, current_option, opt_rec, i;
    
    return_record := rec( name := ValueOption( "name" ),
                          tester := ValueOption( "tester" )
    );
    
    ## These should be set every time
    for i in [ "type", "doc_stream_type" ] do
        
        return_record.( i ) := ValueOption( i );
        
    od;
    
    current_option := ValueOption( "description" );
    
    if current_option <> fail then
        
        return_record.description := current_option;
        
    else
        
        return_record.description := "";
        
    fi;
    
    current_option := ValueOption( "return_value" );
    
    if current_option = fail then
        
        return_record.return_value := "";
        
    else
        
        return_record.return_value := current_option;
        
    fi;
    
    return_record!.optional_arguments := [ ];
    
    for i in [ "arguments", "chapter_info" ] do
        
        current_option := ValueOption( i );
        
        if current_option <> fail then
            
            Add( return_record!.optional_arguments, current_option );
            
        fi;
        
    od;
    
    opt_rec := rec( );
    
    for i in [ "group", "label", "function_label" ] do
        
        current_option := ValueOption( i );
        
        if current_option <> fail then
            
            opt_rec.( i ) := current_option;
            
        fi;
        
    od;
    
    Add( return_record!.optional_arguments, opt_rec );
    
    AutoDoc_CreateCompleteEntry( return_record );
    
end );

##
InstallGlobalFunction( AutoDoc_WriteDocEntry,
                       
  function( filestream, list_of_records )
    local return_value, description, current_description, labels, i;
    
    ##look for a good return value (it should be the same everywhere)
    for i in list_of_records do
        
        if IsBound( i.return_value ) then
            
            if IsList( i.return_value ) and Length( i.return_value ) > 0 then
                
                return_value := i.return_value;
                
                break;
                
            elif IsBool( i.return_value ) then
                
                return_value := i.return_value;
                
                break;
                
            fi;
            
        fi;
        
    od;
    
    ## Default.
    if not IsBound( return_value ) then
        
        return_value := "";
        
    fi;
    
    description := [ ];
    
    ##collect description (for readability not in the loop above)
    for i in list_of_records do
        
        current_description := i.description;
        
        if IsString( current_description ) then
            
            current_description := [ current_description ];
            
        fi;
        
        description := Concatenation( description, current_description );
        
    od;
    
    labels := [ ];
    
    for i in list_of_records do
        
        if IsBound( i.group ) and IsString( i.group ) then
            
            Add( labels, i.group );
            
        fi;
        
    od;
    
    if Length( labels ) > 1 then
        
        labels :=  [ labels[ 1 ] ];
        
    fi;
    
    ## Write stuff out
    
    ##First labels, this has no effect in the current GAPDoc, btw.
    AppendTo( filestream, "<ManSection" );
    Perform( labels, function( i ) AppendTo( filestream, " Label=\"", i, "\"" ); end );
    AppendTo( filestream, ">\n" );
    
    ## Function heades
    for i in list_of_records do
        
         AppendTo( filestream, "  <", i.type, " " );
        
        if i.arguments <> fail and i.type <> "Var" then
            AppendTo( filestream, "Arg=\"", i.arguments, "\" " );
        fi;
        
        AppendTo( filestream, "Name=\"", i.name, "\" " );
        
        if i.tester_names <> fail and i.tester_names <> "" then
            AppendTo( filestream, "Label=\"", i.tester_names, "\"" );
        fi;
        
        AppendTo( filestream, "/>\n" );
        
    od;
    
    if return_value <> false then
        AppendTo( filestream, " <Returns>", return_value, "</Returns>\n" );
    fi;
    
    AppendTo( filestream, " <Description>\n" );
    
    for i in description do
        
        AppendTo( filestream, Concatenation( [ "    ", i, "\n" ] ) );
        
    od;
    
    AppendTo( filestream, " </Description>\n" );
    AppendTo( filestream, "</ManSection>\n\n" );
    
end );
