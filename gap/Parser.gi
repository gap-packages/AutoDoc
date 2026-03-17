# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

##
InstallValue( AUTODOC_ITEM_TYPE_INFO, rec(
    Attr := rec(
        chapter_bucket := "attributes",
        is_function_like := true
    ),
    Cat := rec(
        chapter_bucket := "categories",
        filter_type := "Category",
        item_type_override := "Filt",
        is_function_like := true
    ),
    Coll := rec(
        chapter_bucket := "collections",
        filter_type := "Collection",
        item_type_override := "Filt",
        is_function_like := true
    ),
    Constr := rec(
        chapter_bucket := "methods",
        is_function_like := true
    ),
    Fam := rec(
        chapter_bucket := "global_variables",
        is_function_like := false
    ),
    Filt := rec(
        chapter_bucket := "filters",
        is_function_like := true
    ),
    Func := rec(
        chapter_bucket := "global_functions",
        is_function_like := true
    ),
    InfoClass := rec(
        chapter_bucket := "info_classes",
        is_function_like := false
    ),
    Meth := rec(
        chapter_bucket := "methods",
        is_function_like := true
    ),
    Oper := rec(
        chapter_bucket := "methods",
        is_function_like := true
    ),
    Prop := rec(
        chapter_bucket := "properties",
        is_function_like := true
    ),
    Repr := rec(
        chapter_bucket := "representations",
        filter_type := "Representation",
        item_type_override := "Filt",
        is_function_like := true
    ),
    Var := rec(
        chapter_bucket := "global_variables",
        is_function_like := false
    )
));

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

## Scans a string for <char> after <not_before_char> appeared.
## This is necessary to scan the filter list for method declarations
## that contain \[\]. 
BindGlobal( "AUTODOC_PositionElementIfNotAfter",
  function( str, char, not_before_char )
    local pos;
    if Length( str ) > 0 and str[ 1 ] = char then
        return 1;
    fi;
 
    for pos in [ 2 .. Length( str ) ] do
        if str[ pos ] = char and str[ pos - 1 ] <> not_before_char then
            return pos;
        fi;
    od;
    return fail;
end );

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
  function( current_item, type, default_chapter_data )
    local item_rec, filter_style, default_type, item_type, item_type_info,
          default_boolean_return;
    item_rec := current_item;
    default_boolean_return := "<K>true</K> or <K>false</K>";
    if PositionSublist( type, "DeclareCategoryCollections") <> fail then
        default_type := "Coll";
        filter_style := "none";
        if not IsBound( item_rec!.arguments ) then
            item_rec!.arguments := "obj";
        fi;
        item_rec!.coll_suffix := true;
    elif PositionSublist( type, "DeclareCategory" ) <> fail then
        default_type := "Cat";
        filter_style := "single";
    elif PositionSublist( type, "DeclareRepresentation" ) <> fail then
        default_type := "Repr";
        filter_style := "single";
    elif PositionSublist( type, "DeclareAttribute" ) <> fail then
        default_type := "Attr";
        filter_style := "single";
    elif PositionSublist( type, "DeclareSynonymAttr" ) <> fail then
        default_type := "Attr";
        filter_style := "none";
    elif PositionSublist( type, "DeclareProperty" ) <> fail then
        default_type := "Prop";
        filter_style := "single";
    elif PositionSublist( type, "DeclareSynonym" ) <> fail then
        default_type := "Func";
        filter_style := "none";
    elif PositionSublist( type, "DeclareOperation" ) <> fail then
        default_type := "Oper";
        filter_style := "list";
    elif PositionSublist( type, "DeclareConstructor" ) <> fail then
        default_type := "Constr";
        filter_style := "list";
    elif PositionSublist( type, "DeclareGlobalFunction" ) <> fail then
        default_type := "Func";
        filter_style := "none";
    elif PositionSublist( type, "DeclareGlobalVariable" ) <> fail then
        default_type := "Var";
        filter_style := "none";
    elif PositionSublist( type, "DeclareGlobalName" ) <> fail then
        default_type := "Var";
        filter_style := "none";
        if IsBound( item_rec!.declaration_is_function ) and
           item_rec!.declaration_is_function then
            default_type := "Func";
        fi;
    elif PositionSublist( type, "DeclareFilter" ) <> fail then
        default_type := "Filt";
        filter_style := "none";
    elif PositionSublist( type, "DeclareInfoClass" ) <> fail then
        default_type := "InfoClass";
        filter_style := "none";
    elif PositionSublist( type, "KeyDependentOperation" ) <> fail then
        default_type := "Oper";
        filter_style := "pair";
    else
        return fail;
    fi;

    if IsBound( item_rec!.item_type ) then
        item_type := StripBeginEnd( item_rec!.item_type, " \t\r\n" );
    else
        item_type := default_type;
    fi;
    if not IsBound( AUTODOC_ITEM_TYPE_INFO.( item_type ) ) then
        return fail;
    fi;
    item_type_info := AUTODOC_ITEM_TYPE_INFO.( item_type );
    item_rec!.item_type := item_type;

    if not IsBound( item_rec!.chapter_info ) or item_rec!.chapter_info = [ ] then
        item_rec!.chapter_info :=
            default_chapter_data.( item_type_info.chapter_bucket );
    fi;

    if item_type in [ "Cat", "Coll", "Filt", "Prop", "Repr" ] and
       ( item_rec!.return_value = [ ] or item_rec!.return_value = false ) then
        item_rec!.return_value := [ default_boolean_return ];
    fi;
    if filter_style = "none" and item_type_info.is_function_like and
       not IsBound( item_rec!.arguments ) then
        item_rec!.arguments := "arg";
    elif filter_style = "none" and not item_type_info.is_function_like then
        item_rec!.arguments := fail;
        item_rec!.return_value := false;
    fi;
    return filter_style;
