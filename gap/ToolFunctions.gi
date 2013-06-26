

##
InstallGlobalFunction( AutoDoc_WriteEntry,
                       
  function( doc_stream, label, type, arguments, name, tester_names, return_value, description )
    local i;
    
    AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label , "\">\n" );
    AppendTo( doc_stream, "##  <ManSection>\n" );
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