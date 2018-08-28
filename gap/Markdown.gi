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
InstallGlobalFunction( INSERT_IN_STRING_WITH_REPLACE,
  function( string, new_string, position, nr_letters_to_be_replaced )
    return Concatenation(
               string{[ 1 .. position - 1 ]},
               new_string,
               string{[ position + nr_letters_to_be_replaced .. Length( string ) ]}
           );
end );

##
InstallGlobalFunction( CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML,
  function( string_list )
    local i, current_list, current_string, max_line_length,
          current_position, already_in_list, command_list_with_translation, beginning,
          commands, position_of_command, insert, beginning_whitespaces, temp, string_list_temp, skipped,
          already_inserted_paragraph, in_list, in_item, masked_string;

    #! @Chapter Comments
    #! @Section MarkdownExtension
    #! @BeginChunk markdown_conventions
    #! @Subsection Paragraph breaks
    #! @Index Paragraph Paragraph breaks in Markdown style
    #!    An empty line between blocks of &AutoDoc; text (that is to say, text
    #!    processed by &AutoDoc; that is being inserted into the current
    #!    chapter, section, description, etc.) is converted into a paragraph
    #!    break.
    #! @BeginLogSession
    #!#! @Chapter Intro
    #!#! This first paragraph gives you an overall feel of the operation of
    #!#! this package. It does so with vague generalities.
    #!#!
    #!#! However, this text plunges into the depths of a new paragraph because
    #!#! of the blank line separating it from what precedes it.
    #! @EndLogSession

    already_inserted_paragraph := false;
    for i in [ 1 ..  Length( string_list ) ] do
        if NormalizedWhitespace( string_list[ i ] ) = "" then
            if already_inserted_paragraph = false then
                string_list[ i ] := "<P/>";
                already_inserted_paragraph := true;
            fi;
        else
            already_inserted_paragraph := false;
        fi;
        i := i + 1;
    od;

    #! @Subsection MarkdownExtensionList
    #! @SubsectionTitle Lists
    #! @Index Lists Lists in Markdown style
    #!      One can create lists of items by beginning a new line with *, +,
    #!      -, followed by one space. The first item starts the list. When
    #!      items are longer than one line, the following lines
    #!      have to be indented by at least two spaces. The list ends when a
    #!      line which does not start a new item is not indented by two
    #!      spaces. Of course lists can be nested. Here is an example:
    #! @BeginLogSession
    #!#! The list starts in the next line
    #!#! * item 1
    #!#! * item 2
    #!#!   which is a bit longer
    #!#!   * and also contains a nested list
    #!#!   * with two items
    #!#! * item 3 of the outer list
    #!#! This does not belong to the list anymore.
    #! @EndLogSession
    #!    This is the output:<Br/>
    #!The list starts in the next line
    #!<List>
    #!<Item>
    #!  item 1
    #!</Item>
    #!<Item>
    #!  item 2
    #!  which is a bit longer
    #!    <List>
    #!      <Item>
    #!        and also contains a nested list
    #!      </Item>
    #!      <Item>
    #!        with two items
    #!      </Item>
    #!    </List>
    #!</Item>
    #!<Item>
    #!  item 3 of the outer list
    #!</Item>
    #!</List>
    #!This does not belong to the list anymore.<Br/>
    #!    The *, -, and + are fully interchangeable and can even be used
    #!     mixed, but this is not recommended.
    #!
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
            if PositionSublist( string_list[ i ], "<![CDATA[" ) <> fail then
                skipped := true;
            fi;
            if PositionSublist( string_list[ i ], "]]>" ) <> fail then
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
    command_list_with_translation := [
    #! @Subsection MarkdownExtensionMath
    #! @SubsectionTitle Math Modes
    #! @Index Math Math in Markdown Style
    #!    One can start an inline formula with a \$, and also end it with \$,
    #!    just like in &LaTeX;. This will translate into
    #!    &GAPDoc;s inline math environment. For display mode one can use \$\$,
    #!    also like &LaTeX;. If you need to produce a single \$ in your
    #!    documentation, you can escape it with a backslash, i.e. `\\$`
    #!    produces a \$.
    #! @BeginLogSession
    #!#! This is an inline formula: $1+1 = 2$.
    #1#! This is a display formula:
    #!#! $$ \sum_{i=1}^n i. $$
    #!#! You can have this package for \$0.
    #! @EndLogSession
    #!     produces the following output:<Br/>
    #! This is an inline formula: <Math>1+1 = 2</Math>.
    #! This is a display formula:
    #! <Display> \sum_{i=1}^n i. </Display>
    #! You can have this package for \$0.
                                       [ "$$", "Display" ],
                                       [ "$", "Math" ],
    #! @Subsection MarkdownExtensionEmph
    #! @SubsectionTitle Emphasize
    #! @Index Emphasize Emphasizing text in Markdown style
    #!    One can emphasize text by using two asterisks (`**`) or two
    #!    underscores (`__`) at the beginning and the end of the text which
    #!    should be emphasized. Example:
    #! @BeginLogSession
    #!#! **This** is very important.
    #!#! This is __also important__.
    #!#! **Naturally, more than one line
    #!#! can be important.**
    #! @EndLogSession
    #!    This produces the following output:<Br/>
    #!<E>This</E> is very important.
    #!This is <E>also important</E>.
    #!<E>Naturally, more than one line
    #!can be important.</E>
                                       [ "**", "Emph" ],
                                       [ "__", "Emph" ],
    #! @Subsection MarkdownExtensionCode
    #! @SubsectionTitle Code
    #! @Index Code Code quotations in Markdown Style
    #!    One can include arbitrary characters in a font suggestive of source
    #!    code by preceding and following the code snippet with a single
    #!    backtick character (\`). Any special meaning to &AutoDoc;
    #!    of the characters inside the backticked string is suppressed;
    #!    it may include &AutoDoc; commands, but they will not be executed. Note
    #!    however that currently, the matching beginning and ending backicks
    #!    must occur on the same source line. If you need to produce a
    #!    backtick character in your documentation, you can escape it with a
    #!    backslash, i.e. `\\`` produces a single backtick.
    ######### Make sure to leave this one last, as it masks the others
                                       [ "`", "C" ]
                                     ];
    #! @EndSubsection
    #! @EndChunk
    ## special handling for \$ and \`
    for i in [ 1 .. Length( string_list ) ] do
        string_list[ i ] := ReplacedString( string_list[ i ], "\\$", "&#36;" );
        string_list[ i ] := ReplacedString( string_list[ i ], "\\`", "&#96;" );
    od;

    for commands in command_list_with_translation do
        beginning := true;
        skipped := false;
        for i in [ 1 .. Length( string_list ) ] do
            if PositionSublist( string_list[ i ], "<![CDATA[" ) <> fail then
                skipped := true;
            fi;
            if PositionSublist( string_list[ i ], "]]>" ) <> fail then
                skipped := false;
            fi;
            if skipped = true then
                continue;
            fi;

            masked_string := AutoDoc_Mask_Line( string_list[ i ] );
            while PositionSublist( masked_string, commands[ 1 ] ) <> fail do
                position_of_command := PositionSublist( masked_string, commands[ 1 ] );
                if beginning = true then
                    insert := Concatenation( "<", commands[ 2 ], ">" );
                else
                    insert := Concatenation( "</", commands[ 2 ], ">" );
                fi;
                string_list[ i ] := INSERT_IN_STRING_WITH_REPLACE( string_list[ i ], insert, position_of_command, Length( commands[ 1 ] ) );
                masked_string := AutoDoc_Mask_Line( string_list[ i ] );
                beginning := not beginning;
            od;
        od;

        if beginning = false then
            Error( "did you forget some ", commands[ 1 ] );
        fi;
    od;

    return string_list;
end );
