# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

## Helper function
InstallGlobalFunction( AutoDoc_Mask_Line,
  function ( line )
    local maskedline, inquote, i;
    maskedline := ShallowCopy( line );
    inquote := false;
    i := 1;
    while i <= Length( line ) do
        if maskedline[ i ] = '\\' then
            if inquote then
                maskedline[ i ] := 'X';
                maskedline[ i+1 ] := 'X';
            fi;
            i := i + 2;
            continue;
        fi;
        if line[ i ] = '`' then
            inquote := not inquote;
        elif inquote then
            maskedline[ i ] := 'X';
        fi;
        i := i + 1;
    od;
    return maskedline;
end );

##
InstallGlobalFunction( Scan_for_AutoDoc_Part,
  function( line, plain_text_mode )
    local masked_line, position, whitespace_position, command,
          argument, masked_argument;
    masked_line := AutoDoc_Mask_Line( line );
    #! @DONT_SCAN_NEXT_LINE
    position := PositionSublist( masked_line, "#!" );
    if position = fail and plain_text_mode = false then
        return [ false, line, masked_line ];
    fi;
    if plain_text_mode <> true then
        line := StripBeginEnd( line{[ position + 2 .. Length( line ) ]}, " " );
        masked_line := StripBeginEnd( masked_line{[ position + 2 .. Length( masked_line ) ]}, " " );
    fi;
    ## Scan for a command
    position := PositionSublist( masked_line, "@" );
    if position = fail then
        return [ "STRING", line, masked_line ];
    fi;
    whitespace_position := PositionSublist( line, " " );
    if whitespace_position = fail then
        command := line{[ position .. Length( line ) ]};
        argument := "";
        masked_argument := "";
    else
        command := line{[ position .. whitespace_position - 1 ]};
        argument := line{[ whitespace_position + 1 .. Length( line ) ]};
        masked_argument := masked_line{[ whitespace_position + 1 ..
                                         Length( line ) ]};
    fi;
    return [ command, argument, masked_argument ];
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


## Helper function
NotFunctional@ := function( item, declarator )
    if IsBound( item!.arguments ) and item!.arguments <> fail then
        Info( InfoWarning, 1, "Ignoring @Arguments for item defined by ",
              declarator );
    fi;
    item!.arguments := fail;
    if IsBound( item!.return_value ) and item!.return_value <> false then
        Info( InfoWarning, 1, "Ignoring @Returns for item defined by ",
              declarator );
    fi;
    item!.return_value := false;
    return item!.return_value;
end;

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
  function( current_item, type, default_chapter_data )
    local declaration_cases, declarators, recommended_keys, matched_case,
          decl, key;
    declaration_cases := rec(
        DeclareCategoryCollections :=
            {item} -> rec( item_type := "Filt", doc_stream_type := "categories",
                           coll_suffix := true, arguments := "obj",
                           has_filters := "No" ),
        DeclareCategory :=
            {item} -> rec( item_type := "Filt", doc_stream_type := "categories",
                          has_filters := 1 ),
        DeclareRepresentation := ~.DeclareCategory,
        DeclareAttribute :=
            {item} -> rec( item_type := "Attr", doc_stream_type := "attributes",
                          has_filters := 1 ),
        DeclareProperty :=
            {item} -> rec( item_type := "Prop", doc_stream_type := "properties",
                          has_filters := 1 ),
        DeclareOperation :=
            {item} -> rec( item_type := "Oper", doc_stream_type := "methods",
                          has_filters := "List" ),
        DeclareFilter :=
            {item} -> rec( item_type := "Filt", arguments := "arg",
                          doc_stream_type := "global_functions",
                          has_filters := "No" ),
        DeclareGlobalFunction :=
            {item} -> rec( item_type := "Func", arguments := "arg",
                          doc_stream_type := "global_functions",
                          has_filters := "No" ),
        KeyDependentOperation :=
            {item} -> rec( item_type := "Oper", doc_stream_type := "methods",
                          has_filters := 2 ),
        DeclareSynonym :=
            {item} -> rec( has_filters := "No" ),
        DeclareGlobalVariable :=
            {item} -> rec( item_type := "Var",
                          doc_stream_type := "global_variables",
                          return_value := NotFunctional@(item,
                                              "DeclareGlobalVariable"),
                          has_filters := "No" ),
        DeclareInfoClass :=
            {item} -> rec( item_type := "InfoClass",
                          doc_stream_type := "info_classes",
                          return_value := NotFunctional@(item,
                                              "DeclareInfoClass"),
                          has_filters := "No"),
        DeclareConstructor := function ( item )
            if IsPackageMarkedForLoading( "GAPDoc", ">=1.6.1" ) then
                return rec( item_type := "Constr", doc_stream_type := "methods",
                            has_filters := "List");
            fi;
            AutoDoc_PrintWarningForConstructor();
            return rec( item_type := "Oper", doc_stream_type := "methods",
                        has_filters := "List" );
        end,
    );
    matched_case := false;
    recommended_keys := rec();
    declarators :=  ShallowCopy( RecNames( declaration_cases ) );
    Sort( declarators );
    ## Note must match longer declarators first, since they may contain
    ## shorter declarators
    for decl in Reversed( declarators ) do
        if PositionSublist( type, decl ) <> fail then
            matched_case := decl;
            recommended_keys := (declaration_cases.( decl ))( current_item );
            break;
        fi;
    od;
    if matched_case = false then
        return fail;
    fi;
    ## Some adjustments to the recommended_keys:
    if IsBound( recommended_keys.item_type ) then
        if ( recommended_keys.item_type = "Filt" or
             recommended_keys.item_type = "Prop" )
           and not IsBound( recommended_keys.return_value ) then
            recommended_keys.return_value := "<C>true</C> or <C>false</C>";
        fi;
        if IsBound( current_item!.item_type) and
           current_item!.item_type <> recommended_keys.item_type then
            Info( InfoWarning, 1, "Ignoring recommended item type ",
                  recommended_keys.item_type, " for a ", matched_case,
                  " in favor of explicitly set ", current_item!.item_type );
        fi;
    fi;
    ## Pull in an existing doc_stream_type for the sake of looking the
    ## chapter_info up in the default_chapter_data
    if IsBound( current_item!.doc_stream_type) then
        recommended_keys.doc_stream_type := current_item!.doc_stream_type;
    fi;
    if IsBound( recommended_keys.doc_stream_type ) then
        recommended_keys.chapter_info :=
        default_chapter_data.( recommended_keys.doc_stream_type );
    fi;
    ## Now merge the recommended keys into the current item, where they don't
    ## conflict
    for key in RecNames( recommended_keys ) do
        if not IsBound( current_item!.( key ) ) or
           current_item!.( key ) = [ ] or
           current_item!.( key ) = false then
            current_item!.( key) := recommended_keys.( key );
        fi;
    od;
    return current_item!.has_filters;
end );

