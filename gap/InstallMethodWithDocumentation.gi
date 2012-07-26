#############################################################################
##
##  InstallHomalgMethod.gi                            ToolsForHomalg package
##
##  Copyright 2007-2012, Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, RWTH-Aachen University
##                  Markus Lange-Hegermann, RWTH-Aachen University
##
##  A new way to create Methods.
##
#############################################################################

##
InstallValue( HOMALG_DOCUMENTATION,
              rec(
                enable_documentation := false,
                documentation_stream := false,
                documentation_headers := false,
                random_value := 10^10
              )
              
);

##
## Gets three strings. Initialises everything.
InstallGlobalFunction( CreateAutomaticDocumentation,

  function( package_name, name_documentation_file, name_xml_file )
    local dependencies;
    
    ## First of all, make shure $package_name is the only package to be loaded:
    dependencies := PackageInfo( package_name )[ 1 ].Dependencies;
    
    List( dependencies.NeededOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    
    List( dependencies.SuggestedOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    ## Now loading $package_name only loads ONE package.
    
    ## Initialising the filestreams.
    HOMALG_DOCUMENTATION.enable_documentation := true;
    
    HOMALG_DOCUMENTATION.documentation_stream := OutputTextFile( name_documentation_file, false );
    
    HOMALG_DOCUMENTATION.documentation_headers := OutputTextFile( name_xml_file, false );
    
    ## Creating a header for the xml file.
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<Chapter Label=\"", package_name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<Heading>", package_name, " automatic documentation part</Heading>\n" ] ) );
    
    ## Seems that we need a section :/
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<Section Label=\"", package_name, "_automatically_generated_documentated_functions\">\n" ] ) );
    
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<Heading>", package_name, " automatic documentated declarations and functions</Heading>\n" ] ) );
    
    ## Magic!
    LoadPackage( package_name );
    
    ## Close header file and streams
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, "</Section>" );
    
    AppendTo( HOMALG_DOCUMENTATION.documentation_headers, "</Chapter>" );
    
    CloseStream( HOMALG_DOCUMENTATION.documentation_stream );
    
    CloseStream( HOMALG_DOCUMENTATION.documentation_headers );
    
    return true;

end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( HomalgDeclareCategory,

  function( arg )
    local name, tester, description, arguments,
          tester_names, i, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 then
        
        Error( "the method HomalgDeclareCategory must be called with 3 or 4 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    description := arg[ 3 ];
    
    if Length( arg ) = 5 then
        
        arguments := arg[ 5 ];
        
    else
        
        arguments := "arg";
        
    fi;
    
    if HOMALG_DOCUMENTATION.enable_documentation then
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        i := 2;
        
        while i <= Length( tester_names ) do
            
            Remove( tester_names, i );
            
            i := i + 2;
            
        od;
        
        tester_names := JoinStringsWithSeparator( tester_names, " and " );
        
        label_rand_hash := Concatenation( [ name, String( Random( 0, HOMALG_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := HOMALG_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Filt Type=\"Category\" Arg=\"", arguments, "\" Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, "##    <Returns><C>true</C> or <C>false</C></Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      Filters for arguments are: ", tester_names, "<Br/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareCategory( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( HomalgDeclareOperation,

  function( arg )
    local name, tester, description, return_value, arguments,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method HomalgDeclareOperation must be called with 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    description := arg[ 3 ];
    
    return_value := arg[ 4 ];
    
    if Length( arg ) = 5 then
        
        if IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
            
            arguments := JoinStringsWithSeparator( arg[ 5 ] );
            
        elif IsString( arg[ 5 ] ) then
            
            arguments := arg[ 5 ];
            
        fi;
        
    else
        
        arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
        
        arguments := JoinStringsWithSeparator( arguments );
        
    fi;
    
    if HOMALG_DOCUMENTATION.enable_documentation then
        
        tester_names := List( tester, i -> ShallowCopy( NamesFilter( i ) ) );
        
        for j in [ 1 .. Length( tester_names ) ] do
            
            for i in [ 1 .. Length( tester_names[ j ] ) ] do
                
                if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                    
                    Remove( tester_names[ j ], i );
                    
                fi;
                
            od;
            
            tester_names[ j ] := JoinStringsWithSeparator( tester_names[ j ], " and " );
            
        od;
        
        tester_names := JoinStringsWithSeparator( tester_names, ", " );
        
        label_rand_hash := Concatenation( [ name, String( Random( 0, HOMALG_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := HOMALG_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Oper Arg=\"", arguments, "\" Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      Filters for arguments are: ", tester_names, "<Br/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareOperation( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( HomalgDeclareAttribute,

  function( arg )
    local name, tester, description, return_value, arguments,
          tester_names, i, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method HomalgDeclareAttribute must be called with 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    description := arg[ 3 ];
    
    return_value := arg[ 4 ];
    
    if Length( arg ) = 5 then
        
        arguments := arg[ 5 ];
        
    else
        
        arguments := "arg";
        
    fi;
    
    if HOMALG_DOCUMENTATION.enable_documentation then
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        i := 2;
        
        while i <= Length( tester_names ) do
            
            Remove( tester_names, i );
            
            i := i + 2;
            
        od;
        
        tester_names := JoinStringsWithSeparator( tester_names, " and " );
        
        label_rand_hash := Concatenation( [ name, String( Random( 0, HOMALG_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := HOMALG_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Attr Arg=\"", arguments, "\" Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      Filters for arguments are: ", tester_names, "<Br/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareAttribute( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( HomalgDeclareProperty,

  function( arg )
    local name, tester, description, arguments,
          tester_names, i, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 then
        
        Error( "the method HomalgDeclareProperty must be called with 3 or 4 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    description := arg[ 3 ];
    
    if Length( arg ) = 4 then
        
        arguments := arg[ 4 ];
        
    else
        
        arguments := "arg";
        
    fi;
    
    if HOMALG_DOCUMENTATION.enable_documentation then
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        i := 2;
        
        while i <= Length( tester_names ) do
            
            Remove( tester_names, i );
            
            i := i + 2;
            
        od;
        
        tester_names := JoinStringsWithSeparator( tester_names, " and " );
        
        label_rand_hash := Concatenation( [ name, String( Random( 0, HOMALG_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := HOMALG_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Prop Arg=\"", arguments, "\" Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, "##    <Returns><C>true</C> or <C>false</C></Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      Filters for arguments are: ", tester_names, "<Br/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        AppendTo( HOMALG_DOCUMENTATION.documentation_headers, Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareProperty( name, tester );
    
    return true;
    
end );