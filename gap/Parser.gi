# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

##
BindGlobal( "AUTODOC_PositionPrefixShebang",
  function( line )
    local position;
    position := PositionProperty( line, c -> not c in " \t\r\n" );
    if position = fail or position = Length( line ) then
        return fail;
    fi;
    if line[ position ] = '#' and line[ position + 1 ] = '!' then
        return position;
    fi;
    return fail;
end );

##
BindGlobal( "AUTODOC_SplitMarkdownHeading",
  function( line )
    local trimmed, level, first_non_hash;
    trimmed := StripBeginEnd( line, " \t\r\n" );
    if trimmed = "" or trimmed[ 1 ] <> '#' then
        return fail;
    fi;

    level := 1;
    while level < Length( trimmed ) and trimmed[ level + 1 ] = '#' do
        level := level + 1;
    od;
    if level > 3 then
        return fail;
    fi;

    first_non_hash := level + 1;
    if first_non_hash <= Length( trimmed ) and
       not ( trimmed[ first_non_hash ] in " \t\r\n" ) then
        return fail;
    fi;

    while first_non_hash <= Length( trimmed ) and
          trimmed[ first_non_hash ] in " \t\r\n" do
        first_non_hash := first_non_hash + 1;
    od;

    if level = 1 then
        return [ "@Chapter", trimmed{ [ first_non_hash .. Length( trimmed ) ] } ];
    elif level = 2 then
        return [ "@Section", trimmed{ [ first_non_hash .. Length( trimmed ) ] } ];
    fi;
    return [ "@Subsection", trimmed{ [ first_non_hash .. Length( trimmed ) ] } ];
end );

##
BindGlobal( "AUTODOC_SplitCommandAndArgument",
  function( line )
    local command_start, argument_start, command, argument, heading;
    heading := AUTODOC_SplitMarkdownHeading( line );
    if heading <> fail then
        return heading;
    fi;
    command_start := PositionProperty( line, c -> not c in " \t\r\n" );
    if command_start = fail or line[ command_start ] <> '@' then
        return [ "STRING", line ];
    fi;
    argument_start := command_start + 1;
    while argument_start <= Length( line ) and
          not ( line[ argument_start ] in " \t\r\n" ) do
        argument_start := argument_start + 1;
    od;
    command := line{ [ command_start .. argument_start - 1 ] };
    while argument_start <= Length( line ) and line[ argument_start ] in " \t\r\n" do
        argument_start := argument_start + 1;
    od;
    if argument_start <= Length( line ) then
        argument := line{ [ argument_start .. Length( line ) ] };
    else
        argument := "";
    fi;
    return [ command, argument ];
end );

##
InstallGlobalFunction( Scan_for_AutoDoc_Part,
  function( line )
    local trimmed, heading;
    trimmed := StripBeginEnd( line, " \t\r\n" );
    if trimmed = "" then
        return [ "STRING", line ];
    fi;
    if trimmed[ 1 ] = '#' then
        heading := AUTODOC_SplitMarkdownHeading( trimmed );
        if heading = fail then
            return [ "STRING", line ];
        fi;
        return heading;
    fi;
    if trimmed[ 1 ] <> '@' then
        return [ "STRING", line ];
    fi;
    return AUTODOC_SplitCommandAndArgument( trimmed );
 end );

## Scans a string for <element> after <element_not_before_element> appeared.
## This is necessary to scan the filter list for method declarations
## that contain \[\]. 
BindGlobal( "AUTODOC_PositionElementIfNotAfter",
  function( list, element, element_not_before_element )
    local current_pos;
    if not IsList( list ) then
        Error( "<list> must be a list" );
    fi;
    if Length( list ) > 0 and list[ 1 ] = element then
        return 1;
    fi;
 
    for current_pos in [ 2 .. Length( list ) ] do
        if list[ current_pos ] = element and list[ current_pos - 1 ] <> element_not_before_element then
            return current_pos;
        fi;
    od;
    return fail;
end );


