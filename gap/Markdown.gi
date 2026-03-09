# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

##
BindGlobal( "INSERT_IN_STRING_WITH_REPLACE",
  function( string, new_string, position, nr_letters_to_be_replaced )
    return Concatenation(
               string{[ 1 .. position - 1 ]},
               new_string,
               string{[ position + nr_letters_to_be_replaced .. Length( string ) ]}
           );
end );

##
BindGlobal( "AUTODOC_EscapeXMLTextForInlineCode",
  function( string )
    local escaped_string, split_pos;

    escaped_string := "";
    while Length(string) > 0 do
        split_pos := PositionProperty( string, c -> c in "&\"<>" );
        if split_pos = fail then
            Append( escaped_string, string );
            break;
        fi;
        if split_pos > 1 then
            Append( escaped_string, string{ [ 1 .. split_pos - 1 ] } );
        fi;
        if string[ split_pos ] = '&' then
            Append( escaped_string, "&amp;" );
        elif string[ split_pos ] = '"' then
            Append( escaped_string, "&quot;" );
        elif string[ split_pos ] = '<' then
            Append( escaped_string, "&lt;" );
        else
            Append( escaped_string, "&gt;" );
        fi;
        string := string{ [ split_pos + 1 .. Length( string ) ] };
    od;

    return escaped_string;
end );

##
BindGlobal( "AUTODOC_ConvertInlineBackticksInLine",
  function( string, keyword_set )
    local opening_pos, closing_pos, inline_content, tag_name, search_string;

    while PositionSublist( string, "`" ) <> fail do
        opening_pos := PositionSublist( string, "`" );
        search_string := string{ [ opening_pos + 1 .. Length( string ) ] };
        closing_pos := PositionSublist( search_string, "`" );
        if closing_pos = fail then
            Error( "did you forget some `" );
        fi;
        closing_pos := opening_pos + closing_pos;

        if opening_pos + 1 <= closing_pos - 1 then
            inline_content := string{ [ opening_pos + 1 .. closing_pos - 1 ] };
        else
            inline_content := "";
        fi;
        if inline_content in keyword_set then
            tag_name := "Keyword";
        else
            tag_name := "Code";
        fi;
        string := Concatenation(
            string{ [ 1 .. opening_pos - 1 ] },
            "<", tag_name, ">",
            AUTODOC_EscapeXMLTextForInlineCode( inline_content ),
            "</", tag_name, ">",
            string{ [ closing_pos + 1 .. Length( string ) ] }
        );
    od;

    return string;
end );

##
BindGlobal( "AUTODOC_FencedMarkdownElement",
  function( info_string )
    if info_string = "@example" then
        return "Example";
    elif info_string = "@log" then
        return "Log";
    fi;
    return "Listing";
end );

##
BindGlobal( "AUTODOC_ConvertFencedMarkdownBlocks",
  function( string_list )
    local i, converted_string_list, skipped, trimmed_line,
          fence_char, fence_length, info_string, fence_element, code_block,
          fence_content;

    converted_string_list := [ ];
    i := 1;
    skipped := false;
    while i <= Length( string_list ) do
        if AUTODOC_LineStartsCDATA( string_list[ i ] ) then
            skipped := true;
        fi;
        if skipped = true then
            Add( converted_string_list, string_list[ i ] );
            if AUTODOC_LineEndsCDATA( string_list[ i ] ) then
                skipped := false;
            fi;
            i := i + 1;
            continue;
        fi;
        trimmed_line := StripBeginEnd( string_list[ i ], " \t\r\n" );
        if Length( trimmed_line ) >= 3 and
           ( ForAll( trimmed_line{ [ 1 .. 3 ] }, c -> c = '`' ) or
             ForAll( trimmed_line{ [ 1 .. 3 ] }, c -> c = '~' ) ) then
            fence_char := trimmed_line[ 1 ];
            fence_length := 1;
            while fence_length < Length( trimmed_line ) and
                  trimmed_line[ fence_length + 1 ] = fence_char do
                fence_length := fence_length + 1;
            od;
            if fence_length >= 3 then
                info_string := NormalizedWhitespace(
                    trimmed_line{ [ fence_length + 1 .. Length( trimmed_line ) ] }
                );
                fence_element := AUTODOC_FencedMarkdownElement( info_string );
                i := i + 1;
                code_block := false;
                fence_content := [ ];
                while i <= Length( string_list ) do
                    trimmed_line := StripBeginEnd( string_list[ i ], " \t\r\n" );
                    if Length( trimmed_line ) >= fence_length and
                       ForAll( trimmed_line{ [ 1 .. fence_length ] }, c -> c = fence_char ) and
                       ForAll( trimmed_line{ [ fence_length + 1 .. Length( trimmed_line ) ] },
                               c -> c in " \t\r\n" ) then
                        code_block := true;
                        break;
                    fi;
                    Add( fence_content, Chomp( string_list[ i ] ) );
                    i := i + 1;
                od;
                Add( converted_string_list,
                     DocumentationVerbatim( fence_element, rec( ), fence_content ) );
                if code_block = true then
                    i := i + 1;
                    continue;
                fi;
                break;
            fi;
        fi;
        Add( converted_string_list, string_list[ i ] );
        i := i + 1;
    od;

    return converted_string_list;
end );