##
InstallGlobalFunction( AutoDoc_Parser_ReadFiles,
  function( filename_list, tree, default_chapter_data )
    local flush_and_recover, scope_chapter_info, current_string_list,
          Scan_for_Declaration_part, flush_and_prepare_for_item, current_line,
          masked_current_line, filestream,
          level_scope, scope_group, read_example, command_function_record, autodoc_read_line,
          current_command, was_declaration, filename, system_scope, groupnumber, chunk_list, rest_of_file_skipped,
          active_node_stack, new_man_item, add_man_item, Reset, read_code, title_item, title_item_list, plain_text_mode,
          current_line_unedited, deprecated,
          ReadLineWithLineCount, Normalized_ReadLine, line_number, ErrorWithPos, create_title_item_function,
          current_line_positition_for_filter, read_session_example,
          StackEmpty, PopNode, PeekNode, PushNode, ResetStack;
    groupnumber := 0;
    level_scope := 0;
    autodoc_read_line := false;
    active_node_stack := [ ];
    scope_chapter_info := [ ];
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
    StackEmpty := {} -> Length( active_node_stack ) = 0;
    PopNode := function ()
        if not StackEmpty() then return Remove( active_node_stack ); fi;
        return fail;
    end;
    PeekNode := function ()
        if not StackEmpty() then
            return active_node_stack[ Length( active_node_stack ) ];
        fi;
        return fail;
    end;
    PushNode := function (node)
        # Pop any list nodes
        while IsList( PeekNode() ) do
            PopNode();
        od;
        Add(active_node_stack, node);
    end;
    ResetStack := function() active_node_stack := [ ]; end;
    new_man_item := function( )
        local man_item;
        man_item := PeekNode();
        if IsTreeForDocumentationNodeForManItemRep( man_item ) then
            return man_item;
        fi;

        # implicitly end any subsection
        if IsBound( scope_chapter_info[ 3 ] ) then
            Unbind( scope_chapter_info[ 3 ] );
            PopNode();
        fi;

        man_item := DocumentationManItem( tree );
        PushNode( man_item );
        if IsBound( scope_group ) then
            SetGroupName( man_item, scope_group );
        fi;
        man_item!.chapter_info := ShallowCopy( scope_chapter_info );
        man_item!.tester_names := fail;
        return man_item;
    end;
    add_man_item := function( )
        local man_item;
        man_item := PopNode();
        if IsBound( man_item!.chapter_info ) then
            SetChapterInfo( man_item, man_item!.chapter_info );
        fi;
        if Length( ChapterInfo( man_item ) ) <> 2 then
            ErrorWithPos( "declarations must be documented within a section" );
        fi;
        Add( tree, man_item );
    end;
    Reset := function( )
        scope_chapter_info := [ ];
        ResetStack();
        plain_text_mode := false;
    end;
    Scan_for_Declaration_part := function()
        local man_item, declare_position, current_type, filter_string,
              has_filters, position_parentesis, nr_of_attr_loops, i;

        ## fail is bigger than every integer
        declare_position := Minimum( [ PositionSublist( masked_current_line, "Declare" ), PositionSublist( masked_current_line, "KeyDependentOperation" ) ] );
        position_parentesis := PositionSublist( masked_current_line, "(");
        if declare_position <> fail and position_parentesis <> fail then
            man_item := new_man_item();
            current_line := current_line{[ declare_position .. Length( current_line ) ]};
            position_parentesis := PositionSublist( current_line, "(" );
            if position_parentesis = fail then
                ErrorWithPos( "Something went wrong" );
            fi;
            current_type := current_line{ [ 1 .. position_parentesis - 1 ] };
            has_filters := AutoDoc_Type_Of_Item( man_item, current_type, default_chapter_data );
            if has_filters = fail then
                ErrorWithPos( "Unrecognized scan type" );
                return false;
            fi;
            current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
            ## Now the funny part begins:
            ## try fetching the name:
            ## Assuming the name is in the same line as its
            while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                current_line := Normalized_ReadLine( filestream );
            od;
            current_line := StripBeginEnd( current_line, " " );
            man_item!.name := current_line{ [ 1 .. Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1 ] };
            man_item!.name := StripBeginEnd( ReplacedString( man_item!.name, "\"", "" ), " " );

            # Deal with DeclareCategoryCollections: this has some special
            # rules on how the name of a new category is derived from the
            # string given to it. Since the code for that is not available in
            # a separate GAP function, we have to replicate this logic here.
            # To understand what's going on, please refer to the
            # DeclareCategoryCollections documentation and implementation.
            if IsBound(man_item!.coll_suffix) then
                if EndsWith(man_item!.name, "Collection") then
                    man_item!.name :=
                    man_item!.name{[1..Length(man_item!.name)-6]};
                fi;
                if EndsWith(man_item!.name, "Coll") then
                    man_item!.coll_suffix := "Coll";
                else
                    man_item!.coll_suffix := "Collection";
                fi;
                man_item!.name := Concatenation(man_item!.name,
                                                man_item!.coll_suffix);
            fi;

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
                while AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) = fail do
                    current_line := ReadLineWithLineCount( filestream );
                    NormalizeWhitespace( current_line );
                od;
                current_line := current_line{ [ AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) + 1 .. Length( current_line ) ] };
                while AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' ) = fail do
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    current_line := ReadLineWithLineCount( filestream );
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
                if man_item!.tester_names = fail and StripBeginEnd( filter_string, " " ) <> "for" then
                    man_item!.tester_names := filter_string;
                fi;
                if StripBeginEnd( filter_string, " " ) = "for" then
                    has_filters := "empty_argument_list";
                fi;
                ##Adjust arguments
                if not IsBound( man_item!.arguments ) then
                    if IsInt( has_filters ) then
                        if has_filters = 1 then
                            man_item!.arguments := "arg";
                        else
                            man_item!.arguments := JoinStringsWithSeparator( List( [ 1 .. has_filters ], i -> Concatenation( "arg", String( i ) ) ), "," );
                        fi;
                    elif has_filters = "List" then
                        man_item!.arguments := List( [ 1 .. Length( SplitString( filter_string, "," ) ) ], i -> Concatenation( "arg", String( i ) ) );
                        if Length( man_item!.arguments ) = 1 then
                            man_item!.arguments := "arg";
                        else
                            man_item!.arguments := JoinStringsWithSeparator( man_item!.arguments, "," );
                        fi;
                    elif has_filters = "empty_argument_list" then
                        man_item!.arguments := "";
                    fi;
                fi;
            fi;
            add_man_item();
            return true;
        fi;
        declare_position := Minimum( [ PositionSublist( masked_current_line, "InstallMethod" ),
                                       PositionSublist( masked_current_line, "InstallOtherMethod" ) ] );
                            ## Fail is larger than every integer.
        if declare_position <> fail then
            man_item := new_man_item();
            if not IsBound( man_item!.item_type ) or
               man_item!.item_type = false then
                man_item!.item_type := "Func";
            fi;
            if not IsBound( man_item!.doc_stream_type ) or
               man_item!.doc_stream_type = false then
                man_item!.doc_stream_type := "operations";
            fi;
            ##Find name
            position_parentesis := PositionSublist( current_line, "(" );
            current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
            ## find next colon
            man_item!.name := "";
            while PositionSublist( current_line, "," ) = fail do
                Append( man_item!.name, current_line );
                current_line := Normalized_ReadLine( filestream );
            od;
            position_parentesis := PositionSublist( current_line, "," );
            Append( man_item!.name, current_line{[ 1 .. position_parentesis - 1 ]} );
            NormalizeWhitespace( man_item!.name );
            man_item!.name := StripBeginEnd( man_item!.name, " " );
            while AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' ) = fail do
                current_line := Normalized_ReadLine( filestream );
            od;
            position_parentesis := AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' );
            current_line := current_line{[ position_parentesis + 1 .. Length( current_line ) ]};
            filter_string := "for ";
            while PositionSublist( current_line, "]" ) = fail do
                Append( filter_string, current_line );
            od;
            position_parentesis := AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' );
            Append( filter_string, current_line{[ 1 .. position_parentesis - 1 ]} );
            current_line := current_line{[ position_parentesis + 1 .. Length( current_line )]};
            NormalizeWhitespace( filter_string );
            if IsString( filter_string ) then
                filter_string := ReplacedString( filter_string, "\"", "" );
            fi;
            if man_item!.tester_names = fail then
                man_item!.tester_names := filter_string;
            fi;
            ##Maybe find some argument names
            if not IsBound( man_item!.arguments ) then
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
                    man_item!.arguments := filter_string;
                fi;
            fi;
            if not IsBound( man_item!.arguments ) then
                man_item!.arguments := Length( SplitString( man_item!.tester_names, "," ) );
                man_item!.arguments := JoinStringsWithSeparator( List( [ 1 .. man_item!.arguments ], i -> Concatenation( "arg", String( i ) ) ), "," );
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
            if filestream = fail or PositionSublist( temp_curr_line, "@EndExample" ) <> fail
                                 or PositionSublist( temp_curr_line, "@EndLog" ) <> fail then
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
    read_session_example := function( is_tested_example, plain_text_mode )
        local temp_string_list, temp_curr_line, temp_pos_comment,
              is_following_line, item_temp, example_node,
              incorporate_this_line;
        example_node := DocumentationExample( tree );
        example_node!.is_tested_example := is_tested_example;
        temp_string_list := example_node!.content;
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
            if temp_curr_line[ Length( temp_curr_line )] = '\n' then
                temp_curr_line := temp_curr_line{[ 1 .. Length( temp_curr_line ) - 1 ]};
            fi;
            if filestream = fail or ( is_tested_example and PositionSublist( temp_curr_line, "@EndExampleSession" ) <> fail )
                                 or ( not is_tested_example and PositionSublist( temp_curr_line, "@EndLogSession" ) <> fail ) then
                break;
            fi;
            incorporate_this_line := plain_text_mode;
            if not plain_text_mode then
                #! @DONT_SCAN_NEXT_LINE
                temp_pos_comment := PositionSublist( temp_curr_line, "#!" );
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
    deprecated := function(name, f)
        return function(args...)
            Info(InfoWarning, 1, TextAttr.1, "WARNING: ----------------------------------------------------------------------------", TextAttr.reset);
            Info(InfoWarning, 1, TextAttr.1, "WARNING: ", name, " is deprecated; please refer to the AutoDoc manual for details", TextAttr.reset);
            Info(InfoWarning, 1, TextAttr.1, "WARNING: ----------------------------------------------------------------------------", TextAttr.reset);
            f();
        end;
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
            # Starting a chapter ends subsection and section
            command_function_record.@EndSubsection();
            command_function_record.@EndSection();
            # Starting a chapter pops any chapters or list nodes off the stack
            while IsTreeForDocumentationNodeForChapterRep( PeekNode() ) or
                  IsList( PeekNode() ) do
                PopNode();
            od;
            scope_chapter := ReplacedString( current_command[ 2 ], " ", "_" );
            PushNode( ChapterInTree( tree, scope_chapter ) );
            scope_chapter_info := [ scope_chapter ];
        end,
        @ChapterLabel := function()
            local scope_chapter, label_name;
            if not IsBound( scope_chapter_info[ 1 ] ) then
                ErrorWithPos( "found @ChapterLabel with no active chapter" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_chapter := ChapterInTree( tree, scope_chapter_info[ 1 ] );
            scope_chapter!.additional_label := Concatenation( "Chapter_", label_name );
        end,
        @ChapterTitle := function()
            local scope_chapter;
            if not IsBound( scope_chapter_info[ 1 ] ) then
                ErrorWithPos( "found @ChapterTitle with no active chapter" );
            fi;
            scope_chapter := ChapterInTree( tree, scope_chapter_info[ 1 ] );
            scope_chapter!.title_string := current_command[ 2 ];
        end,
        @Section := function()
            local scope_section;
            if not IsBound( scope_chapter_info[ 1 ] ) then
                ErrorWithPos( "found @Section with no active chapter" );
            fi;
            # Starting a section ends any current Subsection and Section
            command_function_record.@EndSubsection();
            command_function_record.@EndSection();
            if StackEmpty() then
                ErrorWithPos( "found @Section with no active node" );
            fi;
            scope_section := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_chapter_info[ 2 ] := scope_section;
            PushNode( SectionAsChildOf( tree, scope_chapter_info, PeekNode() ) );
        end,
        @SectionLabel := function()
            local scope_section, label_name;
            if not IsBound( scope_chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionLabel with no active section" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            ## The following will barf if the section has not already been
            ## created, which should never happen.
            scope_section := SectionAsChildOf( tree, scope_chapter_info{ [ 1, 2 ] }, fail );
            scope_section!.additional_label := Concatenation( "Section_", label_name );
        end,
        @SectionTitle := function()
            local scope_section;
            if not IsBound( scope_chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionTitle with no active section" );
            fi;
            scope_section := SectionAsChildOf( tree, scope_chapter_info{ [ 1, 2 ] }, fail );
            scope_section!.title_string := current_command[ 2 ];
        end,
        @EndSection := deprecated("@EndSection", function()
            # First close the subsection if any
            command_function_record.@EndSubsection();
            Unbind( scope_chapter_info[ 2 ] );
            # Pop any sections or list nodes on the stack
            while IsTreeForDocumentationNodeForSectionRep( PeekNode() ) or
                  IsList( PeekNode() ) do
                PopNode();
            od;
            # Is there any further error checking/operation we should do
            # on the state of the stack?
        end),
        @Subsection := function()
            local scope_subsection;
            if not IsBound( scope_chapter_info[ 1 ] ) or not IsBound( scope_chapter_info[ 2 ] ) then
                ErrorWithPos( "found @Subsection with no active section" );
            fi;
            # End any current subsection
            command_function_record.@EndSubsection();
            if StackEmpty() then
                ErrorWithPos( "found @Subsection with no active node" );
            fi;
            scope_subsection := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_chapter_info[ 3 ] := scope_subsection;
            PushNode( SubsectionAsChildOf( tree, scope_chapter_info, PeekNode() ) );
        end,
        @SubsectionLabel := function()
            local scope_subsection, label_name;
            if not IsBound( scope_chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionLabel with no active subsection" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_subsection := SubsectionAsChildOf( tree, scope_chapter_info, fail );
            scope_subsection!.additional_label := Concatenation( "Subsection_", label_name );
        end,
        @SubsectionTitle := function()
            local scope_subsection;
            if not IsBound( scope_chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionTitle with no active subsection" );
            fi;
            scope_subsection := SubsectionAsChildOf( tree, scope_chapter_info, fail );
            scope_subsection!.title_string := current_command[ 2 ];
        end,
        @EndSubsection := deprecated("@EndSubsection", function()
            # One should not end a subsection in the middle of a man item
            if IsTreeForDocumentationNodeForManItemRep( PeekNode() ) then
                ErrorWithPos( "Attempt to end a subsection, section, or chapter with unfinished man item." );
            fi;
            Unbind( scope_chapter_info[ 3 ] );
            # Pop any subsection nodes or list nodes on the stack.
            while IsTreeForDocumentationNodeForSubsectionRep( PeekNode() ) or
                  IsList( PeekNode() ) do
                PopNode();
            od;
            # Is there any further error checking/operation we should do
            # on the state of the stack?
        end),

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
            local man_item;
            man_item := new_man_item();
            SetManItemToDescription( man_item );
            NormalizeWhitespace( current_command[ 2 ] );
            if current_command[ 2 ] <> "" then
                Add( man_item, current_command[ 2 ] );
            fi;
        end,
        @Returns := function()
            local man_item;
            man_item := new_man_item();
            SetManItemToReturnValue( man_item );
            if current_command[ 2 ] <> "" then
                Add( man_item, current_command[ 2 ] );
            fi;
        end,
        @Arguments := function()
            new_man_item()!.arguments := current_command[ 2 ];
        end,
        @Label := function()
            new_man_item()!.tester_names := current_command[ 2 ];
        end,
        @Group := function()
            local group_name;
            group_name := ReplacedString( current_command[ 2 ], " ", "_" );
            SetGroupName( new_man_item(), group_name );
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
            local spec_chapter_info;
            spec_chapter_info := SplitString( current_command[ 2 ], "," );
            spec_chapter_info := List( spec_chapter_info, i -> ReplacedString( StripBeginEnd( i, " " ), " ", "_" ) );
            SetChapterInfo( new_man_item(), spec_chapter_info );
        end,
        @ItemType := function()
            local man_item, splitargs;
            man_item := new_man_item();
            splitargs := SplitString( current_command[ 2 ], " \t" );
            man_item!.item_type := splitargs[ 1 ];
            if Length( splitargs ) > 1 then
                man_item!.doc_stream_type := splitargs[ 2 ];
            fi;
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
            PeekNode()!.level := Int( current_command[ 2 ] );
        end,

        @InsertChunk := function()
            Add( PeekNode(), DocumentationDummy( tree, current_command[ 2 ] ) );
        end,
        @BeginChunk := function()
            PushNode( DocumentationDummy( tree, current_command[ 2 ] ) );
        end,
        @Chunk := ~.@BeginChunk,
        @EndChunk := function()
            if autodoc_read_line = true then
                autodoc_read_line := false;
            fi;
            ## Ending a chunk ends any section or subsection in force
            command_function_record.@EndSubsection();
            command_function_record.@EndSection();
            ## Now we had better be in a chunk
            if not IsTreeForDocumentationDummyNodeRep( PeekNode() ) then
                ErrorWithPos( "Found @EndChunk when no chunk was active." );
            fi;
            PopNode();
        end,

        @InsertSystem := deprecated("@InsertSystem", ~.@InsertChunk),
        @System := deprecated("@System", ~.@BeginChunk),
        @BeginSystem := ~.@System,
        @EndSystem := deprecated("@EndSystem", ~.@EndChunk),

        @BeginCode := function()
            local tmp_system;
            tmp_system := DocumentationCode( tree, current_command[ 2 ] );
            Append( tmp_system!.content, read_code() );
        end,
        @Code := ~.@BeginCode,
        @InsertCode := ~.@InsertChunk,
        @HereCode := function()
            local tmp_system;
            groupnumber := groupnumber + 1;
            tmp_system :=
              DocumentationCode( tree, Concatenation( "Anon_Code_",
                                                      String( groupnumber ) ) );
            Append( tmp_system!.content, read_code() );
            Add( PeekNode(), tmp_system );
        end,

        @BeginExample := function()
            local example_node;
            example_node := read_example( true );
            Add( PeekNode(), example_node );
        end,
        @Example := ~.@BeginExample,

        @BeginLog := function()
            local example_node;
            example_node := read_example( false );
            Add( PeekNode(), example_node );
        end,
        @Log := ~.@BeginLog,

        STRING := function()
            local comment_pos, masked_unedited;
            if PeekNode() = fail then
                return;
            fi;
            masked_unedited := AutoDoc_Mask_Line( current_line_unedited );
            #! @DONT_SCAN_NEXT_LINE
            comment_pos := PositionSublist( masked_unedited, "#!" );
            if comment_pos <> fail then
                current_line_unedited := current_line_unedited{[ comment_pos + 2 .. Length( current_line_unedited ) ]};
            fi;
            Add( PeekNode(), current_line_unedited );
        end,

        @Index := function()
            local args, whitesep, key, entry;
            args := current_command[ 2 ];
            whitesep := PositionSublist( args, " " );
            if whitesep <> fail then
                key := args{[ 1..whitesep-1 ]};
                entry := args{[ whitesep+1..Length(args) ]};
            else
                key := args;
                entry := args;
            fi;
            Add( PeekNode(), DocumentationIndexEntry( tree, key, entry ) );
        end,

        @BeginLatexOnly := function()
            Add( PeekNode(), "<Alt Only=\"LaTeX\"><![CDATA[" );
            if current_command[ 2 ] <> "" then
                Add( PeekNode(), current_command[ 2 ] );
            fi;
        end,
        @EndLatexOnly := function()
            if autodoc_read_line = true then
                autodoc_read_line := false;
            fi;
            Add( PeekNode(), "]]></Alt>" );
        end,
        @LatexOnly := function()
            Add( PeekNode(), "<Alt Only=\"LaTeX\"><![CDATA[" );
            Add( PeekNode(), current_command[ 2 ] );
            Add( PeekNode(), "]]></Alt>" );
        end,

        @BeginNotLatex := function()
            Add( PeekNode(), "<Alt Not=\"LaTeX\"><![CDATA[" );
            if current_command[ 2 ] <> "" then
                Add( PeekNode(), current_command[ 2 ] );
            fi;
        end,
        @EndNotLatex := function()
            if autodoc_read_line = true then
                autodoc_read_line := false;
            fi;
            Add( PeekNode(), "]]></Alt>" );
        end,
        @NotLatex := function()
            Add( PeekNode(), "<Alt Not=\"LaTeX\"><![CDATA[" );
            Add( PeekNode(), current_command[ 2 ] );
            Add( PeekNode(), "]]></Alt>" );
        end,

        ## FIXME: The following command is undocumented, and I can't find any
        ## other occurrences of `worksheet_dependencies` in the code. Is this
        ## implementation incomplete? Should it be documented or removed?
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
            example_node := read_session_example( true, plain_text_mode );
            Add( PeekNode(), example_node );
        end,
        @BeginExampleSession := ~.@ExampleSession,

        @LogSession := function()
            local example_node;
            example_node := read_session_example( false, plain_text_mode );
            Add( PeekNode(), example_node );
        end,
        @BeginLogSession := ~.@LogSession,
    );
    
    ## The following commands are specific for worksheets. They do not have a packageinfo,
    ## and no place to extract those infos. So these commands are needed to make insert the
    ## information directly into the document.
    ## Unfortunately, there didn't seem to be a way to use exactly the same
    ## list for the documentation and the code, as with the list of recognized
    ## declarations, but at least moving the documentation next to the list
    ## should help keep them in sync.
    ### Would be nice if there were a way to avoid repeating the list of these
    ### commands *three* times (once for index, once for documentation, once
    ### for code)
    title_item_list := [ "Title", "Subtitle", "Version", "TitleComment", "Author",
                         "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ];
    create_title_item_function := function( name )
        return function()
            if not IsBound( tree!.TitlePage.( name ) ) then
                tree!.TitlePage.( name ) := [ ];
            fi;
            Add( tree!.TitlePage.( name ), current_command[ 2 ] );
            PushNode( tree!.TitlePage.( name ) );
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
    Info( InfoGAPDoc, 2, "AutoDoc scanning files: ", filename_list, "\n");
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
            masked_current_line := current_command[ 3 ];
            if autodoc_read_line = true or autodoc_read_line = fail then
                was_declaration := Scan_for_Declaration_part( );
                if not was_declaration and autodoc_read_line <> fail then
                    autodoc_read_line := false;
                fi;
            fi;
        od;
    od;
end );