BindGlobal( "AutoDoc_PrintWarningForConstructor",
            AutoDoc_CreatePrintOnceFunction( "Installed GAPDoc version does not support constructors" ) );

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
  function( current_item, type, default_chapter_data )
    local item_rec, entries, has_filters, ret_val;
    item_rec := current_item;
    if PositionSublist( type, "DeclareCategoryCollections") <> fail then
        entries := [ "Filt", "categories" ];
        ret_val := "<K>true</K> or <K>false</K>";
        has_filters := "No";
        if not IsBound( item_rec!.arguments ) then
            item_rec!.arguments := "obj";
        fi;
        item_rec!.coll_suffix := true;
    elif PositionSublist( type, "DeclareCategory" ) <> fail then
        entries := [ "Filt", "categories" ];
        ret_val := "<K>true</K> or <K>false</K>";
        has_filters := 1;
    elif PositionSublist( type, "DeclareRepresentation" ) <> fail then
        entries := [ "Filt", "categories" ];
        ret_val := "<K>true</K> or <K>false</K>";
        has_filters := 1;
    elif PositionSublist( type, "DeclareAttribute" ) <> fail then
        entries := [ "Attr", "attributes" ];
        has_filters := 1;
    elif PositionSublist( type, "DeclareProperty" ) <> fail then
        entries := [ "Prop", "properties" ];
        ret_val := "<K>true</K> or <K>false</K>";
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
    elif PositionSublist( type, "DeclareGlobalName" ) <> fail then
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
    local current_item, chapter_info, Scan_for_Declaration_part, current_line, filestream,
          scope_group, read_example, command_function_record, autodoc_read_line,
          current_command, filename, groupnumber, rest_of_file_skipped,
          context_stack, new_man_item, add_man_item, Reset, read_code, title_item, title_item_list, plain_text_mode,
          current_line_unedited, current_line_info, NormalizeInputLine,
          ReadLineWithLineCount, Normalized_ReadLine, line_number, ErrorWithPos, create_title_item_function,
          current_line_positition_for_filter, read_session_example, DeclarationDelimiterPosition,
          ReadInstallMethodFilterString, ReadInstallMethodArguments,
          markdown_fence,
          AUTODOC_MarkdownFenceFromLine, AUTODOC_IsMatchingMarkdownFence,
          current_line_fence, current_line_is_fence_delimiter,
          xml_comment_mode, comment_start_pos;
    groupnumber := 0;
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
    NormalizeInputLine := function( raw_line )
        local text, comment_pos;
        if plain_text_mode then
            text := raw_line;
            return rec(
                raw_text := raw_line,
                text := text,
                is_autodoc := true,
                allows_declaration_scan := false
            );
        fi;

        comment_pos := AUTODOC_PositionPrefixShebang( raw_line );
        if comment_pos = fail then
            return rec(
                raw_text := raw_line,
                text := raw_line,
                is_autodoc := false,
                allows_declaration_scan := false
            );
        fi;

        text := raw_line{ [ comment_pos + 2 .. Length( raw_line ) ] };
        return rec(
            raw_text := raw_line,
            text := text,
            is_autodoc := true,
            allows_declaration_scan := true
        );
    end;
    AUTODOC_MarkdownFenceFromLine := function( line )
        local trimmed_line, fence_char, fence_length;
        trimmed_line := StripBeginEnd( Chomp( line ), " \t\r\n" );
        if Length( trimmed_line ) < 3 or
           not ( trimmed_line[ 1 ] in "`~" ) or
           not ForAll( trimmed_line{ [ 1 .. 3 ] }, c -> c = trimmed_line[ 1 ] ) then
            return fail;
        fi;
        fence_char := trimmed_line[ 1 ];
        fence_length := 1;
        while fence_length < Length( trimmed_line ) and
              trimmed_line[ fence_length + 1 ] = fence_char do
            fence_length := fence_length + 1;
        od;
        return rec(
            char := fence_char,
            length := fence_length,
            remainder := trimmed_line{ [ fence_length + 1 .. Length( trimmed_line ) ] }
        );
    end;
    AUTODOC_IsMatchingMarkdownFence := function( fence, current_line_fence )
        return current_line_fence <> fail and
               fence <> fail and
               current_line_fence.char = fence.char and
               current_line_fence.length >= fence.length and
               ForAll( current_line_fence.remainder, c -> c in " \t\r\n" );
    end;
    DeclarationDelimiterPosition := function( line )
        return Minimum( [ PositionSublist( line, "," ), PositionSublist( line, ");" ) ] );
    end;
    ReadInstallMethodFilterString := function( )
        local filter_string, position_parenthesis;
        while AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) = fail do
            current_line := Normalized_ReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated InstallMethod filter list" );
            fi;
        od;
        position_parenthesis := AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' );
        current_line := current_line{[ position_parenthesis + 1 .. Length( current_line ) ]};
        filter_string := "for ";
        while AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' ) = fail do
            Append( filter_string, current_line );
            current_line := Normalized_ReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated InstallMethod filter list" );
            fi;
        od;
        position_parenthesis := AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' );
        Append( filter_string, current_line{[ 1 .. position_parenthesis - 1 ]} );
        current_line := current_line{[ position_parenthesis + 1 .. Length( current_line )]};
        NormalizeWhitespace( filter_string );
        return filter_string;
    end;
    ReadInstallMethodArguments := function( )
        local position_parenthesis, argument_string;
        while PositionSublist( current_line, "function(" ) = fail and PositionSublist( current_line, ");" ) = fail do
            current_line := Normalized_ReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated InstallMethod declaration" );
            fi;
        od;
        position_parenthesis := PositionSublist( current_line, "function(" );
        if position_parenthesis = fail then
            return fail;
        fi;
        current_line := current_line{[ position_parenthesis + 9 .. Length( current_line ) ]};
        argument_string := "";
        while PositionSublist( current_line, ")" ) = fail do
            current_line := StripBeginEnd( current_line, " " );
            Append( argument_string, current_line );
            current_line := Normalized_ReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated argument list in InstallMethod declaration" );
            fi;
        od;
        position_parenthesis := PositionSublist( current_line, ")" );
        Append( argument_string, current_line{[ 1 .. position_parenthesis - 1 ]} );
        NormalizeWhitespace( argument_string );
        return StripBeginEnd( argument_string, " " );
    end;
    new_man_item := function( )
        local man_item;
        if IsBound( current_item ) and IsTreeForDocumentationNodeForManItemRep( current_item ) then
            return current_item;
        fi;

        # implicitly end any subsection
        if IsBound( chapter_info[ 3 ] ) then
            Unbind( chapter_info[ 3 ] );
            current_item := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
        fi;

        if IsBound( current_item ) then
            Add( context_stack, current_item );
        fi;

        man_item := DocumentationManItem( tree );
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
        markdown_fence := fail;
        xml_comment_mode := false;
    end;
    Scan_for_Declaration_part := function()
        local declare_position, current_type, filter_string, has_filters,
              position_parenthesis, i;

        ## fail is bigger than every integer
        declare_position := Minimum( [ PositionSublist( current_line, "Declare" ), PositionSublist( current_line, "KeyDependentOperation" ) ] );
        if declare_position <> fail then
            current_item := new_man_item();
            current_line := current_line{[ declare_position .. Length( current_line ) ]};
            position_parenthesis := PositionSublist( current_line, "(" );
            if position_parenthesis = fail then
                ErrorWithPos( "Something went wrong" );
            fi;
            current_type := current_line{ [ 1 .. position_parenthesis - 1 ] };
            has_filters := AutoDoc_Type_Of_Item( current_item, current_type, default_chapter_data );
            if has_filters = fail then
                ErrorWithPos( "Unrecognized scan type" );
                return false;
            fi;
            current_line := current_line{ [ position_parenthesis + 1 .. Length( current_line ) ] };
            ## Now the funny part begins:
            ## try fetching the name:
            ## Assuming the name is in the same line as its
            while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                current_line := Normalized_ReadLine( filestream );
                if current_line = fail then
                    ErrorWithPos( "unterminated declaration header" );
                fi;
            od;
            current_line := StripBeginEnd( current_line, " " );
            current_item!.name := current_line{ [ 1 .. DeclarationDelimiterPosition( current_line ) - 1 ] };
            current_item!.name := StripBeginEnd( ReplacedString( current_item!.name, "\"", "" ), " " );

            # Deal with DeclareCategoryCollections: this has some special
            # rules on how the name of a new category is derived from the
            # string given to it. Since the code for that is not available in
            # a separate GAP function, we have to replicate this logic here.
            # To understand what's going on, please refer to the
            # DeclareCategoryCollections documentation and implementation.
            if IsBound(current_item!.coll_suffix) then
                if EndsWith(current_item!.name, "Collection") then
                    current_item!.name :=
                    current_item!.name{[1..Length(current_item!.name)-6]};
                fi;
                if EndsWith(current_item!.name, "Coll") then
                    current_item!.coll_suffix := "Coll";
                else
                    current_item!.coll_suffix := "Collection";
                fi;
                current_item!.name := Concatenation(current_item!.name,
                                                    current_item!.coll_suffix);
            fi;

            current_line := current_line{ [ DeclarationDelimiterPosition( current_line ) + 1 .. Length( current_line ) ] };
            filter_string := "for ";
            ## FIXME: The next two if's can be merged at some point
            if IsInt( has_filters ) then
                for i in [ 1 .. has_filters ] do
                    ## We now search for the filters. A filter is either followed by a ',', if there is more than one,
                    ## or by ');' if it is the only or last one. So we search for the next delimiter.
                    while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                        Append( filter_string, StripBeginEnd( current_line, " " ) );
                        current_line := ReadLineWithLineCount( filestream );
                        if current_line = fail then
                            ErrorWithPos( "unterminated declaration filter list" );
                        fi;
                        NormalizeWhitespace( current_line );
                    od;
                    current_line_positition_for_filter := DeclarationDelimiterPosition( current_line ) - 1;
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
                while AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) = fail do
                    current_line := ReadLineWithLineCount( filestream );
                    if current_line = fail then
                        ErrorWithPos( "unterminated declaration filter list" );
                    fi;
                    NormalizeWhitespace( current_line );
                od;
                current_line := current_line{ [ AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) + 1 .. Length( current_line ) ] };
                while AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' ) = fail do
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    current_line := ReadLineWithLineCount( filestream );
                    if current_line = fail then
                        ErrorWithPos( "unterminated declaration filter list" );
                    fi;
                    NormalizeWhitespace( current_line );
                od;
                Append( filter_string, StripBeginEnd( current_line{[ 1 .. AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' ) - 1 ]}, " " ) );
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
            current_item!.item_type := "Oper";
            ##Find name
            position_parenthesis := PositionSublist( current_line, "(" );
            current_line := current_line{ [ position_parenthesis + 1 .. Length( current_line ) ] };
            ## find next colon
            current_item!.name := "";
            while PositionSublist( current_line, "," ) = fail do
                Append( current_item!.name, current_line );
                current_line := Normalized_ReadLine( filestream );
                if current_line = fail then
                    ErrorWithPos( "unterminated InstallMethod declaration header" );
                fi;
            od;
            position_parenthesis := PositionSublist( current_line, "," );
            Append( current_item!.name, current_line{[ 1 .. position_parenthesis - 1 ]} );
            NormalizeWhitespace( current_item!.name );
            current_item!.name := StripBeginEnd( current_item!.name, " " );
            current_item!.name := ReplacedString( current_item!.name, "\"", "" );
            filter_string := ReadInstallMethodFilterString( );
            if IsString( filter_string ) then
                filter_string := ReplacedString( filter_string, "\"", "" );
            fi;
            if current_item!.tester_names = fail then
                current_item!.tester_names := filter_string;
            fi;
            ##Maybe find some argument names
            if not IsBound( current_item!.arguments ) then
                filter_string := ReadInstallMethodArguments( );
                if filter_string <> fail then
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
        local code, temp_curr_line, temp_line_info, temp_command;
        code := [ "<Listing Type=\"Code\"><![CDATA[\n" ];
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
            temp_line_info := NormalizeInputLine( temp_curr_line );
            if temp_line_info.is_autodoc then
                temp_command := Scan_for_AutoDoc_Part( temp_line_info.text );
                if temp_command[ 1 ] = "@EndCode" then
                    break;
                fi;
                Add( code, temp_line_info.text );
                continue;
            fi;
            Add( code, temp_curr_line );
        od;
        Add( code, "]]></Listing>\n" );
        return code;
    end;
    read_example := function( is_tested_example )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line, item_temp, example_node;
        example_node := DocumentationExample( tree );
        example_node!.is_tested_example := is_tested_example;
        temp_string_list := example_node!.content;
        is_following_line := false;
        while true do
            temp_curr_line := Chomp( ReadLineWithLineCount( filestream ) );
            if PositionSublist( temp_curr_line, "@EndExample" ) <> fail or
               PositionSublist( temp_curr_line, "@EndLog" ) <> fail then
                break;
            fi;
            ##if is comment, simply remove comments.
            temp_pos_comment := AUTODOC_PositionPrefixShebang( temp_curr_line );
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
    read_session_example := function( is_tested_example, plain_text_mode )
        local temp_string_list, temp_curr_line, temp_pos_comment,
              is_following_line, item_temp, example_node,
              incorporate_this_line;
        example_node := DocumentationExample( tree );
        example_node!.is_tested_example := is_tested_example;
        temp_string_list := example_node!.content;
        while true do
            temp_curr_line := Chomp( ReadLineWithLineCount( filestream ) );
            if PositionSublist( temp_curr_line, "@EndExampleSession" ) <> fail or
               PositionSublist( temp_curr_line, "@EndLogSession" ) <> fail then
                break;
            fi;
            incorporate_this_line := plain_text_mode;
            if not plain_text_mode then
                temp_pos_comment := AUTODOC_PositionPrefixShebang( temp_curr_line );
                if temp_pos_comment <> fail then
                    incorporate_this_line := true;
                    temp_curr_line := temp_curr_line{[ temp_pos_comment + 2 .. Length( temp_curr_line ) ]};
                    if Length( temp_curr_line ) >= 1 and temp_curr_line[ 1 ] = ' ' then
                        Remove( temp_curr_line, 1 );
                    fi;
                fi;
            fi;
            if incorporate_this_line then
                Add( temp_string_list, temp_curr_line );
            fi;
        od;
        return example_node;
    end;
    command_function_record := rec(
        @DoNotReadRestOfFile := function()
            Reset();
            rest_of_file_skipped := true;
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
            SetLabel( scope_chapter, Concatenation( "Chapter_", label_name ) );
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
            SetLabel( scope_section, Concatenation( "Section_", label_name ) );
        end,
        @SectionTitle := function()
            local scope_section;
            if not IsBound( chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionTitle with no active section" );
            fi;
            scope_section := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
            scope_section!.title_string := current_command[ 2 ];
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
                ErrorWithPos( "found @SubsectionLabel with no active subsection" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_subsection := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], chapter_info[ 3 ] );
            SetLabel( scope_subsection, Concatenation( "Subsection_", label_name ) );
        end,
        @SubsectionTitle := function()
            local scope_subsection;
            if not IsBound( chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionTitle with no active subsection" );
            fi;
            scope_subsection := SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], chapter_info[ 3 ] );
            scope_subsection!.title_string := current_command[ 2 ];
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
        @GroupTitle := function()
            local group_name, chap_info, group_obj;
            current_item := new_man_item();
            if not HasGroupName( current_item ) then
                ErrorWithPos( "found @GroupTitle with no Group set" );
            fi;
            group_name := GroupName( current_item );
            chap_info := fail;
            if HasChapterInfo( current_item ) then
                chap_info := ChapterInfo( current_item );
            elif IsBound( current_item!.chapter_info ) then
                chap_info := current_item!.chapter_info;
            fi;
            if chap_info = fail or Length( chap_info ) = 0 then
                chap_info := chapter_info;
            fi;
            if Length( chap_info ) <> 2 then
                ErrorWithPos( "can only set @GroupTitle within a Chapter and Section.");
            fi;
            group_obj := DocumentationGroup( tree, group_name, chap_info );
            group_obj!.title_string := current_command[ 2 ];
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
        @Index := function()
            local argument, split_pos, key, entry,
                  escaped_quote_pos, key_string, key_escaped;
            if not IsBound( current_item ) then
                ErrorWithPos( "found @Index with no active documentation item" );
            fi;
            argument := StripBeginEnd( current_command[ 2 ], " \t\r\n" );
            if argument = "" then
                ErrorWithPos( "found @Index without arguments" );
            fi;
            entry := "";
            if argument[ 1 ] = '"' then
                escaped_quote_pos := 2;
                while escaped_quote_pos <= Length( argument ) and
                      argument[ escaped_quote_pos ] <> '"' do
                    escaped_quote_pos := escaped_quote_pos + 1;
                od;
                if escaped_quote_pos > Length( argument ) then
                    ErrorWithPos( "found @Index with unterminated quoted key" );
                fi;
                key := argument{ [ 2 .. escaped_quote_pos - 1 ] };
                split_pos := escaped_quote_pos + 1;
                while split_pos <= Length( argument ) and argument[ split_pos ] in " \t\r\n" do
                    split_pos := split_pos + 1;
                od;
                if split_pos <= Length( argument ) then
                    entry := argument{ [ split_pos .. Length( argument ) ] };
                fi;
            else
                split_pos := PositionProperty( argument, c -> c in " \t\r\n" );
                if split_pos = fail then
                    key := argument;
                else
                    key := argument{ [ 1 .. split_pos - 1 ] };
                    while split_pos <= Length( argument ) and argument[ split_pos ] in " \t\r\n" do
                        split_pos := split_pos + 1;
                    od;
                    if split_pos <= Length( argument ) then
                        entry := argument{ [ split_pos .. Length( argument ) ] };
                    fi;
                fi;
            fi;

            key_string := key;
            key_escaped := "";
            while key_string <> "" do
                split_pos := PositionProperty( key_string, c -> c in "&\"<>" );
                if split_pos = fail then
                    key_escaped := Concatenation( key_escaped, key_string );
                    key_string := "";
                elif split_pos > 1 then
                    key_escaped := Concatenation( key_escaped, key_string{ [ 1 .. split_pos - 1 ] } );
                    key_string := key_string{ [ split_pos .. Length( key_string ) ] };
                fi;
                if key_string = "" then
                    break;
                fi;
                if key_string[ 1 ] = '&' then
                    key_escaped := Concatenation( key_escaped, "&amp;" );
                elif key_string[ 1 ] = '"' then
                    key_escaped := Concatenation( key_escaped, "&quot;" );
                elif key_string[ 1 ] = '<' then
                    key_escaped := Concatenation( key_escaped, "&lt;" );
                else
                    key_escaped := Concatenation( key_escaped, "&gt;" );
                fi;
                if Length( key_string ) > 1 then
                    key_string := key_string{ [ 2 .. Length( key_string ) ] };
                else
                    key_string := "";
                fi;
            od;

            if key_escaped = "" then
                ErrorWithPos( "found @Index with empty key" );
            fi;
            Add( current_item, Concatenation( "<Index Key=\"", key_escaped, "\">", entry, "</Index>" ) );
        end,

        @InsertChunk := function()
            local label_name;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            Add( current_item, DocumentationChunk( tree, label_name ) );
        end,
        @BeginChunk := function()
            local label_name;
            if IsBound( current_item ) then
                Add( context_stack, current_item );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            current_item := DocumentationChunk( tree, label_name );
            current_item!.is_defined := true;
        end,
        @Chunk := ~.@BeginChunk,
        @EndChunk := function()
            autodoc_read_line := false;
            if context_stack <> [ ] then
                current_item := Remove( context_stack );
            else
                Unbind( current_item );
            fi;
        end,

        @BeginCode := function()
            local label_name, tmp_system;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            tmp_system := DocumentationChunk( tree, label_name );
            tmp_system!.is_defined := true;
            Add( tmp_system!.content, DocumentationChunkContent( read_code() ) );
        end,
        @Code := ~.@BeginCode,
        @InsertCode := ~.@InsertChunk,

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
            if not IsBound( current_item ) then
                return;
            fi;
            Add( current_item, current_command[ 2 ] );
        end,
        @BeginLatexOnly := function()
            Add( current_item, "<Alt Only=\"LaTeX\"><![CDATA[" );
            if current_command[ 2 ] <> "" then
                Add( current_item, current_command[ 2 ] );
            fi;
        end,
        @EndLatexOnly := function()
            autodoc_read_line := false;
            Add( current_item, "]]></Alt>" );
        end,
        @LatexOnly := function()
            Add( current_item, "<Alt Only=\"LaTeX\"><![CDATA[" );
            Add( current_item, current_command[ 2 ] );
            Add( current_item, "]]></Alt>" );
        end,
        @BeginNotLatex := function()
            Add( current_item, "<Alt Not=\"LaTeX\"><![CDATA[" );
            if current_command[ 2 ] <> "" then
                Add( current_item, current_command[ 2 ] );
            fi;
        end,
        @EndNotLatex := function()
            autodoc_read_line := false;
            Add( current_item, "]]></Alt>" );
        end,
        @NotLatex := function()
            Add( current_item, "<Alt Not=\"LaTeX\"><![CDATA[" );
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
        @ExampleSession := function()
            local example_node;
            example_node := read_session_example( true, plain_text_mode );
            Add( current_item, example_node );
        end,
        @BeginExampleSession := ~.@ExampleSession,
        @LogSession := function()
            local example_node;
            example_node := read_session_example( false, plain_text_mode );
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
        ##Need to set autodoc_read_line to false again since we now look at a new file.
        autodoc_read_line := false;
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
            current_line_info := NormalizeInputLine( current_line_unedited );
            NormalizeWhitespace( current_line );

            if plain_text_mode then
                if xml_comment_mode then
                    current_command := [ "STRING", current_line_unedited ];
                    if PositionSublist( current_line_unedited, "-->" ) <> fail then
                        xml_comment_mode := false;
                    fi;
                    command_function_record.STRING();
                    continue;
                fi;
                comment_start_pos := PositionSublist( current_line_unedited, "<!--" );
                if comment_start_pos <> fail then
                    current_command := [ "STRING", current_line_unedited ];
                    if PositionSublist(
                           current_line_unedited{ [ comment_start_pos + 4 .. Length( current_line_unedited ) ] },
                           "-->"
                       ) = fail then
                        xml_comment_mode := true;
                    fi;
                    command_function_record.STRING();
                    continue;
                fi;
            fi;

            if current_line_info.is_autodoc then
                current_line_fence := AUTODOC_MarkdownFenceFromLine( current_line_info.text );
                current_command := Scan_for_AutoDoc_Part( current_line_info.text );
            else
                current_line_fence := fail;
                current_command := [ false, current_line ];
            fi;
            current_line_is_fence_delimiter := false;
            if current_line_fence <> fail then
                if markdown_fence = fail then
                    current_line_is_fence_delimiter := true;
                else
                    current_line_is_fence_delimiter :=
                        AUTODOC_IsMatchingMarkdownFence( markdown_fence, current_line_fence );
                fi;
            fi;
            if current_line_is_fence_delimiter then
                current_command := [ "STRING", current_line_info.text ];
            elif markdown_fence <> fail and current_command[ 1 ] <> false then
                current_command := [ "STRING", current_line_info.text ];
            fi;
            if current_command[ 1 ] <> false then
                autodoc_read_line := current_line_info.allows_declaration_scan;
                if not IsBound( command_function_record.(current_command[ 1 ]) ) then
                    ErrorWithPos("unknown AutoDoc command ", current_command[ 1 ]);
                fi;
                command_function_record.(current_command[ 1 ])();
                if current_line_is_fence_delimiter then
                    if markdown_fence = fail then
                        markdown_fence := current_line_fence;
                    else
                        markdown_fence := fail;
                    fi;
                fi;
                continue;
            fi;
            current_line := current_command[ 2 ];
            if autodoc_read_line and not Scan_for_Declaration_part( ) then
                autodoc_read_line := false;
            fi;
        od;
        CloseStream( filestream );
    od;
end );
