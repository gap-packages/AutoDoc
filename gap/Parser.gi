#############################################################################
##
##  AutoDoc package
##
##  Copyright 2012-2016
##    Sebastian Gutsche, University of Kaiserslautern
##    Max Horn, Justus-Liebig-Universität Gießen
##
## Licensed under the GPL 2 or later.
##
#############################################################################

##
InstallGlobalFunction( Scan_for_AutoDoc_Part,
  function( line, plain_text_mode )
    local position, whitespace_position, command, argument;
    #! @DONT_SCAN_NEXT_LINE
    position := PositionSublist( line, "#!" );
    if position = fail and plain_text_mode = false then
        return [ false, line ];
    fi;
    if plain_text_mode <> true then
        line := StripBeginEnd( line{[ position + 2 .. Length( line ) ]}, " " );
    fi;
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


BindGlobal( "AutoDoc_PrintWarningForConstructor",
            AutoDoc_CreatePrintOnceFunction( "Installed GAPDoc version does not support constructors" ) );

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
  function( current_item, type, default_chapter_data )
    local item_rec, entries, has_filters, ret_val;
    item_rec := current_item;
    if PositionSublist( type, "DeclareCategory" ) <> fail then
        entries := [ "Filt", "categories" ];
        ret_val := "<C>true</C> or <C>false</C>";
        has_filters := 1;
    elif PositionSublist( type, "DeclareRepresentation" ) <> fail then
        entries := [ "Filt", "categories" ];
        ret_val := "<C>true</C> or <C>false</C>";
        has_filters := 1;
    elif PositionSublist( type, "DeclareAttribute" ) <> fail then
        entries := [ "Attr", "attributes" ];
        has_filters := 1;
    elif PositionSublist( type, "DeclareProperty" ) <> fail then
        entries := [ "Prop", "properties" ];
        ret_val := "<C>true</C> or <C>false</C>";
        has_filters := 1;
    elif PositionSublist( type, "DeclareOperation" ) <> fail then
        entries := [ "Oper", "methods" ];
        has_filters := "List";
    elif PositionSublist( type, "DeclareConstructor" ) <> fail then
        if IsPackageMarkedForLoading( "GAPDoc", ">=1.6.1" ) then
            entries := [ "Constr", "methods" ];
        else
            AutoDoc_PrintWarningForConstructor();
            entries := [ "Oper", "methods" ];
        fi;
        has_filters := "List";
    elif PositionSublist( type, "DeclareGlobalFunction" ) <> fail then
        entries := [ "Func", "global_functions" ];
        has_filters := "No";
        if not IsBound( item_rec!.arguments ) then
            item_rec!.arguments := "arg";
        fi;
    elif PositionSublist( type, "DeclareGlobalVariable" ) <> fail then
        entries := [ "Var", "global_variables" ];
        has_filters := "No";
        item_rec!.arguments := fail;
        item_rec!.return_value := false;
    elif PositionSublist( type, "DeclareFilter" ) <> fail then
        entries := [ "Filt", "properties" ];
        has_filters := "No";
        item_rec!.arguments := fail;
        item_rec!.return_value := false;
    elif PositionSublist( type, "DeclareInfoClass" ) <> fail then
        entries := [ "InfoClass", "info_classes" ];
        has_filters := "No";
        item_rec!.arguments := fail;
        item_rec!.return_value := false;
    elif PositionSublist( type, "KeyDependentOperation" ) <> fail then
        entries := [ "Oper", "methods" ];
        has_filters := 2;
    else
        return fail;
    fi;
    item_rec!.item_type := entries[ 1 ];
    item_rec!.doc_stream_type := entries[ 2 ];
    if not IsBound( item_rec!.chapter_info ) or item_rec!.chapter_info = [ ] then
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
          context_stack, new_man_item, add_man_item, Reset, read_code, title_item, title_item_list, plain_text_mode,
          current_line_unedited,
          ReadLineWithLineCount, Normalized_ReadLine, line_number, ErrorWithPos, create_title_item_function,
          current_line_positition_for_filter, read_session_example;
    groupnumber := 0;
    level_scope := 0;
    autodoc_read_line := false;
    context_stack := [ ];
    chapter_info := [ ];
    line_number := 0;

    ReadLineWithLineCount := function( stream )
        line_number := line_number + 1;
        return ReadLine( stream );
    end;
    Normalized_ReadLine := function( stream )
        local string;
        string := ReadLineWithLineCount( stream );
        if string = fail then
            return fail;
        fi;
        NormalizeWhitespace( string );
        return string;
    end;
    ErrorWithPos := function(arg)
        local list;
        list := Concatenation(arg, [ ",\n", "at ", filename, ":", line_number]);
        CallFuncList(Error, list);
    end;
    new_man_item := function( )
        local man_item;
        if IsBound( current_item ) and IsTreeForDocumentationNodeForManItemRep( current_item ) then
            return current_item;
        fi;
        man_item := DocumentationManItem( tree );
        if IsBound( current_item ) then
            Add( context_stack, current_item );
        fi;
        if IsBound( scope_group ) then
            SetGroupName( man_item, scope_group );
        fi;
        man_item!.chapter_info := ShallowCopy( chapter_info );
        man_item!.tester_names := fail;
        return man_item;
    end;
    add_man_item := function( )
        local man_item;
        man_item := current_item;
        if context_stack <> [ ] then
            current_item := Remove( context_stack );
        else
            Unbind( current_item );
        fi;
        if IsBound( man_item!.chapter_info ) then
            SetChapterInfo( man_item, man_item!.chapter_info );
        fi;
        if Length( ChapterInfo( man_item ) ) <> 2 then
            ErrorWithPos( "declarations must be documented within a section" );
        fi;
        Add( tree, man_item );
    end;
    Reset := function( )
        chapter_info := [ ];
        context_stack := [ ];
        Unbind( current_item );
        plain_text_mode := false;
    end;
    Scan_for_Declaration_part := function()
        local declare_position, current_type, filter_string, has_filters,
              position_parentesis, nr_of_attr_loops, i;

        ## fail is bigger than every integer
        declare_position := Minimum( [ PositionSublist( current_line, "Declare" ), PositionSublist( current_line, "KeyDependentOperation" ) ] );
        if declare_position <> fail then
            current_item := new_man_item();
            current_line := current_line{[ declare_position .. Length( current_line ) ]};
            position_parentesis := PositionSublist( current_line, "(" );
            if position_parentesis = fail then
                ErrorWithPos( "Something went wrong" );
            fi;
            current_type := current_line{ [ 1 .. position_parentesis - 1 ] };
            has_filters := AutoDoc_Type_Of_Item( current_item, current_type, default_chapter_data );
            if has_filters = fail then
                ErrorWithPos( "Unrecognized scan type" );
                return false;
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
            filter_string := "for ";
            ## FIXME: The next two if's can be merged at some point
            if IsInt( has_filters ) then
                for i in [ 1 .. has_filters ] do
                    ## We now search for the filters. A filter is either followed by a ',', if there is more than one,
                    ## or by ');' if it is the only or last one. So we search for the next delimiter.
                    while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                        Append( filter_string, StripBeginEnd( current_line, " " ) );
                        current_line := ReadLineWithLineCount( filestream );
                        NormalizeWhitespace( current_line );
                    od;
                    current_line_positition_for_filter := Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1;
                    Append( filter_string, StripBeginEnd( current_line{ [ 1 .. current_line_positition_for_filter ] }, " " ) );
                    current_line := current_line{[ current_line_positition_for_filter + 1 .. Length( current_line ) ]};
                    if current_line[ 1 ] = ',' then
                        current_line := current_line{[ 2 .. Length( current_line ) ]};
                    elif current_line[ 1 ] = ')' then
                        current_line := current_line{[ 3 .. Length( current_line ) ]};
                    fi;
                    ## FIXME: Refactor this whole if IsInt( has_filters ) case!
                    if has_filters - i > 0 then
                        Append( filter_string, ", " );
                    fi;
                od;
            elif has_filters = "List" then
                while PositionSublist( current_line, "[" ) = fail do
                    current_line := ReadLineWithLineCount( filestream );
                    NormalizeWhitespace( current_line );
                od;
                current_line := current_line{ [ PositionSublist( current_line, "[" ) + 1 .. Length( current_line ) ] };
                while PositionSublist( current_line, "]" ) = fail do
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    current_line := ReadLineWithLineCount( filestream );
                    NormalizeWhitespace( current_line );
                od;
                Append( filter_string, StripBeginEnd( current_line{[ 1 .. PositionSublist( current_line, "]" ) - 1 ]}, " " ) );
            else
                filter_string := false;
            fi;
            if IsString( filter_string ) then
                filter_string := ReplacedString( filter_string, "\"", "" );
            fi;
            if filter_string <> false then
                if current_item!.tester_names = fail and StripBeginEnd( filter_string, " " ) <> "for" then
                    current_item!.tester_names := filter_string;
                fi;
                if StripBeginEnd( filter_string, " " ) = "for" then
                    has_filters := "empty_argument_list";
                fi;
                ##Adjust arguments
                if not IsBound( current_item!.arguments ) then
                    if IsInt( has_filters ) then
                        if has_filters = 1 then
                            current_item!.arguments := "arg";
                        else
                            current_item!.arguments := JoinStringsWithSeparator( List( [ 1 .. has_filters ], i -> Concatenation( "arg", String( i ) ) ), "," );
                        fi;
                    elif has_filters = "List" then
                        current_item!.arguments := List( [ 1 .. Length( SplitString( filter_string, "," ) ) ], i -> Concatenation( "arg", String( i ) ) );
                        if Length( current_item!.arguments ) = 1 then
                            current_item!.arguments := "arg";
                        else
                            current_item!.arguments := JoinStringsWithSeparator( current_item!.arguments, "," );
                        fi;
                    elif has_filters = "empty_argument_list" then
                        current_item!.arguments := "";
                    fi;
                fi;
            fi;
            add_man_item();
            return true;
        fi;
        declare_position := Minimum( [ PositionSublist( current_line, "InstallMethod" ), PositionSublist( current_line, "InstallOtherMethod" ) ] );
                            ## Fail is larger than every integer.
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
            if IsString( filter_string ) then
                filter_string := ReplacedString( filter_string, "\"", "" );
            fi;
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
            if not IsBound( current_item!.arguments ) then
                current_item!.arguments := Length( SplitString( current_item!.tester_names, "," ) );
                current_item!.arguments := JoinStringsWithSeparator( List( [ 1 .. current_item!.arguments ], i -> Concatenation( "arg", String( i ) ) ), "," );
            fi;
            add_man_item();
            return true;
        fi;
        return false;
    end;
    read_code := function( )
        local code, temp_curr_line, comment_pos, before_comment;
        code := [ ];
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
            if temp_curr_line[ Length( temp_curr_line )] = '\n' then
                temp_curr_line := temp_curr_line{[ 1 .. Length( temp_curr_line ) - 1 ]};
            fi;
            if plain_text_mode = false then
                comment_pos := PositionSublist( temp_curr_line, "#!" );
                if comment_pos <> fail then
                    before_comment := NormalizedWhitespace( temp_curr_line{ [ 1 .. comment_pos - 1 ] } );
                    if before_comment = "" then
                        temp_curr_line := temp_curr_line{[ comment_pos + 2 .. Length( temp_curr_line ) ]};
                    fi;
                fi;
            fi;
            if filestream = fail or PositionSublist( temp_curr_line, "@EndCode" ) <> fail then
                break;
            fi;
            Add( code, temp_curr_line );
        od;
        return code;
    end;
    read_example := function( is_tested_example )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line, item_temp, example_node;
        example_node := DocumentationExample( tree );
        example_node!.is_tested_example := is_tested_example;
        temp_string_list := example_node!.content;
        is_following_line := false;
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
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
    read_session_example := function( is_tested_example )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line, item_temp, example_node;
        example_node := DocumentationExample( tree );
        if is_tested_example = false then
            example_node!.is_tested_example := false;
        else
            example_node!.is_tested_example := true;
        fi;
        temp_string_list := example_node!.content;
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
            if temp_curr_line[ Length( temp_curr_line )] = '\n' then
                temp_curr_line := temp_curr_line{[ 1 .. Length( temp_curr_line ) - 1 ]};
            fi;
            if filestream = fail or PositionSublist( temp_curr_line, "@EndExampleSession" ) <> fail
                                 or PositionSublist( temp_curr_line, "@EndLogSession" ) <> fail then
                break;
            fi;
            #! @DONT_SCAN_NEXT_LINE
            temp_pos_comment := PositionSublist( temp_curr_line, "#!" );
            if temp_pos_comment <> fail then
                temp_curr_line := temp_curr_line{[ temp_pos_comment + 2 .. Length( temp_curr_line ) ]};
                if Length( temp_curr_line ) >= 1 and temp_curr_line[ 1 ] = ' ' then
                    Remove( temp_curr_line, 1 );
                fi;
                Add( temp_string_list, temp_curr_line );
            fi;
        od;
        return example_node;
    end;
    command_function_record := rec(
        ## HACK: Needed for AutoDoc parser to be scanned savely.
        ##       The lines where the AutoDoc comments are
        ##       searched cause problems otherwise.
        @DONT_SCAN_NEXT_LINE := function()
            ReadLineWithLineCount( filestream );
        end,
        @DoNotReadRestOfFile := function()
            Reset();
            rest_of_file_skipped := true;
        end,
        @BeginAutoDoc := function()
            autodoc_read_line := fail;
        end,
        @AutoDoc := ~.@BeginAutoDoc,
        @EndAutoDoc := function()
            autodoc_read_line := false;
        end,
        @Chapter := function()
            local scope_chapter;
            scope_chapter := ReplacedString( current_command[ 2 ], " ", "_" );
            current_item := ChapterInTree( tree, scope_chapter );
            chapter_info[ 1 ] := scope_chapter;
        end,
        @ChapterLabel := function()
            local scope_chapter, label_name;
            if not IsBound( chapter_info[ 1 ] ) then
                ErrorWithPos( "found @ChapterLabel with no active chapter" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_chapter := ChapterInTree( tree, chapter_info[ 1 ] );
            scope_chapter!.additional_label := Concatenation( "Chapter_", label_name );
        end,
        @ChapterTitle := function()
            local scope_chapter;
            if not IsBound( chapter_info[ 1 ] ) then
                ErrorWithPos( "found @ChapterTitle with no active chapter" );
            fi;
            scope_chapter := ChapterInTree( tree, chapter_info[ 1 ] );
            scope_chapter!.title_string := current_command[ 2 ];
        end,
        @Section := function()
            local scope_section;
            if not IsBound( chapter_info[ 1 ] ) then
                ErrorWithPos( "found @Section with no active chapter" );
            fi;
            scope_section := ReplacedString( current_command[ 2 ], " ", "_" );
            current_item := SectionInTree( tree, chapter_info[ 1 ], scope_section );
            Unbind( chapter_info[ 3 ] );
            chapter_info[ 2 ] := scope_section;
        end,
        @SectionLabel := function()
            local scope_section, label_name;
            if not IsBound( chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionLabel with no active section" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_section := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
            scope_section!.additional_label := Concatenation( "Section_", label_name );
        end,
        @SectionTitle := function()
            local scope_section;
            if not IsBound( chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionTitle with no active section" );
            fi;
            scope_section := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
            scope_section!.title_string := current_command[ 2 ];
        end,
        @EndSection := function()
            Unbind( chapter_info[ 2 ] );
            Unbind( chapter_info[ 3 ] );
            current_item := ChapterInTree( tree, chapter_info[ 1 ] );
        end,
        @Subsection := function()
            local scope_subsection;
            if not IsBound( chapter_info[ 1 ] ) or not IsBound( chapter_info[ 2 ] ) then
                ErrorWithPos( "found @Subsection with no active section" );
            fi;
            scope_subsection := ReplacedString( current_command[ 2 ], " ", "_" );
            current_item := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], scope_subsection );
            chapter_info[ 3 ] := scope_subsection;
        end,
        @SubsectionLabel := function()
            local scope_subsection, label_name;
            if not IsBound( chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionLabel with no active Subsection" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_subsection := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], chapter_info[ 3 ] );
            scope_subsection!.additional_label := Concatenation( "Subsection_", label_name );
        end,
        @SubsectionTitle := function()
            local scope_subsection;
            if not IsBound( chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionTitle with no active section" );
            fi;
            scope_subsection := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], chapter_info[ 3 ] );
            scope_subsection!.title_string := current_command[ 2 ];
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
        end,
        @EndGroup := function()
            Unbind( scope_group );
        end,
        @Description := function()
            current_item := new_man_item();
            SetManItemToDescription( current_item );
            NormalizeWhitespace( current_command[ 2 ] );
            if current_command[ 2 ] <> "" then
                Add( current_item, current_command[ 2 ] );
            fi;
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
            local group_name;
            current_item := new_man_item();
            group_name := ReplacedString( current_command[ 2 ], " ", "_" );
            SetGroupName( current_item, group_name );
        end,
        @ChapterInfo := function()
            local current_chapter_info;
            current_item := new_man_item();
            current_chapter_info := SplitString( current_command[ 2 ], "," );
            current_chapter_info := List( current_chapter_info, i -> ReplacedString( StripBeginEnd( i, " " ), " ", "_" ) );
            SetChapterInfo( current_item, current_chapter_info );
        end,
        @BREAK := function()
            ErrorWithPos( current_command[ 2 ] );
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
        @InsertChunk := function()
            Add( current_item, DocumentationDummy( tree, current_command[ 2 ] ) );
        end,
        @InsertSystem := ~.@InsertChunk,
        @BeginChunk := function()
            if IsBound( current_item ) then
                Add( context_stack, current_item );
            fi;
            current_item := DocumentationDummy( tree, current_command[ 2 ] );
        end,
        @Chunk := ~.@BeginChunk,
        @System := ~.@BeginChunk,
        @BeginSystem := ~.@BeginChunk,
        @BeginCode := function()
            local tmp_system;
            tmp_system := DocumentationCode( tree, current_command[ 2 ] );
            Append( tmp_system!.content, read_code() );
        end,
        @Code := ~.@BeginCode,
        @InsertCode := ~.@InsertSystem,
        @EndChunk := function()
            if autodoc_read_line = true then
                autodoc_read_line := false;
            fi;
            if context_stack <> [ ] then
                current_item := Remove( context_stack );
            else
                Unbind( current_item );
            fi;
        end,
        @EndSystem := ~.@EndChunk,
        @BeginExample := function()
            local example_node;
            example_node := read_example( true );
            Add( current_item, example_node );
        end,
        @Example := ~.@BeginExample,
        @BeginLog := function()
            local example_node;
            example_node := read_example( false );
            Add( current_item, example_node );
        end,
        @Log := ~.@BeginLog,
        STRING := function()
            local comment_pos;
            if not IsBound( current_item ) then
                return;
            fi;
            comment_pos := PositionSublist( current_line_unedited, "#!" );
            if comment_pos <> fail then
                current_line_unedited := current_line_unedited{[ comment_pos + 2 .. Length( current_line_unedited ) ]};
            fi;
            Add( current_item, current_line_unedited );
        end,
        @BeginLatexOnly := function()
            Add( current_item, "<Alt Only=\"LaTeX\"><![CDATA[" );
            if current_command[ 2 ] <> "" then
                Add( current_item, current_command[ 2 ] );
            fi;
        end,
        @EndLatexOnly := function()
            if autodoc_read_line = true then
                autodoc_read_line := false;
            fi;
            Add( current_item, "]]></Alt>" );
        end,
        @LatexOnly := function()
            Add( current_item, "<Alt Only=\"LaTeX\"><![CDATA[" );
            Add( current_item, current_command[ 2 ] );
            Add( current_item, "]]></Alt>" );
        end,
        @Dependency := function()
            if not IsBound( tree!.worksheet_dependencies ) then
                tree!.worksheet_dependencies := [ ];
            fi;
            NormalizeWhitespace( current_command[ 2 ] );
            Add( tree!.worksheet_dependencies, SplitString( current_command[ 2 ], " " ) );
        end,
        @BeginAutoDocPlainText := function()
            plain_text_mode := true;
        end,
        @AutoDocPlainText := ~.@BeginAutoDocPlainText,
        @EndAutoDocPlainText := function()
            plain_text_mode := false;
        end,
        @ExampleSession := function()
            local example_node;
            example_node := read_session_example( true );
            Add( current_item, example_node );
        end,
        @BeginExampleSession := ~.@ExampleSession,
        @LogSession := function()
            local example_node;
            example_node := read_session_example( false );
            Add( current_item, example_node );
        end,
        @BeginLogSession := ~.@LogSession
    );
    
    ## The following commands are specific for worksheets. They do not have a packageinfo,
    ## and no place to extract those infos. So these commands are needed to make insert the
    ## information directly into the document.
    title_item_list := [ "Title", "Subtitle", "Version", "TitleComment", "Author",
                         "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ];
    
    create_title_item_function := function( name )
        return function()
            if not IsBound( tree!.TitlePage.( name ) ) then
                tree!.TitlePage.( name ) := [ ];
            fi;
            current_item := tree!.TitlePage.( name );
            Add( current_item, current_command[ 2 ] );
        end;
    end;
    
    ## Note that we need to create these functions in the helper function
    ## create_title_item_function to ensure that the <name> variable is bound properly.
    ## Without this intermediate helper, the wrong closure is taken,
    ## and later, when the function is executed, the value for <name> will be the last
    ## value <title_item> had, i.e., the last entry of <title_item_list>.
    for title_item in title_item_list do
        command_function_record.( Concatenation( "@", title_item ) ) := create_title_item_function( title_item );
    od;

    rest_of_file_skipped := false;
    ##Now read the files.
    for filename in filename_list do
        Reset();
        ## FIXME: Is this dangerous?
        if PositionSublist( filename, ".autodoc" ) <> fail then
            plain_text_mode := true;
        fi;
        filestream := InputTextFile( filename );
        if filestream = fail then
            Error( "could not open ", filename );
        fi;
        line_number := 0;
        while true do
            if rest_of_file_skipped = true then
                rest_of_file_skipped := false;
                break;
            fi;
            current_line := ReadLineWithLineCount( filestream );
            if current_line = fail then
                break;
            fi;
            current_line_unedited := ShallowCopy( current_line );
            NormalizeWhitespace( current_line );
            current_command := Scan_for_AutoDoc_Part( current_line, plain_text_mode );
            if current_command[ 1 ] <> false then
                if autodoc_read_line <> fail then
                    autodoc_read_line := true;
                fi;
                if not IsBound( command_function_record.(current_command[ 1 ]) ) then
                    ErrorWithPos("unknown AutoDoc command ", current_command[ 1 ]);
                fi;
                command_function_record.(current_command[ 1 ])();
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
