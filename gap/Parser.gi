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
    #! @BeginChunk recognized_declarators
    #!   The &GAP; declarations recognized by &AutoDoc; consist of the
    #!   following:
    declaration_cases := rec(
        #! @BeginAutoDocPlainText
        DeclareCategoryCollections
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Filt", doc_stream_type := "categories",
                          coll_suffix := true, arguments := "obj",
                          has_filters := "No" )
        #! @BeginAutoDocPlainText
        , DeclareCategory
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Filt", doc_stream_type := "categories",
                          has_filters := 1 )
        #! @BeginAutoDocPlainText
        , DeclareRepresentation
        #!@EndAutoDocPlainText
        := ~.DeclareCategory
        #! @BeginAutoDocPlainText
        , DeclareAttribute
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Attr", doc_stream_type := "attributes",
                          has_filters := 1 )
        #! @BeginAutoDocPlainText
        , DeclareProperty
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Prop", doc_stream_type := "properties",
                          has_filters := 1 )
        #! @BeginAutoDocPlainText
        , DeclareOperation
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Oper", doc_stream_type := "methods",
                          has_filters := "List" )
        #! @BeginAutoDocPlainText
        , DeclareFilter
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Filt", arguments := "arg",
                          doc_stream_type := "global_functions",
                          has_filters := "No" )
        #! @BeginAutoDocPlainText
        , DeclareGlobalFunction
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Func", arguments := "arg",
                          doc_stream_type := "global_functions",
                          has_filters := "No" )
        #! @BeginAutoDocPlainText
        , KeyDependentOperation
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Oper", doc_stream_type := "methods",
                          has_filters := 2 )
        #! @BeginAutoDocPlainText
        , DeclareSynonym
        #!@EndAutoDocPlainText
        := {item} -> rec( has_filters := "No" )
        #! @BeginAutoDocPlainText
        , DeclareGlobalVariable
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "Var",
                          doc_stream_type := "global_variables",
                          return_value := NotFunctional@(item,
                                              "DeclareGlobalVariable"),
                          has_filters := "No" )
        #! @BeginAutoDocPlainText
        , DeclareInfoClass
        #!@EndAutoDocPlainText
        := {item} -> rec( item_type := "InfoClass",
                          doc_stream_type := "info_classes",
                          return_value := NotFunctional@(item,
                                              "DeclareInfoClass"),
                          has_filters := "No")
        #! @BeginAutoDocPlainText
        , DeclareConstructor
        #!@EndAutoDocPlainText
        := function ( item )
            if IsPackageMarkedForLoading( "GAPDoc", ">=1.6.1" ) then
                return rec( item_type := "Constr", doc_stream_type := "methods",
                            has_filters := "List");
            fi;
            AutoDoc_PrintWarningForConstructor();
            return rec( item_type := "Oper", doc_stream_type := "methods",
                        has_filters := "List" );
        end
    );
    #! , InstallMethod, and InstallOtherMethod.
    #! @EndChunk
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
          current_line_unedited,
          ReadLineWithLineCount, Normalized_ReadLine, line_number, ErrorWithPos, create_title_item_function,
          current_line_positition_for_filter, read_session_example,
          StackNonEmpty, StackEmpty, PopNode, PeekNode, PushNode, ResetStack;
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
    StackNonEmpty := {} -> Length( active_node_stack ) > 0;
    StackEmpty := {} -> Length( active_node_stack ) = 0;
    PopNode := function ()
        if StackNonEmpty() then return Remove( active_node_stack ); fi;
        return fail;
    end;
    PeekNode := function ()
        if StackNonEmpty() then
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
    read_session_example := function( is_tested_example, pt_mode )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line, item_temp, example_node, incorporate_this_line;
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
            if filestream = fail or ( is_tested_example and PositionSublist( temp_curr_line, "@EndExampleSession" ) <> fail )
                                 or ( not is_tested_example and PositionSublist( temp_curr_line, "@EndLogSession" ) <> fail ) then
                break;
            fi;
            incorporate_this_line := pt_mode;
            if not pt_mode then
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
    command_function_record := rec(
        ## HACK: Needed for AutoDoc parser to be scanned savely.
        ##       The lines where the AutoDoc comments are
        ##       searched cause problems otherwise.
        @DONT_SCAN_NEXT_LINE := function()
            ReadLineWithLineCount( filestream );
        end,
        #! @Chapter Comments
        #! @Section Declarations
        #! @BeginChunk documenting_declaration_commands
        #! @Subsection @Description
        #! @SubsectionTitle @Description <A>descr</A>
        #! @Index @Description `@Description`
        #!   Adds the text in the following lines of the &AutoDoc; to the
        #!   description of the declaration in the manual. Lines are until the
        #!   next &AutoDoc; command or until the declaration is reached.
        @Description := function()
            local man_item;
            man_item := new_man_item();
            SetManItemToDescription( man_item );
            NormalizeWhitespace( current_command[ 2 ] );
            if current_command[ 2 ] <> "" then
                Add( man_item, current_command[ 2 ] );
            fi;
        end,
        #! @Subsection @Returns
        #! @SubsectionTitle @Returns <A>ret_val</A>
        #! @Index @Returns `@Returns`
        #!   The string <A>ret_val</A> is added to the documentation of the
        #!   declaration, with the text <Q>Returns: </Q> put in front of
        #!   it. This should usually give a brief hint about the type or
        #!   meaning of the value returned by the documented function.
        @Returns := function()
            local man_item;
            man_item := new_man_item();
            SetManItemToReturnValue( man_item );
            if current_command[ 2 ] <> "" then
                Add( man_item, current_command[ 2 ] );
            fi;
        end,
        #! @Subsection @Arguments
        #! @SubsectionTitle @Arguments <A>args</A>
        #! @Index @Arguments `@Arguments`
        #!   The string <A>args</A> contains a description of the arguments
        #!   the declared function expects, including optional parts, which
        #!   are denoted by square brackets. The argument names can be
        #!   separated by whitespace, commas or square brackets for the
        #!   optional arguments, like
        #!   <Q>grp[, elm]</Q> or <Q>xx[y[z] ]</Q>. If &GAP; options are
        #!   used, this can be followed by a colon : and one or more
        #!   assignments, like <Q>n[, r]: tries := 100</Q>.
        @Arguments := function()
            new_man_item()!.arguments := current_command[ 2 ];
        end,
        #! @Subsection @Group
        #! @SubsectionTitle @Group <A>grpname</A>
        #! @Index @Group `@Group`
        #!   Adds the following declaration to a group named <A>grpname</A>.
        #!   See section <Ref Sect="Section_Groups"/> for more information
        #!   about groups.
        @Group := function()
            local group_name;
            group_name := ReplacedString( current_command[ 2 ], " ", "_" );
            SetGroupName( new_man_item(), group_name );
        end,
        #! @Subsection @Label
        #! @SubsectionTitle @Label <A>label</A>
        #! @Index @Label `@Label`
        #!   Adds label to the function as label.
        #!   If this is not specified, then for declarations that involve a
        #!   list of input filters (as is the case for
        #!   <C>DeclareOperation</C>, <C>DeclareAttribute</C>, etc.),
        #!   a default label is generated from this filter list.
        #! @EndSubsection
        #! @BeginLogSession
        #! #! @Label testlabel
        #! DeclareProperty( "AProperty",
        #!                  IsObject );
        #! @EndLogSession
        #! leads to this:
        #! <ManSection>
        #!  <Prop Arg="arg" Name="AProperty" Label="testlabel"/>
        #!  <Returns> <C>true</C> or <C>false</C>
        #!  </Returns>
        #!  <Description>
        #!  </Description>
        #! </ManSection>
        #! &nbsp;<Br/>
        #! while
        #! @BeginLogSession
        #! #!
        #! DeclareProperty( "AProperty",
        #!                  IsObject );
        #! @EndLogSession
        #! leads to this:
        #! <ManSection>
        #!  <Prop Arg="arg" Name="AProperty" Label="for IsObject"/>
        #!  <Returns> <C>true</C> or <C>false</C>
        #!  </Returns>
        #!  <Description>
        #!  </Description>
        #! </ManSection>
        @Label := function()
            new_man_item()!.tester_names := current_command[ 2 ];
        end,
        #! @Subsection @ChapterInfo
        #! @SubsectionTitle @ChapterInfo <A>chapter, section</A>
        #! @Index @ChapterInfo `@ChapterInfo`
        #!   Adds the entry to the given chapter and section. Here,
        #!   <A>chapter</A> and <A>section</A> are the respective names.
        @ChapterInfo := function()
            local spec_chapter_info;
            spec_chapter_info := SplitString( current_command[ 2 ], "," );
            spec_chapter_info := List( spec_chapter_info, i -> ReplacedString( StripBeginEnd( i, " " ), " ", "_" ) );
            SetChapterInfo( new_man_item(), spec_chapter_info );
        end,
        #! @Subsection @ItemType
        #! @SubsectionTitle @ItemType <A>type [stream]</A>
        #! @Index @ItemType `@ItemType`
        #!   Normally &AutoDoc; is able to infer whether a declaration is for
        #!   a global function, method, operator, filter, attribute, property,
        #!   etc.  However, in some cases it cannot, for example in the case
        #!   of a `DeclareSynonym` declaration, or in some
        #!   `InstallOtherMethod` cases. In such cases, you can use the
        #!   `@ItemType` command to supply that information. The first
        #!   argument <A>type</A> specifies the type of the item;
        #!   it must be the name of the &GAPDoc;
        #!   entity corresponding to the desired type, e.g. `Filt` for
        #!   filters, `Func` for functions, and so on. See the &GAPDoc;
        #!   documentation for a full list. The optional second argument
        #!   <A>stream</A> specifies the default documentation stream of
        #!   &AutoDoc; in which the documentation will be emitted if no
        #!   section is specified.
        @ItemType := function()
            local man_item, splitargs;
            man_item := new_man_item();
            splitargs := SplitString( current_command[ 2 ], " \t" );
            man_item!.item_type := splitargs[ 1 ];
            if Length( splitargs ) > 1 then
                man_item!.doc_stream_type := splitargs[ 2 ];
            fi;
        end,
        #! @Subsection @Level
        #! @SubsectionTitle @Level <A>lvl</A>
        #! @Index @Level `@Level`
        #!    Sets the level of documentation of this declaration. (Note that
        #!    this same command can also set the level of the current section or
        #!    chapter.) Levels are used to selectively prune portions of the
        #!    documentation, only level 0 (the default) documentation is
        #!    generated by default, but higher-level documentation can be
        #!    generated on request. See section <Ref Sect="Section_Level"/>
        #!    for more information about levels.
        @Level := function()
            PeekNode()!.level := Int( current_command[ 2 ] );
        end,
        #! @EndSubsection
        #! @EndChunk
        #
        #! @Chapter Comments
        #! @Section Others
        #! @BeginChunk other_commands
        #! @Subsection @Chapter
        #! @SubsectionTitle @Chapter <A>name</A>
        #! @Index @Chapter `@Chapter`
        #! @Index @ChapterLabel `@ChapterLabel`
        #! @Index @ChapterTitle `@ChapterTitle`
        #!    Sets the active chapter, all subsequent functions which do not
        #!    have an explicit chapter declared in their AutoDoc comment via
        #!    `@ChapterInfo` will be added to this chapter. Also all text
        #!    comments, i.e. lines that begin with `#!` without a command, and
        #!    which do not follow after `@Description`, will be added to the
        #!    chapter as regular text. Additionally, the chapter's label wil
        #!    be set to `Chapter_`<A>name</A>.
        #!
        #! Example:
        #! @BeginLogSession
        #!#! @Chapter My chapter
        #!#!  This is my chapter.
        #!#!  I document my stuff in it.
        #! @EndLogSession
        #!    The `@ChapterLabel` <A>label</A> command can be used to set the
        #!    label of the chapter to `Chapter_`<A>label</A> instead of
        #!    `Chapter_`<A>name</A>.
        #!
        #!    Additionally, the chapter will be stored as
        #!    `_Chapter_`<A>label</A>`.xml`.
        #!
        #!    The `@ChapterTitle` <A>title</A> command can be used to set a
        #!    heading for the chapter that is different from <A>name</A>.
        #!    Note that the title does not affect the label.
        #!
        #!    If you use all three commands, i.e.,
        #! @BeginLogSession
        #!#! @Chapter name
        #!#! @ChapterLabel label
        #!#! @ChapterTitle title
        #! @EndLogSession
        #! `title` is used for the headline, `label` for cross-referencing,
        #! and `name` for setting the same chapter as active chapter again.
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
        #! @Subsection @Section
        #! @SubsectionTitle @Section <A>name</A>
        #! @Index @Section `@Section`
        #! @Index @SectionLabel `@SectionLabel`
        #! @Index @SectionTitle `@SectionTitle`
        #!   Sets an active section like `@Chapter` sets an active chapter.
        #! @BeginLogSession
        #!#! @Section My first manual section
        #!#!  In this section I am going to document my first method.
        #! @EndLogSession
        #!   The `@SectionLabel` <A>label</A> command can be used to set the
        #!   label of the section to `Section_`<A>label</A> instead of
        #!   `Chapter_chaptername_Section_`<A>name</A>.
        #!
        #!   The `@SectionTitle` <A>title</A> command can be used to set a
        #!   heading for the section that is different from <A>name</A>.
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
        #! @Subsection @EndSection
        #! @Index @EndSection `@EndSection`
        #!   Closes the current section. Please be careful here. Closing a
        #!   section before opening it might cause unexpected errors.
        #! @BeginLogSession
        #!#! @EndSection
        #!#### The following text again belongs to the chapter
        #!#! Now we could start a second section if we want to.
        #! @EndLogSession
        @EndSection := function()
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
        end,
        #! @Subsection @Subsection
        #! @SubsectionTitle @Subsection <A>name</A>
        #! @Index @Subsection `@Subsection`
        #! @Index @SubsectionLabel `@SubsectionLabel`
        #! @Index @SubsectionTitle `@SubsectionTitle`
        #!   Sets an active subsection like `@Chapter` sets an active
        #!   chapter.
        #! @BeginLogSession
        #!#! @Subsection My first manual subsection
        #!#!  In this subsection I am going to document my first example.
        #! @EndLogSession
        #!   Analogous to `@SectionLabel`, the `@SubsectionLabel` <A>label</A>
        #!   command can be used to set the label of the subsection to
        #!   `Subsection_`<A>label</A> instead of
        #!   `Chapter_chaptername_Section_sectionname_Subsection_`<A>name</A>.
        #!
        #!   The `@SubsectionTitle` <A>title</A> command can be used to set a
        #!   heading for the subsection that is different from <A>name</A>.
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
                ErrorWithPos( "found @SubsectionLabel with no active Subsection" );
            fi;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            scope_subsection := SubsectionAsChildOf( tree, scope_chapter_info, fail );
            scope_subsection!.additional_label := Concatenation( "Subsection_", label_name );
        end,
        @SubsectionTitle := function()
            local scope_subsection;
            if not IsBound( scope_chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionTitle with no active section" );
            fi;
            scope_subsection := SubsectionAsChildOf( tree, scope_chapter_info, fail );
            scope_subsection!.title_string := current_command[ 2 ];
        end,
        #! @Subsection @EndSubsection
        #! @Index @EndSubsection `@EndSubsection`
        #!   Closes the current subsection. Please be careful here. Closing a
        #!   subsection before opening it might cause unexpected errors.
        #! @BeginLogSession
        #!#! @EndSubsection
        #!#### The following text again belongs to the section
        #!#! Now we are in the section again
        #! @EndLogSession
        @EndSubsection := function()
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
        end,
        #! @Subsection @BeginAutoDoc
        #! @Index @BeginAutoDoc `@BeginAutoDoc`
        #!    Causes all subsequent declarations (until the next `@EndAutoDoc`
        #!    command) to be documented in the manual regardless of whether
        #!    they have any &AutoDoc; comment immediately preceding them.
        @BeginAutoDoc := function()
            autodoc_read_line := fail;
        end,
        @AutoDoc := ~.@BeginAutoDoc,
        #! @Subsection @EndAutoDoc
        #! @Index @EndAutoDoc `@EndAutoDoc`
        #!   Ends any `@BeginAutoDoc` in effect. So from here on, again only
        #!   declarations with an explicit &AutoDoc; comment immediately
        #!   preceding them are added to the manual.
        #! @BeginLogSession
        #!#! @BeginAutoDoc
        #!
        #!DeclareOperation( "Operation1", [ IsList ] );
        #!
        #!DeclareProperty( "IsProperty", IsList );
        #!
        #!#! @EndAutoDoc
        #!
        #!DeclareOperation( "Operation2", [ IsString ] );
        #! @EndLogSession
        #!   Both of `Operation1` and `IsProperty` would appear in the manual,
        #!   but `Operation2` would not.
        @EndAutoDoc := function()
            autodoc_read_line := false;
        end,
        #! @Subsection @BeginGroup
        #! @SubsectionTitle @BeginGroup <A>[grpname]</A>
        #! @Index @BeginGroup `@BeginGroup`
        #!    Starts a group. All following documented declarations without an
        #!    explicit `@Group` command are grouped together in the same group
        #!    with the given name. If no name is given, then a new nameless
        #!    group is generated. The effect of this command is ended when an
        #!    `@EndGroup` command is reached.
        #!
        #!    See section <Ref Sect="Section_Groups"/> for more information
        #!    about groups.
        @BeginGroup := function()
            local grp;
            if current_command[ 2 ] = "" then
                groupnumber := groupnumber + 1;
                current_command[ 2 ] := Concatenation( "AutoDoc_generated_group", String( groupnumber ) );
            fi;
            scope_group := ReplacedString( current_command[ 2 ], " ", "_" );
        end,
        #! @Subsection @Endgroup
        #! @Index @EndGroup `@EndGroup`
        #!    Ends the current group.
        #! @BeginLogSession
        #! #! @BeginGroup MyGroup
        #! #!
        #! DeclareAttribute( "GroupedAttribute",
        #!                   IsList );
        #!
        #! DeclareOperation( "NonGroupedOperation",
        #!                   [ IsObject ] );
        #!
        #! #!
        #  !DeclareOperation( "GroupedOperation",
        #!                    [ IsList, IsRubbish ] );
        #! #! @EndGroup
        #! @EndLogSession
        #!   See section <Ref Sect="Section_Groups"/> for more information
        #!   about groups.
        @EndGroup := function()
            Unbind( scope_group );
        end,
        #! @Subsection @SetLevel
        #! @SubsectionTitle @SetLevel <A>lvl</A>
        #! @Index @SetLevel `@SetLevel`
        #!    Sets the current level of the documentation. All items created
        #!    after this, chapters, sections, and items, are given the level
        #!    <A>lvl</A>, until the `@ResetLevel` command resets the
        #!    level to 0 or another level is set.
        #!
        #!    See section <Ref Sect="Section_Level"/> for more information
        #!    about levels.
        @SetLevel := function()
            level_scope := Int( current_command[ 2 ] );
        end,
        #! @Subsection @ResetLevel
        #! @Index @ResetLevel `@ResetLevel`
        #!    Resets the current documentation level to 0;
        #!    it is simply an alias for `@SetLevel 0`.
        @ResetLevel := function()
            level_scope := 0;
        end,
        #! @Subsection @BeginExample
        #! @SubsectionTitle @BeginExample and @EndExample
        #! @Index @BeginExample `@BeginExample / @EndExample`
        #!    `@BeginExample` inserts an example into the manual. The syntax
        #!    for examples is different from &GAPDoc;'s example syntax in
        #!    order to have a file that contains the example and is &GAP;
        #!    readable. To achieve this, &GAP; commands are not preceded by a
        #!    comment, while output has to be preceded by an &AutoDoc; comment.
        #!    The `gap>` prompt for the display in the manual is added by
        #!    &AutoDoc;. `@EndExample` ends the example block.
        #! @BeginLogSession
        #!#! @BeginExample
        #!S5 := SymmetricGroup(5);
        #!#! Sym( [ 1 .. 5 ] )
        #!Order(S5);
        #!#! 120
        #!#! @EndExample
        #! @EndLogSession
        #!    The &AutoDoc; command `@Example` is an alias of `@BeginExample`.
        @BeginExample := function()
            local example_node;
            example_node := read_example( true );
            Add( PeekNode(), example_node );
        end,
        @Example := ~.@BeginExample,
        #! @Subsection @BeginExampleSession
        #! @SubsectionTitle @BeginExampleSession and @EndExampleSession
        #! @Index @BeginExampleSession `@BeginExampleSession / @EndExampleSession`
        #!    `@BeginExampleSession` inserts an example into the manual, but
        #!    in a different syntax. To understand the motivation, consider
        #! @BeginLogSession
        #!#! @BeginExample
        #!S5 := SymmetricGroup(5);
        #!#! Sym( [ 1 .. 5 ] )
        #!Order(S5);
        #!#! 120
        #!#! @EndExample
        #! @EndLogSession
        #!    As you can see, the commands are not commented and hence are
        #!    executed when the file containing the example block is read. To
        #!    insert examples directly into source code files, one can instead
        #!    use `@BeginExampleSession`:
        #! @BeginLogSession
        #!#! @BeginExampleSession
        #!#! gap> S5 := SymmetricGroup(5);
        #!#! Sym( [ 1 .. 5 ] )
        #!#! gap> Order(S5);
        #!#! 120
        #!#! @EndExampleSession
        #! @EndLogSession
        #!    It inserts an example into the manual just as `@BeginExample`
        #!    would do, but all lines are commented and therefore not executed
        #!    when the file is read. All lines that should be part of the
        #!    example displayed in the manual have to start with an &AutoDoc;
        #!    comment (`#!`). The comment will be removed, and, if the
        #!    following character is a space, this space will also be
        #!    removed. There is never more than one space removed. To ensure
        #!    examples are correctly colored in the manual, there should be
        #!    exactly one space between `#!` and the `gap>` prompt.
        #!
        #!    The &AutoDoc; command `@ExampleSession` is an alias of
        #!    `@BeginExampleSession`.
        @BeginExampleSession := function()
            local example_node;
            example_node := read_session_example( true, plain_text_mode );
            Add( PeekNode(), example_node );
        end,
        @ExampleSession := ~.@BeginExampleSession,
        #! @Subsection @BeginLog
        #! @SubsectionTitle @BeginLog and @EndLog
        #! @Index @BeginLog `@BeginLog / @EndLog`
        #!    This pair of commands works just like the `@BeginExample` and
        #!    `@EndExample` commands, but the example will not be tested. See
        #!    the &GAPDoc; manual for more information. The &AutoDoc;
        #!    command `@Log` is an alias for `@BeginLog`.
        @BeginLog := function()
            local example_node;
            example_node := read_example( false );
            Add( PeekNode(), example_node );
        end,
        @Log := ~.@BeginLog,
        #! @Subsection @BeginLogSession
        #! @SubsectionTitle @BeginLogSession and @EndLogSession
        #! @Index @BeginLogSession `@BeginLogSession / @EndLogSession`
        #!    This pair of commands works just like the `@BeginExampleSession`
        #!    and `@EndExampleSession` commands, but the example will not be
        #!    tested if manual examples are run. See
        #!    the &GAPDoc; manual for more information. The &AutoDoc;
        #!    command `@LogSession` is an alias for `@BeginLogSession`.
        @LogSession := function()
            local example_node;
            example_node := read_session_example( false, plain_text_mode );
            Add( PeekNode(), example_node );
        end,
        @BeginLogSession := ~.@LogSession,
        #! @Subsection @DoNotReadRestOfFile
        #! @Index @DoNotReadRestOfFile `@DoNotReadRestOfFile`
        #!    Prevents the rest of the file from being read by the
        #!    &AutoDoc; parser. Useful for unfinished or temporary files.
        #! @BeginLogSession
        #!#! This will appear in the manual
        #!
        #!#! @DoNotReadRestOfFile
        #!
        #!#! This will not appear in the manual.
        #! @EndLogSession
        @DoNotReadRestOfFile := function()
            Reset();
            rest_of_file_skipped := true;
        end,
        #! @Subsection @BeginChunk
        #! @SubsectionTitle @BeginChunk <A>name</A>, @EndChunk, and @InsertChunk <A>name</A>
        #! @Index @BeginChunk `@BeginChunk / @EndChunk / @InsertChunk`
        #!    Text inside a `@BeginChunk` / `@EndChunk` pair will not be
        #!    inserted into the final documentation directly. Instead, the text
        #!    is stored in an internal buffer. That chunk of text can then
        #!    later on be inserted in any other place by using the
        #!    `@InsertChunk` <A>name</A> command. Note that a chunk may
        #!    contain any autodoc components (text, examples, sections, etc.)
        #!    except for chapters. (To control the overall order of chapters,
        #!    you may want to arrange for a file declaring all of the
        #!    chapters to be processed early in &AutoDoc;'s operation, for
        #!    example by using the `files` entry of the `autodoc` record in the
        #!    invocation of &AutoDoc;, see
        #!    <Ref Label="AutodocFilesOption" Text="the files option"/>.)
        #!
        #!    If you do not provide an `@EndChunk`, the chunk ends at the end of
        #!    the file.
        #! @BeginLogSession
        #!#! @BeginChunk MyChunk
        #!#! Hello, world.
        #!#! @EndChunk
        #!
        #!#! @InsertChunk MyChunk
        #!## The text "Hello, world." is inserted right before this.
        #! @EndLogSession
        #!    You can use this to define an example like this in one file:
        #! @BeginLogSession
        #!#! @BeginChunk Example_Symmetric_Group
        #!#! @BeginExample
        #!S5 := SymmetricGroup(5);
        #!#! Sym( [ 1 .. 5 ] )
        #!Order(S5);
        #!#! 120
        #!#! @EndExample
        #!#! @EndChunk
        #! @EndLogSession
        #!    And then later, insert the example in a different file, like
        #!    this:
        #! @BeginLogSession
        #!#! @InsertChunk Example_Symmetric_Group
        #! @EndLogSession
        #!    The &AutoDoc; commands `@BeginSystem, @EndSystem,` and
        #!    `@InsertSystem` are deprecated aliases for these "chunk"
        #!    commands. Please use the "chunk" versions instead.
        @InsertChunk := function()
            Add( PeekNode(), DocumentationDummy( tree, current_command[ 2 ] ) );
        end,
        @InsertSystem := ~.@InsertChunk,
        @BeginChunk := function()
            PushNode( DocumentationDummy( tree, current_command[ 2 ] ) );
        end,
        @Chunk := ~.@BeginChunk,
        @System := ~.@BeginChunk,
        @BeginSystem := ~.@BeginChunk,
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
        @EndSystem := ~.@EndChunk,
        #! @Subsection @BeginCode
        #! @SubsectionTitle @BeginCode <A>name</A>, @EndCode, @InsertCode, @HereCode <A>name</A>
        #! @Index @BeginCode `@BeginCode / @EndCode / @InsertCode / @HereCode`
        #!    The text between `@BeginCode` <A>name</A> and `@EndCode` is
        #!    inserted verbatim at the point where `@InsertCode` is called.
        #!    This is useful to insert code excerpts directly into the manual.
        #!    If you want to insert code immediately at the current point
        #!    in the documentation, use `@HereCode` rather than `@BeginCode`;
        #!    it still matches with `@EndCode`, but no <A>name</A> or
        #!    `@InsertCode` is necessary.
        #! @BeginLogSession
        #!#! @BeginCode Increment
        #!i := i + 1;
        #!#! @EndCode
        #!
        #!#! @InsertCode Increment
        #!## Code is inserted immediately above here.
        #! @EndLogSession
        @BeginCode := function()
            local tmp_system;
            tmp_system := DocumentationCode( tree, current_command[ 2 ] );
            Append( tmp_system!.content, read_code() );
        end,
        @Code := ~.@BeginCode,
        @HereCode := function()
            local tmp_system;
            groupnumber := groupnumber + 1;
            tmp_system :=
              DocumentationCode( tree, Concatenation( "Anon_Code_",
                                                      String( groupnumber ) ) );
            Append( tmp_system!.content, read_code() );
            Add( PeekNode(), tmp_system );
        end,
        @InsertCode := ~.@InsertSystem,
        #! @Subsection @Index
        #! @SubsectionTitle @Index <A>key [entry]</A>
        #! @Index @Index `@Index`
        #!    Inserts an entry in the index sorted by <A>key</A> with written
        #!    entry <A>entry</A> (which defaults to <A>key</A> if <A>entry</A>
        #!    is omitted. The index entry refers to the point in the manual at
        #!    which the `@Index` command occurs. Note that documented
        #!    declarations generate index entries automatically, you don't
        #!    need to use an `@Index` call for each one.
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
        #! @Subsection @LatexOnly
        #! @SubsectionTitle @LatexOnly <A>text</A>, @BeginLatexOnly, and @EndLatexOnly
        #! @Index @LatexOnly `@LatexOnly / @BeginLatexOnly / @EndLatexOnly`
        #!    Code inserted between `@BeginLatexOnly` and `@EndLatexOnly` or
        #!    after `@LatexOnly` on a line is only inserted
        #!    in the PDF version of the manual or worksheet. It can hold
        #!    arbitrary LaTeX commands.
        #! @BeginLogSession
        #!#! @BeginLatexOnly
        #!#! \include{picture.tex}
        #!#! @EndLatexOnly
        #!
        #!#! @LatexOnly \include{picture2.tex}
        #! @EndLogSession
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
        #! @Subsection @BeginAutoDocPlainText
        #! @SubsectionLabel PlainCommands
        #! @SubsectionTitle @BeginAutoDocPlainText and @EndAutoDocPlainText
        #! @Index @BeginAutoDocPlainText `@BeginAutoDocPlainText / @EndAutoDocPlainText`
        #!    `@BeginAutoDocPlainText` mode turns on plain text mode, in which
        #!    `#!` comment characters are not needed for a line to be
        #!    processed by &AutoDoc; -- or, equivalently, in which every line
        #!    treated as if it were preceded by a `#!`.
        #!    `@EndAutoDocPlainText` reverts to ordinary mode, in which the
        #!    `#!` comment characters are necessary for a line to be processed
        #!    by &AutoDoc;. For more information on plain text mode, see
        #!    <Ref Sect="Section_Plain"/>.
        @BeginAutoDocPlainText := function()
            plain_text_mode := true;
        end,
        @AutoDocPlainText := ~.@BeginAutoDocPlainText,
        @EndAutoDocPlainText := function()
            plain_text_mode := false;
        end,
        #! @EndChunk
        @BREAK := function()
            ErrorWithPos( current_command[ 2 ] );
        end,
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
        ## FixMe: The following command is undocumented, and I can't find any
        ## other occurrences of `worksheet_dependencies` in the code. Is this
        ## implementation incomplete? Should it be documented or removed?
        @Dependency := function()
            if not IsBound( tree!.worksheet_dependencies ) then
                tree!.worksheet_dependencies := [ ];
            fi;
            NormalizeWhitespace( current_command[ 2 ] );
            Add( tree!.worksheet_dependencies, SplitString( current_command[ 2 ], " " ) );
        end
    );
    
    ## The following commands are specific for worksheets. They do not have a packageinfo,
    ## and no place to extract those infos. So these commands are needed to make insert the
    ## information directly into the document.
    ## Unfortunately, there didn't seem to be a way to use exactly the same
    ## list for the documentation and the code, as with the list of recognized
    ## declarations, but at least moving the documentation next to the list
    ## should help keep them in sync.
    #! @Chapter Comments
    #! @BeginChunk titlepage_commands
    #! @Section TitlepageCommands
    #! @SectionTitle Title page commands
    ### Would be nice if there were a way to avoid repeating the list of these
    ### commands *three* times (once for index, once for documentation, once
    ### for code)
    #! @Index @Title `@Title`
    #! @Index @Subtitle `@Subtitle`
    #! @Index @Version `@Version`
    #! @Index @TitleComment `@TitleComment`
    #! @Index @Author `@Author`
    #! @Index @Date `@Date`
    #! @Index @Address `@Address`
    #! @Index @Abstract `@Abstract`
    #! @Index @Copyright `@Copyright`
    #! @Index @Acknowledgements `@Acknowledgements`
    #! @Index @Colophon `@Colophon`
    #!    The following commands can be used to add the corresponding parts to
    #!    the title page of the document, in case the scaffolding is
    #!    enabled.
    #! * `@Title`
    #! * `@Subtitle`
    #! * `@Version`
    #! * `@TitleComment`
    #! * `@Author`
    #! * `@Date`
    #! * `@Address`
    #! * `@Abstract`
    #! * `@Copyright`
    #! * `@Acknowledgements`
    #! * `@Colophon`
    #!
    #! These commands add the following lines at the corresponding point of
    #! the title page. Please note that many of those things can be (better)
    #! extracted from the `PackageInfo.g`. In case you use the above commands,
    #! the extracted or in-scaffold-defined items will be overwritten. While
    #! this is not very useful for documenting packages, they are necessary
    #! for worksheets created with <Ref Func="AutoDocWorksheet"/>,
    #! since they do not have a `PackageInfo.g` from which to extract any of
    #! this information.
    title_item_list := [ "Title", "Subtitle", "Version", "TitleComment", "Author",
                         "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ];
    #! @EndSection
    #! @EndChunk
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
