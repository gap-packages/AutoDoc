#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

##
InstallGlobalFunction( Normalized_ReadLine,
                       
  function( stream )
    local string;
    
    string := ReadLine( stream );
    
    if string = fail then
        
        return fail;
        
    fi;
    
    NormalizeWhitespace( string );
    
    return string;
    
end );

##
InstallGlobalFunction( Scan_for_AutoDoc_Part,
                       
  function( line )
    local position, whitespace_position, command, argument;
    
    #! @DONT_SCAN_NEXT_LINE
    position := PositionSublist( line, "#!" );
    
    if position = fail then
        
        return [ false, line ];
        
    fi;
    
    line := StripBeginEnd( line{[ position + 2 .. Length( line ) ]}, " " );
    
    ## Scan for a command
    
    position := PositionSublist( line, "@" );
    
    if position = fail then
        
        return [ "STRING", line ];
        
    fi;
    
    whitespace_position := PositionSublist( line, " " );
    
    if whitespace_position = fail then
        
        command := line{[ position .. Length( line ) ]};
        
        argument := "";
        
    else
        
        command := line{[ position .. whitespace_position - 1 ]};
        
        argument := line{[ whitespace_position + 1 .. Length( line ) ]};
        
    fi;
    
    return [ command, argument ];
    
end );

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
                       
  function( current_item, type, default_chapter_data )
    local item_rec, entries, has_filters, ret_val;
    
    item_rec := current_item;
    
    if type = "Category" then
        
        entries := [ "Filt", "categories" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Representation" then
        
        entries := [ "Filt", "categories" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Attribute" then
        
        entries := [ "Attr", "attributes" ];
        
        has_filters := "One";
        
    elif type = "Property" then
        
        entries := [ "Prop", "properties" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Operation" then
        
        entries := [ "Oper", "methods" ];
        
        has_filters := "List";
        
    elif type = "GlobalFunction" then
        
        entries := [ "Func", "global_functions" ];
        
        has_filters := "No";
        
        if not IsBound( item_rec.arguments ) then
            
            item_rec.arguments := "arg";
            
        fi;
        
    elif type = "GlobalVariable" then
        
        entries := [ "Var", "global_variables" ];
        
        has_filters := "No";
        
        item_rec.arguments := fail;
        
    else
        
        return fail;
        
    fi;
    
    item_rec!.item_type := entries[ 1 ];
    
    item_rec!.doc_stream_type := entries[ 2 ];
    
    if not IsBound( item_rec!.chapter_info ) then
        item_rec!.chapter_info := default_chapter_data.( entries[ 2 ] );
    fi;
    
    if IsBound( ret_val ) and ( item_rec!.return_value = [ ] or item_rec!.return_value = false ) then
        
        item_rec!.return_value := [ ret_val ];
        
    fi;
    
    return has_filters;
    
end );

##
InstallGlobalFunction( AutoDoc_Parser_ReadFiles,
                       
  function( filename_list, tree, default_chapter_data )
    local current_item, flush_and_recover, chapter_info, current_string_list,
          Scan_for_Declaration_part, flush_and_prepare_for_item, current_line, filestream,
          level_scope, scope_group, read_example, command_function_record, autodoc_read_line,
          current_command, was_declaration, filename, system_scope, groupnumber, chunk_list, rest_of_file_skipped,
          context_stack, new_man_item, add_man_item, Reset;
    
    groupnumber := 0;
    
    level_scope := 0;
    
    autodoc_read_line := false;
    
    context_stack := [ ];
    
    chapter_info := [ ];
    
    new_man_item := function( )
        local man_item;
        
        if IsTreeForDocumentationNodeForManItemRep( current_item ) then
            
            return current_item;
            
        fi;
        
        man_item := DocumentationManItem( tree );
        
        Add( context_stack, current_item );
        
        man_item!.chapter_info := ShallowCopy( chapter_info );
        
        man_item!.tester_names := fail;
        
        return man_item;
        
    end;
    
    add_man_item := function( )
        local man_item;
        
        man_item := current_item;
        
        current_item := Remove( context_stack );
        
        Add( current_item, man_item );
        
    end;
    
    Reset := function( )
        
        chapter_info := [ ];
        
        context_stack := [ ];
        
        Unbind( current_item );
        
    end;
    
    Scan_for_Declaration_part := function()
        local declare_position, current_type, filter_string, has_filters,
              position_parentesis;
        
        declare_position := PositionSublist( current_line, "Declare" );
        
        if declare_position <> fail then
            
            current_item := new_man_item();
            
            current_line := current_line{[ declare_position + 7 .. Length( current_line ) ]};
            
            position_parentesis := PositionSublist( current_line, "(" );
            
            if position_parentesis = fail then
                
                Error( "Something went wrong" );
                
            fi;
            
            current_type := current_line{ [ 1 .. position_parentesis - 1 ] };
            
            has_filters := AutoDoc_Type_Of_Item( current_item, current_type, default_chapter_data );
            
            if has_filters = fail then
                
                Error( "Unrecognized scan type" );
                
                return fail;
                
            fi;
            
            current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
            
            ## Not the funny part begins:
            ## try fetching the name:
            
            ## Assuming the name is in the same line as its 
            while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                
                current_line := Normalized_ReadLine( filestream );
                
            od;
            
            current_line := StripBeginEnd( current_line, " " );
            
            current_item!.name := current_line{ [ 1 .. Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1 ] };
            
            current_item!.name := StripBeginEnd( ReplacedString( current_item!.name, "\"", "" ), " " );
            
            current_line := current_line{ [ Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) + 1 .. Length( current_line ) ] };
            
            if has_filters = "One" then
                
                filter_string := "for ";
                
                while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                    
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    
                    current_line := ReadLine( filestream );
                    
                    NormalizeWhitespace( current_line );
                    
                od;
                
                Append( filter_string, StripBeginEnd( current_line{ [ 1 .. Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1 ] }, " " ) );
                
            elif has_filters = "List" then
                
                filter_string := "for ";
                
                while PositionSublist( current_line, "[" ) = fail do
                    
                    current_line := ReadLine( filestream );
                    
                    NormalizeWhitespace( current_line );
                    
                od;
                
                current_line := current_line{ [ PositionSublist( current_line, "[" ) + 1 .. Length( current_line ) ] };
                
                while PositionSublist( current_line, "]" ) = fail do
                    
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    
                    current_line := ReadLine( filestream );
                    
                    NormalizeWhitespace( current_line );
                    
                od;
                
                Append( filter_string, StripBeginEnd( current_line{[ 1 .. PositionSublist( current_line, "]" ) - 1 ]}, " " ) );
                
            else
                
                filter_string := false;
                
            fi;
            
            if filter_string <> false then
                
                if current_item!.tester_names = fail then
                    
                    current_item!.tester_names := filter_string;
                    
                fi;
                
                ##Adjust arguments
                
                if not IsBound( current_item!.arguments ) then
                    
                    if has_filters = "One" then
                        
                        current_item!.arguments := "arg";
                        
                    elif has_filters = "List" then
                        
                        current_item!.arguments := List( [ 1 .. Length( SplitString( filter_string, "," ) ) ], i -> Concatenation( "arg", String( i ) ) );
                        
                        if Length( current_item!.arguments ) = 1 then
                            
                            current_item!.arguments := "arg";
                            
                        else
                            
                            current_item!.arguments := JoinStringsWithSeparator( current_item!.arguments, "," );
                            
                        fi;
                        
                    fi;
                    
                fi;
                
            fi;
            
            add_man_item();
            
            return true;
            
        fi;
        
        declare_position := PositionSublist( current_line, "InstallMethod" );
        
        if declare_position <> fail then
            
            current_item := new_man_item();
            
            current_item!.item_type := "Func";
            
            current_item!.doc_stream_type := "operations";
            
            ##Find name
            
            position_parentesis := PositionSublist( current_line, "(" );
            
            current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
            
            ## find next colon
            current_item!.name := "";
            
            while PositionSublist( current_line, "," ) = fail do
                
                Append( current_item!.name, current_line );
                
                current_line := Normalized_ReadLine( filestream );
                
            od;
            
            position_parentesis := PositionSublist( current_line, "," );
            
            Append( current_item!.name, current_line{[ 1 .. position_parentesis - 1 ]} );
            
            NormalizeWhitespace( current_item!.name );
            
            current_item!.name := StripBeginEnd( current_item!.name, " " );
            
            while PositionSublist( current_line, "[" ) = fail do
                
                current_line := Normalized_ReadLine( filestream );
                
            od;
            
            position_parentesis := PositionSublist( current_line, "[" );
            
            current_line := current_line{[ position_parentesis + 1 .. Length( current_line ) ]};
            
            filter_string := "for ";
            
            while PositionSublist( current_line, "]" ) = fail do
                
                Append( filter_string, current_line );
                
            od;
            
            position_parentesis := PositionSublist( current_line, "]" );
            
            Append( filter_string, current_line{[ 1 .. position_parentesis - 1 ]} );
            
            current_line := current_line{[ position_parentesis + 1 .. Length( current_line )]};
            
            NormalizeWhitespace( filter_string );
            
            if current_item!.tester_names = fail then
                
                current_item!.tester_names := filter_string;
                
            fi;
            
            ##Maybe find some argument names
            if not IsBound( current_item!.arguments ) then
            
                while PositionSublist( current_line, "function(" ) = fail and PositionSublist( current_line, ");" ) = fail do
                    
                    current_line := Normalized_ReadLine( filestream );
                    
                od;
                
                position_parentesis := PositionSublist( current_line, "function(" );
                
                if position_parentesis <> fail then
                    
                    current_line := current_line{[ position_parentesis + 9 .. Length( current_line ) ]};
                    
                    filter_string := "";
                    
                    while PositionSublist( current_line, ")" ) = fail do;
                        
                        current_line := StripBeginEnd( current_line, " " );
                        
                        Append( filter_string, current_line );
                        
                        current_line := Normalized_ReadLine( current_line );
                        
                    od;
                    
                    position_parentesis := PositionSublist( current_line, ")" );
                    
                    Append( filter_string, current_line{[ 1 .. position_parentesis - 1 ]} );
                    
                    NormalizeWhitespace( filter_string );
                    
                    filter_string := StripBeginEnd( filter_string, " " );
                    
                    current_item!.arguments := filter_string;
                    
                fi;
                
            fi;
            
            add_man_item();
            
            return true;
            
        fi;
        
        return false;
        
    end;
    
    read_example := function( is_tested_example )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line, item_temp, example_node;
        
        example_node := DocumentationExample( tree );
        
        example_node!.is_tested_example := is_tested_example;
        
        temp_string_list := example_node!.content;
        
        is_following_line := false;
        
        while true do
            
            temp_curr_line := ReadLine( filestream );
            
            if temp_curr_line[ Length( temp_curr_line )] = '\n' then
                
                temp_curr_line := temp_curr_line{[ 1 .. Length( temp_curr_line ) - 1 ]};
                
            fi;
            
            if filestream = fail or PositionSublist( temp_curr_line, "@EndExample" ) <> fail or PositionSublist( temp_curr_line, "@EndLog" ) <> fail then
                
                break;
                
            fi;
            
            ##if is comment, simply remove comments.
            #! @DONT_SCAN_NEXT_LINE
            temp_pos_comment := PositionSublist( temp_curr_line, "#!" );
            
            if temp_pos_comment <> fail then
                
                temp_curr_line := temp_curr_line{[ temp_pos_comment + 3 .. Length( temp_curr_line ) ]};
                
                Add( temp_string_list, temp_curr_line );
                
                is_following_line := false;
                
                continue;
                
            else
                
                if is_following_line then
                    
                    temp_curr_line := Concatenation( "> ", temp_curr_line );
                    
                    if PositionSublist( temp_curr_line, ";" ) <> fail then
                        
                        is_following_line := false;
                        
                    fi;
                    
                else
                    
                    if temp_curr_line = "" then
                        
                        continue;
                        
                    fi;
                    
                    temp_curr_line := Concatenation( "gap> ", temp_curr_line );
                    
                    is_following_line := PositionSublist( temp_curr_line, ";" ) = fail;
                    
                fi;
                
                Add( temp_string_list, temp_curr_line );
                
                continue;
                
            fi;
            
        od;
        
        return example_node;
        
    end;
    
    command_function_record := rec(
        
        ## HACK: Needed for AutoDoc parser to be scanned savely.
        ##       The lines where the AutoDoc comments are
        ##       searched cause problems otherwise.
        @DONT_SCAN_NEXT_LINE := function()
            
            ReadLine( filestream );
            
        end,
        
        @DoNotReadRestOfFile := function()
            
            Reset();
            
            rest_of_file_skipped := true;
            
        end,
        
        @AutoDoc := function()
            
            autodoc_read_line := fail;
            
        end,
        
        @EndAutoDoc := function()
            
            autodoc_read_line := false;
            
        end,
        
        @Chapter := function()
            local scope_chapter;
            
            scope_chapter := ReplacedString( current_command[ 2 ], " ", "_" );
            
            current_item := ChapterInTree( tree, scope_chapter );
            
            chapter_info[ 1 ] := scope_chapter;
            
        end,
        
        @Section := function()
            local scope_section;
            
            if not IsBound( chapter_info[ 1 ] ) then
                
                Error( "Chapter must be given" );
                
            fi;
            
            scope_section := ReplacedString( current_command[ 2 ], " ", "_" );
            
            current_item := SectionInTree( tree, chapter_info[ 1 ], scope_section );
            
            Unbind( chapter_info[ 3 ] );
            
            chapter_info[ 2 ] := scope_section;
            
        end,
        
        @EndSection := function()
            
            Unbind( chapter_info[ 2 ] );
            
            Unbind( chapter_info[ 3 ] );
            
            current_item := ChapterInTree( tree, chapter_info[ 1 ] );
            
        end,
        
        @Subsection := function()
            local scope_subsection;
            
            if not IsBound( chapter_info[ 1 ] ) or not IsBound( chapter_info[ 2 ] ) then
                
                Error( "no subsection without chapter and section" );
                
            fi;
            
            scope_subsection := ReplacedString( current_command[ 2 ], " ", "_" );
            
            current_item := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], scope_subsection );
            
            chapter_info[ 3 ] := scope_subsection;
            
        end,
        
        @EndSubsection := function()
            
            Unbind( chapter_info[ 3 ] );
            
            current_item := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
            
        end,
        
        @BeginGroup := function()
            local grp;
            
            if current_command[ 2 ] = "" then
                
                groupnumber := groupnumber + 1;
                
                current_command[ 2 ] := Concatenation( "AutoDoc_generated_group", String( groupnumber ) );
                
            fi;
            
            scope_group := ReplacedString( current_command[ 2 ], " ", "_" );
            
            grp := DocumentationGroup( tree, scope_group );
            
            Add( context_stack, current_item );
            
            Add( current_item, grp );
            
            current_item := grp;
            
        end,
        
        @EndGroup := function()
            
            current_item := Remove( context_stack );
            
        end,
        
        @Description := function()
            
            current_item := new_man_item();
            
            SetManItemToDescription( current_item );
            
            Add( current_item, current_command[ 2 ] );
            
        end,
        
        @Returns := function()
            
            current_item := new_man_item();
            
            SetManItemToReturnValue( current_item );
            
            if current_command[ 2 ] <> "" then
                
                Add( current_item, current_command[ 2 ] );
                
            fi;
            
        end,
        
        @Arguments := function()
            
            current_item := new_man_item();
            
            current_item!.arguments := current_command[ 2 ];
            
        end,
        
        @Label := function()
            
            current_item := new_man_item();
            
            current_item!.tester_names := current_command[ 2 ];
            
        end,
        
        @Group := function()
            
            current_item := new_man_item();
            
            current_item!.group := current_command[ 2 ];
            
        end,
        
        @ChapterInfo := function()
            local current_chapter_info;
            
            current_item := new_man_item();
            
            current_chapter_info := SplitString( current_command[ 2 ], "," );
            
            current_chapter_info := List( current_chapter_info, i -> ReplacedString( StripBeginEnd( i, " " ), " ", "_" ) );
            
            SetChapterInfo( current_item, current_chapter_info );
            
        end,
        
        @BREAK := function()
            
            Error( current_command[ 2 ] );
            
        end,
        
        @SetLevel := function()
            
            level_scope := Int( current_command[ 2 ] );
            
        end,
        
        @ResetLevel := function()
            
            level_scope := 0;
            
            
        end,
        
        @Level := function()
            
            current_item!.level := Int( current_command[ 2 ] );
            
        end,
        
        @InsertSystem := function()
            
            Add( current_item, DocumentationDummy( tree, current_command[ 2 ] ) );
            
        end,
        
        @System := function()
            
            current_item := DocumentationDummy( tree, current_command[ 2 ] );
            
        end,
        
        @EndSystem := function()
            
            current_item := Remove( context_stack );
            
        end,
        
        @Example := function()
            local example_node;
            
            example_node := read_example( true );
            
            Add( current_item, example_node );
            
        end,
        
        @Log := function()
            local example_node;
            
            example_node := read_example( false );
            
            Add( current_item, example_node );
            
        end,
        
        @Author := function()
            
            if not IsBound( tree!.worksheet_author ) then
                
                tree!.worksheet_author := [ ];
                
            fi;
                
            Add( tree!.worksheet_author, current_command[ 2 ] );
            
        end,
        
        @Title := function()
            
            tree!.worksheet_title := current_command[ 2 ];
            
        end,
        
        STRING := function()
            
            Add( current_item, current_command[ 2 ] );
            
        end,
        
        @Chunk := ~.@System,
        
        @EndChunk := ~.@EndSystem,
        
        @InsertChunk := ~.@InsertSystem,
        
        @BeginLatexOnly := function()
            
            Add( current_item, "<Alt Only=\"LaTeX\">" );
            
            if current_command[ 2 ] <> "" then
                
                Add( current_item, current_command[ 2 ] );
                
            fi;
            
        end,
        
        @EndLatexOnly := function()
            
            Add( current_item, "</Alt>" );
            
        end,
        
        @LatexOnly := function()
            
            Add( current_item, "<Alt Only=\"LaTeX\">" );
            
            Add( current_item, current_command[ 2 ] );
            
            Add( current_item, "</Alt>" );
            
        end,
        
        @Dependency := function()
            
            if not IsBound( tree!.worksheet_dependencies ) then
                
                tree!.worksheet_dependencies := [ ];
                
            fi;
            
            NormalizeWhitespace( current_command[ 2 ] );
            
            Add( tree!.worksheet_dependencies, SplitString( current_command[ 2 ], " " ) );
            
        end,
        
        @Date := function()
            
            tree!.worksheet_date := current_command[ 2 ];
            
        end,
        
        ## FIXME
        @Acknowledgements := function()
            
            if not IsBound( tree!.acknowledgements ) then
                
                tree!.acknowledgements := [ ];
                
            fi;
            
            current_string_list := tree!.acknowledgements;
            
        end,
        
        @URL := function()
            
            tree!.worksheet_URL_string := current_command[ 2 ];
            
        end,
        
        ## FIXME
        @Abstract := function( )
            
            if not IsBound( tree!.abstract ) then
                
                tree!.abstract := [ ];
                
            fi;
            
            current_string_list := tree!.abstract;
            
        end
        
    );
    
    rest_of_file_skipped := false;
    
    ##Now read the files.
    for filename in filename_list do
        
        Reset();
        
        filestream := InputTextFile( filename );
        
        while true do
            
            if rest_of_file_skipped = true then
                
                rest_of_file_skipped := false;
                
                break;
                
            fi;
            
            current_line := Normalized_ReadLine( filestream );
            
            if current_line = fail then
                
                break;
                
            fi;
            
            current_command := Scan_for_AutoDoc_Part( current_line );
            
            if current_command[ 1 ] <> false then
                
                command_function_record.(current_command[ 1 ])();
                
                if autodoc_read_line <> fail then
                    
                    autodoc_read_line := true;
                    
                fi;
                
                continue;
                
            fi;
            
            current_line := current_command[ 2 ];
            
            if autodoc_read_line = true or autodoc_read_line = fail then
                
                was_declaration := Scan_for_Declaration_part( );
                
                if not was_declaration and autodoc_read_line <> fail then
                    
                    autodoc_read_line := false;
                    
                fi;
                
            fi;
            
        od;
        
    od;
    
end );