##
BindGlobal( "AUTODOC_ForEachNonCDATALine",
  function( string_list, action )
    local i, in_cdata;

    in_cdata := false;
    for i in [ 1 .. Length( string_list ) ] do
        if AUTODOC_LineStartsCDATA( string_list[ i ] ) then
            in_cdata := true;
        fi;
        if in_cdata = false then
            action( i );
        fi;
        if AUTODOC_LineEndsCDATA( string_list[ i ] ) then
            in_cdata := false;
        fi;
    od;
end );

##
BindGlobal( "AUTODOC_ConvertMarkdownStringsToGAPDocXML",
  function( string_list )
    local i, current_list, current_string, max_line_length,
          current_position, already_in_list, command_list_with_translation, beginning,
          commands, position_of_command, insert, beginning_whitespaces, temp, string_list_temp, skipped,
          already_inserted_paragraph, in_list, in_item, converted_string_list,
          keyword_set;

    # Convert inline backticks before list detection so literal tags such as
    # `<List>` inside code spans do not look like structural GAPDoc tags.
    keyword_set := Set( ALL_KEYWORDS() );
    AUTODOC_ForEachNonCDATALine( string_list, function( i )
        string_list[ i ] :=
            AUTODOC_ConvertInlineBackticksInLine( string_list[ i ], keyword_set );
    end );

    ## Check for paragraphs by turning an empty string into <P/>
    
    already_inserted_paragraph := false;
    AUTODOC_ForEachNonCDATALine( string_list, function( i )
        if NormalizedWhitespace( string_list[ i ] ) = "" then
            if already_inserted_paragraph = false then
                string_list[ i ] := "<P/>";
                already_inserted_paragraph := true;
            fi;
        else
            already_inserted_paragraph := false;
        fi;
    end );

    ## We need to find lists. Lists are indicated by a beginning
    ## *, -, or +. Lists can be nested. Save list as list of strings,
    ## and at the same time, concatenate all the other strings
    ## FIXME: @Max: where are my regular expressions?
    ## Do this in several iterations
    max_line_length := Maximum( List( string_list, Length ) );
    current_position := 1;
    while current_position < max_line_length do
        already_in_list := false;
        i := 1;
        skipped := false;

        ## maybe make the first line marked by definition?
        while i <= Length( string_list ) do
            if AUTODOC_LineStartsCDATA( string_list[ i ] ) then
                skipped := true;
            fi;
            if AUTODOC_LineEndsCDATA( string_list[ i ] ) then
                skipped := false;
                i := i + 1;
                continue;
            fi;
            if skipped = true then
                i := i + 1;
                continue;
            fi;
            if PositionSublist( string_list[ i ], "* " ) = current_position
            or PositionSublist( string_list[ i ], "+ " ) = current_position
            or PositionSublist( string_list[ i ], "- " ) = current_position then
                if not ForAll( [ 1 .. current_position - 1 ], j -> string_list[ i ][ j ] = ' ' ) then
                    i := i + 1;
                    continue;
                fi;
                if already_in_list = false then
                    Add( string_list, "<Item>", i );
                    Add( string_list, "<List>", i );
                    i := i + 2;
                    string_list[ i ] := string_list[ i ]{[ current_position + 2 .. Length( string_list[ i ] ) ]};
                    already_in_list := true;
                else
                    Add( string_list, "<Item>", i );
                    Add( string_list, "</Item>", i );
                    i := i + 2;
                    string_list[ i ] := string_list[ i ]{[ current_position + 2 .. Length( string_list[ i ] ) ]};
                fi;
                ## find out if line has to be marked
                ## THIS is buggy. Discuss this
                ## FIXME: This causes strange problems with GAPDoc.
#                 if PositionSublist( string_list[ i ], "**" ) = 1 then
#                     string_list[ i ] := string_list[ i ]{[ 3 .. Length( string_list[ i ] ) ]};
#                     temp := string_list[ i ];
#                     string_list[ i ] := string_list[ i - 1 ];
#                     string_list[ i - 1 ] := temp;
#                     Add( string_list, "<Mark>", i - 1 );
#                     Add( string_list, "</Mark>", i + 1 );
#                     i := i + 2;
#                 fi;
            elif already_in_list = true and PositionSublist( string_list[ i ], "  " ) > current_position then
                already_in_list := false;
                Add( string_list, "</List>", i );
                Add( string_list, "</Item>", i );
                i := i + 2;
            fi;
            i := i + 1;
        od;
        if already_in_list = true then
            Add( string_list, "</Item>" );
            Add( string_list, "</List>" );
        fi;
        current_position := current_position + 1;
    od;
    
    # Remove <P/> if in List but not in item
    in_list := 0;
    in_item := 0;
    for current_position in [ 1 .. Length( string_list ) ] do
        if PositionSublist( string_list[ current_position ], "<List>" ) <> fail then
            in_list := in_list + 1;
        fi;
        
        if PositionSublist( string_list[ current_position ], "</List>" ) <> fail  then
            in_list := in_list - 1;
        fi;
        
        if PositionSublist( string_list[ current_position ], "<Item>" ) <> fail then
            in_item := in_item + 1;
        fi;
        
        if PositionSublist( string_list[ current_position ], "</Item>" ) <> fail then
            in_item := in_item - 1;
        fi;
        
        if in_item < in_list and string_list[ current_position ] = "<P/>" then
            string_list[ current_position ] := "";
        fi;
    od;

    ## Find commands
    command_list_with_translation := [ [ "$$", "Display" ],
                                       [ "$", "Math" ],
                                       [ "**", "Emph" ],
                                       [ "__", "Emph" ] ];

    ## special handling for \$
    for i in [ 1 .. Length( string_list ) ] do
        string_list[ i ] := ReplacedString( string_list[ i ], "\\$", "&#36;" );
    od;

    for commands in command_list_with_translation do
        beginning := true;
        AUTODOC_ForEachNonCDATALine( string_list, function( i )
            while PositionSublist( string_list[ i ], commands[ 1 ] ) <> fail do
                position_of_command := PositionSublist( string_list[ i ], commands[ 1 ] );
                if beginning = true then
                    insert := Concatenation( "<", commands[ 2 ], ">" );
                else
                    insert := Concatenation( "</", commands[ 2 ], ">" );
                fi;
                string_list[ i ] := INSERT_IN_STRING_WITH_REPLACE( string_list[ i ], insert, position_of_command, Length( commands[ 1 ] ) );
                beginning := not beginning;
            od;
        end );

        if beginning = false then
            Error( "did you forget some ", commands[ 1 ] );
        fi;
    od;

    return string_list;
end );

##
InstallGlobalFunction( AUTODOC_ConvertMarkdownToGAPDocXML,
  function( string_list )
    local converted_items, current_string_list, item, FlushStringList;

    converted_items := [ ];
    current_string_list := [ ];

    FlushStringList := function()
        if current_string_list = [ ] then
            return;
        fi;
        Append( converted_items,
                AUTODOC_ConvertMarkdownStringsToGAPDocXML( current_string_list ) );
        current_string_list := [ ];
    end;

    for item in AUTODOC_ConvertFencedMarkdownBlocks( string_list ) do
        if IsString( item ) then
            Add( current_string_list, item );
        else
            FlushStringList();
            Add( converted_items, item );
        fi;
    od;
    FlushStringList();

    return converted_items;
end );
