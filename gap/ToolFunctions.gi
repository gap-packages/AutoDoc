#############################################################################
##
##  ToolFunctions.gi                      AutoDoc package
##
##  Copyright 2007-2013,   Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, University of Kaiserslautern
##
##  Some tools
##
#############################################################################

InstallGlobalFunction( "AUTODOC_OutputTextFile",
                       
function( arg )
    local filename, filestream;
    if Length( arg ) = 1 then
        filename := arg[1];
    else
        filename := Filename( arg[1], arg[2] );
    fi;
    
    filestream := OutputTextFile( filename, false );
    SetPrintFormattingStatus( filestream, false );
    
    return filestream;
    
end );

##
InstallGlobalFunction( AutoDoc_WriteDocEntry,
                       
  function( filestream, list_of_records )
    local return_value, description, current_description, labels, i;
    
    ##look for a good return value (it should be the same everywhere)
    for i in list_of_records do
        
        if IsBound( i!.return_value ) then
            
            if IsList( i!.return_value ) and Length( i!.return_value ) > 0 then
                
                return_value := i!.return_value;
                
                break;
                
            elif IsBool( i!.return_value ) then
                
                return_value := i!.return_value;
                
                break;
                
            fi;
            
        fi;
        
    od;
    
    ## Default.
    if not IsBound( return_value ) then
        
        return_value := "";
        
    fi;
    
    if IsList( return_value ) and ( not IsString( return_value ) ) and return_value <> "" then
        
        return_value := JoinStringsWithSeparator( return_value, " " );
        
    fi;
    
    description := [ ];
    
    ##collect description (for readability not in the loop above)
    for i in list_of_records do
        
        current_description := i!.description;
        
        if IsString( current_description ) then
            
            current_description := [ current_description ];
            
        fi;
        
        description := Concatenation( description, current_description );
        
    od;
    
    labels := [ ];
    
    for i in list_of_records do
        
        if HasGroupName( i ) then
            
            Add( labels, GroupName( i ) );
            
        fi;
        
    od;
    
    if Length( labels ) > 1 then
        
        labels :=  [ labels[ 1 ] ];
        
    fi;
    
    ## Write stuff out
    
    ##First labels, this has no effect in the current GAPDoc, btw.
    AppendTo( filestream, "<ManSection" );
    Perform( labels, function( i ) AppendTo( filestream, " Label=\"", i, "\"" ); end );
    AppendTo( filestream, ">\n" );
    
    ## Function heades
    for i in list_of_records do
        
         AppendTo( filestream, "  <", i!.item_type, " " );
        
        if i!.arguments <> fail and i!.item_type <> "Var" then
            AppendTo( filestream, "Arg=\"", i!.arguments, "\" " );
        fi;
        
        AppendTo( filestream, "Name=\"", i!.name, "\" " );
        
        if i!.tester_names <> fail and i!.tester_names <> "" then
            AppendTo( filestream, "Label=\"", i!.tester_names, "\"" );
        fi;
        
        AppendTo( filestream, "/>\n" );
        
    od;
    
    if return_value <> false then
        
        if IsString( return_value ) then
            
            return_value := [ return_value ];
            
        fi;
        
        AppendTo( filestream, " <Returns>" );
        
        WriteDocumentation( return_value, filestream );
        
        AppendTo( filestream, "</Returns>\n" );
        
    fi;
    
    AppendTo( filestream, " <Description>\n" );
    
    WriteDocumentation( description, filestream );
    
    AppendTo( filestream, " </Description>\n" );
    AppendTo( filestream, "</ManSection>\n\n" );
    
end );
