

##
InstallGlobalFunction( AutoDoc_WriteEntry,
                       
  function( doc_stream, label, type, arguments, name, tester_names, return_value, description, label_for_mansection )
    local i;
    
    AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label , "\">\n" );
    AppendTo( doc_stream, "##  <ManSection" );
    Perform( label_for_mansection, function( i ) AppendTo( doc_stream, " Label=\"", i, "\"" ); end );
    AppendTo( doc_stream, ">\n" );
    AppendTo( doc_stream, "##    <", type, " Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\"/>\n" );
    AppendTo( doc_stream, "##    <Returns>", return_value, "</Returns>\n" );
    AppendTo( doc_stream, "##    <Description>\n" );
    
    for i in description do
        
        AppendTo( doc_stream, Concatenation( [ "##      ", i, "\n" ] ) );
        
    od;
    
    AppendTo( doc_stream, "##    </Description>\n" );
    AppendTo( doc_stream, "##  </ManSection>\n" );
    AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
    AppendTo( doc_stream, "##\n\n" );
    
end );

##
InstallGlobalFunction( AutoDoc_WriteGroupedEntry,
                       
  function( doc_stream, label, list_of_type_arg_name_testernames, return_value, description, label_list )
    local i;
    
    AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label , "\">\n" );
    AppendTo( doc_stream, "##  <ManSection" );
    Perform( label_list, function( i ) AppendTo( doc_stream, " Label=\"", i, "\"" ); end );
    AppendTo( doc_stream, ">\n" );
    
    for i in list_of_type_arg_name_testernames do
        
        AppendTo( doc_stream, "##    <", i[ 1 ], " Arg=\"", i[ 2 ], "\" Name=\"", i[ 3 ], "\" Label=\"for ", i[ 4 ], "\"/>\n" );
        
    od;
    
    AppendTo( doc_stream, "##    <Returns>", return_value, "</Returns>\n" );
    AppendTo( doc_stream, "##    <Description>\n" );
    
    for i in description do
        
        AppendTo( doc_stream, Concatenation( [ "##      ", i, "\n" ] ) );
        
    od;
    
    AppendTo( doc_stream, "##    </Description>\n" );
    AppendTo( doc_stream, "##  </ManSection>\n" );
    AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
    AppendTo( doc_stream, "##\n\n" );
    
end );