end );

##
InstallGlobalFunction( AutoDoc_Parser_ReadFiles,
  function( filename_list, tree, default_chapter_data )
    local ApplyFilterInfoToCurrentItem, CreateTitleItemFunction, CurrentItem,
          CurrentOrNewManItem, DeclarationDelimiterPosition, ErrorWithPos,
          FinishCurrentManItem, HasCurrentItem, IsMatchingMarkdownFence,
          MarkdownFenceFromLine, NormalizeInputLine, NormalizeItemType,
          NormalizedReadLine, ReadBracketedFilterString, ReadCode,
          ReadExample, ReadInstallMethodArguments,
          ReadInstallMethodFilterString, ReadLineWithLineCount,
          ReadSessionExample, Reset, ScanDeclarePart, ScanForDeclarationPart,
          ScanInstallMethodPart, SetCurrentItem,
          #
          active_title_item_is_multiline, active_title_item_name,
          autodoc_read_line, chapter_info, command_function_record,
          comment_start_pos, context_stack, current_command,
          current_line, current_line_fence, current_line_info,
          current_line_is_fence_delimiter, current_line_positition_for_filter,
          current_line_unedited, filename, filestream, groupnumber,
          line_number, markdown_fence, plain_text_mode, rest_of_file_skipped,
          scope_group, single_line_title_item_list, title_item,
          title_item_list, xml_comment_mode;
    groupnumber := 0;
    autodoc_read_line := false;
    context_stack := [ ];
    chapter_info := [ ];
    line_number := 0;
    active_title_item_name := fail;
    active_title_item_is_multiline := false;

    ReadLineWithLineCount := function( stream )
        line_number := line_number + 1;
        return ReadLine( stream );
    end;
    NormalizedReadLine := function( stream )
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
    HasCurrentItem := function( )
        return Length( context_stack ) > 0;
    end;
    CurrentItem := function( )
        return Last( context_stack );
    end;
    SetCurrentItem := function( item )
        if HasCurrentItem() then
            context_stack[ Length( context_stack ) ] := item;
        else
            Add( context_stack, item );
        fi;
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
    MarkdownFenceFromLine := function( line )
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
    IsMatchingMarkdownFence := function( fence, current_line_fence )
        return current_line_fence <> fail and
               fence <> fail and
               current_line_fence.char = fence.char and
               current_line_fence.length >= fence.length and
               ForAll( current_line_fence.remainder, c -> c in " \t\r\n" );
    end;
    DeclarationDelimiterPosition := function( line )
        return Minimum( [ PositionSublist( line, "," ), PositionSublist( line, ");" ) ] );
    end;
    ReadBracketedFilterString := function( error_message, trim_parts )
        local filter_string, pos, part;
        pos := AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' );
        while pos = fail do
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( error_message );
            fi;
            pos := AUTODOC_PositionElementIfNotAfter( current_line, '[', '\\' );
        od;
        current_line := current_line{[ pos + 1 .. Length( current_line ) ]};
        filter_string := "for ";
        pos := AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' );
        while pos = fail do
            part := current_line;
            if trim_parts then
                part := StripBeginEnd( part, " " );
            fi;
            Append( filter_string, part );
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( error_message );
            fi;
            pos := AUTODOC_PositionElementIfNotAfter( current_line, ']', '\\' );
        od;
        part := current_line{[ 1 .. pos - 1 ]};
        if trim_parts then
            part := StripBeginEnd( part, " " );
        fi;
        Append( filter_string, part );
        current_line := current_line{[ pos + 1 .. Length( current_line ) ]};
        NormalizeWhitespace( filter_string );
        return filter_string;
    end;
    ReadInstallMethodFilterString := function( )
        return ReadBracketedFilterString(
            "unterminated InstallMethod filter list",
            false
        );
    end;
    ReadInstallMethodArguments := function( )
        local pos, argument_string;
        while PositionSublist( current_line, "function(" ) = fail and PositionSublist( current_line, ");" ) = fail do
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated InstallMethod declaration" );
            fi;
        od;
        pos := PositionSublist( current_line, "function(" );
        if pos = fail then
            return fail;
        fi;
        current_line := current_line{[ pos + 9 .. Length( current_line ) ]};
        argument_string := "";
        while PositionSublist( current_line, ")" ) = fail do
            current_line := StripBeginEnd( current_line, " " );
            Append( argument_string, current_line );
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated argument list in InstallMethod declaration" );
            fi;
        od;
        pos := PositionSublist( current_line, ")" );
        Append( argument_string, current_line{[ 1 .. pos - 1 ]} );
        NormalizeWhitespace( argument_string );
        return StripBeginEnd( argument_string, " " );
    end;
    ApplyFilterInfoToCurrentItem := function( filter_string, filter_style )
        local filter_count;
        if IsString( filter_string ) then
            filter_string := ReplacedString( filter_string, "\"", "" );
        fi;
        if filter_string = false then
            return;
        fi;
        if CurrentItem()!.tester_names = fail and StripBeginEnd( filter_string, " " ) <> "for" then
            CurrentItem()!.tester_names := filter_string;
        fi;
        if not IsBound( CurrentItem()!.arguments ) then
            if StripBeginEnd( filter_string, " " ) = "for" then
                CurrentItem()!.arguments := "";
            elif filter_style = "single" then
                CurrentItem()!.arguments := "arg";
            elif filter_style = "pair" then
                CurrentItem()!.arguments := "arg1,arg2";
            elif filter_style = "list" then
                filter_count := Length( SplitString( filter_string, "," ) );
                CurrentItem()!.arguments := List(
                    [ 1 .. filter_count ],
                    i -> Concatenation( "arg", String( i ) )
                );
                if filter_count = 1 then
                    CurrentItem()!.arguments := "arg";
                else
                    CurrentItem()!.arguments := JoinStringsWithSeparator( CurrentItem()!.arguments, "," );
                fi;
            fi;
        fi;
    end;
    NormalizeItemType := function( item_type )
        local supported_types;
        item_type := StripBeginEnd( item_type, " \t\r\n" );
        if IsBound( AUTODOC_ITEM_TYPE_INFO.( item_type ) ) then
            return item_type;
        fi;
        supported_types := JoinStringsWithSeparator(
            Set( RecNames( AUTODOC_ITEM_TYPE_INFO ) ),
            ", "
        );
        ErrorWithPos(
            Concatenation(
                "unknown @ItemType ", item_type,
                "; expected one of ", supported_types
            )
        );
    end;
    CurrentOrNewManItem := function( )
        local man_item;
        if HasCurrentItem() and IsTreeForDocumentationNodeForManItemRep( CurrentItem() ) then
            return CurrentItem();
        fi;

        # implicitly end any subsection
        if IsBound( chapter_info[ 3 ] ) then
            Unbind( chapter_info[ 3 ] );
            SetCurrentItem( SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] ) );
        fi;

        man_item := DocumentationManItem( );
        if IsBound( scope_group ) then
            SetGroupName( man_item, scope_group );
        fi;
        man_item!.chapter_info := ShallowCopy( chapter_info );
        man_item!.tester_names := fail;
        Add( context_stack, man_item );
        return man_item;
    end;
    FinishCurrentManItem := function( )
        local man_item;
        man_item := CurrentItem();
        Remove( context_stack );
        if IsBound( man_item!.chapter_info ) then
            SetChapterInfo( man_item, man_item!.chapter_info );
        fi;
        if Length( ChapterInfo( man_item ) ) <> 2 then
            ErrorWithPos( "declarations must be documented within a section" );
        fi;
        Add( tree, man_item );
    end;
    ScanDeclarePart := function( declare_position )
        local current_type, filter_string, filter_style, i, name, pos;
        CurrentOrNewManItem();
        current_line := current_line{[ declare_position .. Length( current_line ) ]};
        pos := PositionSublist( current_line, "(" );
        if pos = fail then
            ErrorWithPos( "Something went wrong" );
        fi;
        current_type := current_line{ [ 1 .. pos - 1 ] };
        filter_style := AutoDoc_Type_Of_Item( CurrentItem(), current_type, default_chapter_data );
        if filter_style = fail then
            ErrorWithPos( "Unrecognized scan type" );
            return false;
        fi;
        current_line := current_line{ [ pos + 1 .. Length( current_line ) ] };
        while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated declaration header" );
            fi;
        od;
        current_line := StripBeginEnd( current_line, " " );
        name := current_line{ [ 1 .. DeclarationDelimiterPosition( current_line ) - 1 ] };
        name := StripBeginEnd( ReplacedString( name, "\"", "" ), " " );

        # Deal with DeclareCategoryCollections: this has some special
        # rules on how the name of a new category is derived from the
        # string given to it. Since the code for that is not available in
        # a separate GAP function, we have to replicate this logic here.
        # To understand what's going on, please refer to the
        # DeclareCategoryCollections documentation and implementation.
        if IsBound(CurrentItem()!.coll_suffix) then
            if EndsWith(name, "Collection") then
                name := name{[1..Length(name)-6]};
            fi;
            if EndsWith(name, "Coll") then
                CurrentItem()!.coll_suffix := "Coll";
            else
                CurrentItem()!.coll_suffix := "Collection";
            fi;
            Append(name, CurrentItem()!.coll_suffix);
        fi;
        CurrentItem()!.name := name;

        current_line := current_line{ [ DeclarationDelimiterPosition( current_line ) + 1 .. Length( current_line ) ] };
        filter_string := "for ";
        if filter_style = "single" or filter_style = "pair" then
            for i in [ 1 .. 2 ] do
                if filter_style = "single" and i = 2 then
                    break;
                fi;
                while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                    Append( filter_string, StripBeginEnd( current_line, " " ) );
                    current_line := NormalizedReadLine( filestream );
                    if current_line = fail then
                        ErrorWithPos( "unterminated declaration filter list" );
                    fi;
                od;
                current_line_positition_for_filter := DeclarationDelimiterPosition( current_line ) - 1;
                Append( filter_string, StripBeginEnd( current_line{ [ 1 .. current_line_positition_for_filter ] }, " " ) );
                current_line := current_line{[ current_line_positition_for_filter + 1 .. Length( current_line ) ]};
                if current_line[ 1 ] = ',' then
                    current_line := current_line{[ 2 .. Length( current_line ) ]};
                elif current_line[ 1 ] = ')' then
                    current_line := current_line{[ 3 .. Length( current_line ) ]};
                fi;
                if filter_style = "pair" and i = 1 then
                    Append( filter_string, ", " );
                fi;
            od;
        elif filter_style = "list" then
            filter_string := ReadBracketedFilterString(
                "unterminated declaration filter list",
                true
            );
        else
            filter_string := false;
        fi;
        ApplyFilterInfoToCurrentItem( filter_string, filter_style );
        FinishCurrentManItem();
        return true;
    end;
    ScanInstallMethodPart := function( declare_position )
        local filter_string, name, pos;
        CurrentOrNewManItem();
        if not IsBound( CurrentItem()!.item_type ) then
            CurrentItem()!.item_type := "Meth";
        else
            CurrentItem()!.item_type := NormalizeItemType(
                CurrentItem()!.item_type
            );
        fi;
        pos := PositionSublist( current_line, "(" );
        current_line := current_line{ [ pos + 1 .. Length( current_line ) ] };
        name := "";
        pos := PositionSublist( current_line, "," );
        while pos = fail do
            Append( name, current_line );
            current_line := NormalizedReadLine( filestream );
            if current_line = fail then
                ErrorWithPos( "unterminated InstallMethod declaration header" );
            fi;
            pos := PositionSublist( current_line, "," );
        od;
        Append( name, current_line{[ 1 .. pos - 1 ]} );
        NormalizeWhitespace( name );
        name := StripBeginEnd( name, " " );
        name := ReplacedString( name, "\"", "" );
        CurrentItem()!.name := name;
        filter_string := ReadInstallMethodFilterString( );
        if CurrentItem()!.tester_names = fail then
            CurrentItem()!.tester_names := ReplacedString( filter_string, "\"", "" );
        fi;
        if not IsBound( CurrentItem()!.arguments ) then
            filter_string := ReadInstallMethodArguments( );
            if filter_string <> fail then
                CurrentItem()!.arguments := filter_string;
            fi;
        fi;
        if not IsBound( CurrentItem()!.arguments ) then
            CurrentItem()!.arguments := Length( SplitString( CurrentItem()!.tester_names, "," ) );
            CurrentItem()!.arguments := JoinStringsWithSeparator( List( [ 1 .. CurrentItem()!.arguments ], i -> Concatenation( "arg", String( i ) ) ), "," );
        fi;
        FinishCurrentManItem();
        return true;
    end;
    Reset := function( )
        chapter_info := [ ];
        context_stack := [ ];
        plain_text_mode := false;
        markdown_fence := fail;
        xml_comment_mode := false;
    end;
    ScanForDeclarationPart := function()
        local declare_position;

        ## fail is bigger than every integer
        declare_position := Minimum( [ PositionSublist( current_line, "Declare" ), PositionSublist( current_line, "KeyDependentOperation" ) ] );
        if declare_position <> fail then
            return ScanDeclarePart( declare_position );
        fi;
        declare_position := Minimum( [ PositionSublist( current_line, "InstallMethod" ), PositionSublist( current_line, "InstallOtherMethod" ) ] );
                            ## Fail is larger than every integer.
        if declare_position <> fail then
            return ScanInstallMethodPart( declare_position );
        fi;
        return false;
    end;
    ReadCode := function( )
        local code_node, temp_curr_line, temp_line_info, temp_command;
        code_node := DocumentationVerbatim(
            "Listing",
            rec( Type := "Code" ),
            [ ]
        );
        while true do
            temp_curr_line := ReadLineWithLineCount( filestream );
            temp_line_info := NormalizeInputLine( temp_curr_line );
            if temp_line_info.is_autodoc then
                temp_command := Scan_for_AutoDoc_Part( temp_line_info.text );
                if temp_command[ 1 ] = "@EndCode" then
                    break;
                fi;
                Add( code_node!.content, Chomp( temp_line_info.text ) );
                continue;
            fi;
            Add( code_node!.content, Chomp( temp_curr_line ) );
        od;
        return code_node;
    end;
    ReadExample := function( element_name )
        local temp_string_list, temp_curr_line, temp_pos_comment, is_following_line,
              item_temp, example_node, end_command;
        example_node := DocumentationExample( element_name );
        temp_string_list := example_node!.content;
        end_command := Concatenation( "@End", element_name );
        is_following_line := false;
        while true do
            temp_curr_line := Chomp( ReadLineWithLineCount( filestream ) );
            if PositionSublist( temp_curr_line, end_command ) <> fail then
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
    ReadSessionExample := function( element_name, plain_text_mode )
        local temp_string_list, temp_curr_line, temp_pos_comment,
              is_following_line, item_temp, example_node,
              incorporate_this_line, end_command;
        example_node := DocumentationExample( element_name );
        temp_string_list := example_node!.content;
        end_command := Concatenation( "@End", element_name, "Session" );
        while true do
            temp_curr_line := Chomp( ReadLineWithLineCount( filestream ) );
            if PositionSublist( temp_curr_line, end_command ) <> fail then
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
            SetCurrentItem( ChapterInTree( tree, scope_chapter ) );
            Unbind( chapter_info[ 2 ] );
            Unbind( chapter_info[ 3 ] );
            chapter_info[ 1 ] := scope_chapter;
        end,
        @Appendix := function()
            local scope_appendix;
            scope_appendix := ReplacedString( current_command[ 2 ], " ", "_" );
            SetCurrentItem( AppendixInTree( tree, scope_appendix ) );
            Unbind( chapter_info[ 2 ] );
            Unbind( chapter_info[ 3 ] );
            chapter_info[ 1 ] := scope_appendix;
        end,
        @ChapterLabel := function()
            local scope_chapter, label_name;
            if not IsBound( chapter_info[ 1 ] ) then
                ErrorWithPos( "found @ChapterLabel with no active chapter" );
            fi;
            label_name := AUTODOC_NormalizeGeneratedLabel( current_command[ 2 ] );
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
            SetCurrentItem( SectionInTree( tree, chapter_info[ 1 ], scope_section ) );
            Unbind( chapter_info[ 3 ] );
            chapter_info[ 2 ] := scope_section;
        end,
        @SectionLabel := function()
            local scope_section, label_name;
            if not IsBound( chapter_info[ 2 ] ) then
                ErrorWithPos( "found @SectionLabel with no active section" );
            fi;
            label_name := AUTODOC_NormalizeGeneratedLabel( current_command[ 2 ] );
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
            SetCurrentItem( SubsectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ], scope_subsection ) );
            chapter_info[ 3 ] := scope_subsection;
        end,
        @SubsectionLabel := function()
            local scope_subsection, label_name;
            if not IsBound( chapter_info[ 3 ] ) then
                ErrorWithPos( "found @SubsectionLabel with no active subsection" );
            fi;
            label_name := AUTODOC_NormalizeGeneratedLabel( current_command[ 2 ] );
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
            CurrentOrNewManItem();
            CurrentItem()!.content := CurrentItem()!.description;
            NormalizeWhitespace( current_command[ 2 ] );
            if current_command[ 2 ] <> "" then
                Add( CurrentItem(), current_command[ 2 ] );
            fi;
        end,
        @Returns := function()
            CurrentOrNewManItem();
            CurrentItem()!.content := CurrentItem()!.return_value;
            if IsBound( CurrentItem()!.item_type ) and CurrentItem()!.item_type = "Var" then
                CurrentItem()!.item_type := "Func";
                if not IsBound( CurrentItem()!.arguments ) or CurrentItem()!.arguments = fail then
                    CurrentItem()!.arguments := "arg";
                fi;
                CurrentItem()!.return_value := [ ];
            elif not IsBound( CurrentItem()!.item_type ) then
                CurrentItem()!.declaration_is_function := true;
            fi;
            if current_command[ 2 ] <> "" then
                Add( CurrentItem(), current_command[ 2 ] );
            fi;
        end,
        @Arguments := function()
            CurrentOrNewManItem();
            if IsBound( CurrentItem()!.item_type ) and CurrentItem()!.item_type = "Var" then
                CurrentItem()!.item_type := "Func";
            elif not IsBound( CurrentItem()!.item_type ) then
                CurrentItem()!.declaration_is_function := true;
            fi;
            CurrentItem()!.arguments := current_command[ 2 ];
        end,
        @ItemType := function()
            CurrentOrNewManItem();
            CurrentItem()!.item_type := NormalizeItemType( current_command[ 2 ] );
        end,
        @Label := function()
            CurrentOrNewManItem();
            CurrentItem()!.tester_names := current_command[ 2 ];
        end,
        @Group := function()
            local group_name;
            CurrentOrNewManItem();
            group_name := ReplacedString( current_command[ 2 ], " ", "_" );
            SetGroupName( CurrentItem(), group_name );
        end,
        @GroupTitle := function()
            local group_name, chap_info, group_obj;
            CurrentOrNewManItem();
            if not HasGroupName( CurrentItem() ) then
                ErrorWithPos( "found @GroupTitle with no Group set" );
            fi;
            group_name := GroupName( CurrentItem() );
            chap_info := fail;
            if HasChapterInfo( CurrentItem() ) then
                chap_info := ChapterInfo( CurrentItem() );
            elif IsBound( CurrentItem()!.chapter_info ) then
                chap_info := CurrentItem()!.chapter_info;
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
            CurrentOrNewManItem();
            current_chapter_info := SplitString( current_command[ 2 ], "," );
            current_chapter_info := List( current_chapter_info, i -> ReplacedString( StripBeginEnd( i, " " ), " ", "_" ) );
            SetChapterInfo( CurrentItem(), current_chapter_info );
        end,
        @BREAK := function()
            ErrorWithPos( current_command[ 2 ] );
        end,
        @Index := function()
            local argument, split_pos, key, entry, c,
                  escaped_quote_pos, key_string, key_escaped;
            if not HasCurrentItem() then
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
                    Append( key_escaped, key_string );
                    break;
                elif split_pos > 1 then
                    Append( key_escaped, key_string{ [ 1 .. split_pos - 1 ] } );
                    key_string := key_string{ [ split_pos .. Length( key_string ) ] };
                fi;
                c := Remove(key_string, 1);
                if c = '&' then
                    Append( key_escaped, "&amp;" );
                elif c = '"' then
                    Append( key_escaped, "&quot;" );
                elif c = '<' then
                    Append( key_escaped, "&lt;" );
                else # c = '>'
                    Append( key_escaped, "&gt;" );
                fi;
            od;

            if key_escaped = "" then
                ErrorWithPos( "found @Index with empty key" );
            fi;
            Add( CurrentItem(), Concatenation( "<Index Key=\"", key_escaped, "\">", entry, "</Index>" ) );
        end,

        @InsertChunk := function()
            local label_name;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            Add( CurrentItem(), DocumentationChunk( tree, label_name ) );
        end,
        @BeginChunk := function()
            local label_name;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            Add( context_stack, DocumentationChunk( tree, label_name ) );
            CurrentItem()!.is_defined := true;
        end,
        @Chunk := ~.@BeginChunk,
        @EndChunk := function()
            autodoc_read_line := false;
            Remove( context_stack );
        end,

        @BeginCode := function()
            local label_name, tmp_system;
            label_name := ReplacedString( current_command[ 2 ], " ", "_" );
            tmp_system := DocumentationChunk( tree, label_name );
            tmp_system!.is_defined := true;
            Add( tmp_system!.content, ReadCode() );
        end,
        @Code := ~.@BeginCode,
        @InsertCode := ~.@InsertChunk,

        @BeginExample := function()
            local example_node;
            example_node := ReadExample( "Example" );
            Add( CurrentItem(), example_node );
        end,

        @Example := ~.@BeginExample,
        @BeginLog := function()
            local example_node;
            example_node := ReadExample( "Log" );
            Add( CurrentItem(), example_node );
        end,
        @Log := ~.@BeginLog,

        STRING := function()
            if not HasCurrentItem() then
                return;
            fi;
            if active_title_item_name <> fail and
               active_title_item_is_multiline = false then
                return;
            fi;
            Add( CurrentItem(), current_command[ 2 ] );
        end,
        @BeginLatexOnly := function()
            local alt_node;
            alt_node := DocumentationVerbatim( "Alt", rec( Only := "LaTeX" ), [ ] );
            Add( CurrentItem(), alt_node );
            Add( context_stack, alt_node!.content );
            if current_command[ 2 ] <> "" then
                Add( CurrentItem(), current_command[ 2 ] );
            fi;
        end,
        @EndLatexOnly := function()
            autodoc_read_line := false;
            Remove( context_stack );
        end,
        @LatexOnly := function()
            Add( CurrentItem(),
                DocumentationVerbatim(
                    "Alt",
                    rec( Only := "LaTeX" ),
                    [ current_command[ 2 ] ]
                 ) );
        end,
        @BeginNotLatex := function()
            local alt_node;
            alt_node := DocumentationVerbatim( "Alt", rec( Not := "LaTeX" ), [ ] );
            Add( CurrentItem(), alt_node );
            Add( context_stack, alt_node!.content );
            if current_command[ 2 ] <> "" then
                Add( CurrentItem(), current_command[ 2 ] );
            fi;
        end,
        @EndNotLatex := function()
            autodoc_read_line := false;
            Remove( context_stack );
        end,
        @NotLatex := function()
            Add( CurrentItem(),
                DocumentationVerbatim(
                    "Alt",
                    rec( Not := "LaTeX" ),
                    [ current_command[ 2 ] ]
                 ) );
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
            example_node := ReadSessionExample( "Example", plain_text_mode );
            Add( CurrentItem(), example_node );
        end,
        @BeginExampleSession := ~.@ExampleSession,
        @LogSession := function()
            local example_node;
            example_node := ReadSessionExample( "Log", plain_text_mode );
            Add( CurrentItem(), example_node );
        end,
        @BeginLogSession := ~.@LogSession
    );
    
    ## The following commands are specific for worksheets. They do not have a packageinfo,
    ## and no place to extract those infos. So these commands are needed to make insert the
    ## information directly into the document.
    title_item_list := [ "Title", "Subtitle", "Version", "TitleComment", "Author",
                         "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ];
    single_line_title_item_list := [ "Title", "Subtitle", "Version", "Author", "Date" ];

    CreateTitleItemFunction := function( name )
        return function()
            if not IsBound( tree!.TitlePage.( name ) ) then
                tree!.TitlePage.( name ) := [ ];
            fi;
            SetCurrentItem( tree!.TitlePage.( name ) );
            active_title_item_name := name;
            active_title_item_is_multiline :=
                Position( single_line_title_item_list, name ) = fail;
            Add( CurrentItem(), current_command[ 2 ] );
        end;
    end;
    
    ## Note that we need to create these functions in the helper function
    ## CreateTitleItemFunction to ensure that the <name> variable is bound properly.
    ## Without this intermediate helper, the wrong closure is taken,
    ## and later, when the function is executed, the value for <name> will be the last
    ## value <title_item> had, i.e., the last entry of <title_item_list>.
    for title_item in title_item_list do
        command_function_record.( Concatenation( "@", title_item ) ) := CreateTitleItemFunction( title_item );
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
                current_line_fence := MarkdownFenceFromLine( current_line_info.text );
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
                        IsMatchingMarkdownFence( markdown_fence, current_line_fence );
                fi;
            fi;
            if current_line_is_fence_delimiter then
                current_command := [ "STRING", current_line_info.text ];
            elif markdown_fence <> fail and current_command[ 1 ] <> false then
                current_command := [ "STRING", current_line_info.text ];
            fi;
            if current_command[ 1 ] <> false then
                autodoc_read_line := current_line_info.allows_declaration_scan;
                if Position( title_item_list, current_command[ 1 ]{ [ 2 .. Length( current_command[ 1 ] ) ] } ) = fail and
                   current_command[ 1 ] <> "STRING" then
                    active_title_item_name := fail;
                    active_title_item_is_multiline := false;
                fi;
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
            if autodoc_read_line then
                autodoc_read_line := false;
                ScanForDeclarationPart( );
            fi;
        od;
        CloseStream( filestream );
    od;
end );
