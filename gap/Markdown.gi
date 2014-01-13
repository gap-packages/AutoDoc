#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2014, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

BindGlobal( "READ_LINEWISE",
            
  function( filename )
    local input_stream, list, i;
    
    input_stream := InputTextFile( filename );
    
    list := [ ];
    
    i := ReadLine( input_stream );
    
    while i <> fail do
        
        Add( list, i );
        
        i := ReadLine( input_stream );
        
    od;
    
    return list;
    
end );

##
BindGlobal( "CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML",
                       
  function( string_list )
    local i, current_list, current_string, max_line_length,
          current_position, already_in_list, white_spaces;
    
    ## Check for paragraphs by making an empty string into <br/>
    
    for i in [ 1 .. Length( string_list ) ] do
        
        if string_list[ i ] = "" then
            
            string_list[ i ] := "<Br>";
            
        fi;
        
    od;
    
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
        
#         white_spaces := JoinStringsWithSeparator( ListWithIdenticalEntries( current_position + 1, " " ) ), "" );
        
        while i <= Length( string_list ) do
            
            if PositionSublist( string_list[ i ], "* " ) = current_position
            or PositionSublist( string_list[ i ], "+ " ) = current_position
            or PositionSublist( string_list[ i ], "- " ) = current_position then
                
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
        
        current_position := current_position + 2;
        
#         Error( "" );
        
    od;
    
    return string_list;
    
end );

list := READ_LINEWISE( "markdown_syntax_test" );

list := CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML( list );

Print( Concatenation( list ) );
