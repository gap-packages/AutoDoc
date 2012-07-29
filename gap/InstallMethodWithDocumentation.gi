#############################################################################
##
##  InstallMethodWithDocumentation.gi         AutomaticDocumentation package
##
##  Copyright 2007-2012, Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, RWTH-Aachen University
##                  Markus Lange-Hegermann, RWTH-Aachen University
##
##  A new way to create Methods.
##
#############################################################################

##
InstallValue( AUTOMATIC_DOCUMENTATION,
              rec(
                enable_documentation := false,
                documentation_stream := false,
                documentation_headers := rec( ),
                documentation_headers_main_file := false;
                path_to_xmlfiles := "";
                default_chapter := "";
                random_value := 10^10
              )
              
);

##
## Call this with the name of the chapter without whitespaces. THEY MUST BE UNDERSCORES! IMPORTANT! UNDERSCORES!
InstallGlobalFunction( CreateNewChapterXMLFile,
                       
  function( chapter_name )
    local filename, filestream, name_chapter;
    
    if IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name ) then
        
        Error( "tried to produce a chapter twice, something went wrong\n" );
        
        return false;
        
    fi;
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name := rec( sections := rec( ) );
    
    filename := Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, chapter_name, ".xml" );
    
    filestream := OutputTextFile( filename, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name.main_filestream := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, Concatenation( "<#Include SYSTEM \"", filename, "\">" ); );
    
    AppendTo( filestream, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( filestream, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( filestream, Concatenation( [ "<Chapter Label=\"", chapter_name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    name_chapter := ReplacedString( chapter_name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", name_chapter, "</Heading>\n" ] ) );
    
    return true;
    
end );
## ToDo: Close all chapters.

##
## Call this with a chapter name and a section name
InstallGlobalFunction( CreateNewSectionXMLFile,
                       
  function( chapter_name, section_name )
    local filestream;
    
    if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name ) then
        
        CreateNewChapterXMLFile( chapter_name );
        
    fi;
    
    if IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name.section_name ) then
        
        Error( "tried to create the same section stream twice, something went wrong\n" );
        
        return false;
        
    fi;
    
    filename := Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, chapter_name, "Section", section_name, ".xml" );
    
    filestream := OutputTextFile( filename, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name.sections.section_name := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name.main_filestream, Concatenation( "<#Include SYSTEM \"", filename, "\">" ); );
    
    AppendTo( filestream, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( filestream, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( filestream, Concatenation( [ "<Section Label=\"", section_name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    name_chapter := ReplacedString( section_name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", section_name, "</Heading>\n" ] ) );
    
    return true;
    
end );

##
## Gets three strings. Initialises everything.
InstallGlobalFunction( CreateAutomaticDocumentation,

  function( arg )
    local package_name, name_documentation_file, path_to_xmlfiles, chapters, dependencies, chapter_record, section_stream;
    
    package_name := arg[ 1 ];
    
    docfile := arg[ 2 ];
    
    path_to_xmlfiles := arg[ 3 ];
    
    AUTOMATIC_DOCUMENTATION.default_chapter := [ [ Concatenation( package_name, "_automatic_generated_documentation" ),
                                                  Concatenation( package_name, "_automatic_generated_documentation_functions" )
                                               ] ];
    
    AUTOMATIC_DOCUMENTATION.path_to_xmlfiles := path_to_xmlfiles;
    
    ## First of all, make shure $package_name is the only package to be loaded:
    dependencies := PackageInfo( package_name )[ 1 ].Dependencies;
    
    List( dependencies.NeededOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    
    List( dependencies.SuggestedOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    ## Now loading $package_name only loads ONE package.
    
    ## Initialising the filestreams.
    AUTOMATIC_DOCUMENTATION.enable_documentation := true;
    
    AUTOMATIC_DOCUMENTATION.documentation_stream := OutputTextFile( name_documentation_file, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers_main_file := OutputTextFile( "AutomaticDocumentationMainFile", false );
    
    ## Creating a header for the xml file.
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, "<!--\n This is an automatically generated file. \n -->\n" );
    
    ## Magic!
    LoadPackage( package_name );
    
    ## Close header file and streams
    
    for chapter_record in AUTOMATIC_DOCUMENTATION.documentation_headers do
        
        AppendTo( chapter_record.main_filestream, "</Chapter>" );
        
        CloseStream( chapter_record.main_filestream );
        
        for section_stream in chapter_record.sections do
            
            AppendTo( section_stream, "</Section" );
            
            CloseStream( section_stream );
            
        od;
        
    od;
    
    CloseStream( HOMALG_DOCUMENTATION.documentation_stream );
    
    CloseStream( HOMALG_DOCUMENTATION.documentation_headers_main_file );
    
    return true;

end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareCategoryWithDocumentation,

  function( arg )
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method HomalgDeclareCategory must be called with 3, 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments := arg[ 4 ];
                
            elif IsList( arg[ 4 ] ) and not IsString( arg[ 4 ] ) then
                
                chapter_info := arg[ 4 ];
                
                arguments := "arg";
                
            else
                
                Error( "the 4th argument is unrecognized" );
                
            fi;
            
        elif Length( arg ) = 5 then
            
            arguments := arg[ 4 ];
            
            chapter_info := arg[ 5 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        i := 2;
        
        tester_names := List( tester, i -> ShallowCopy( NamesFilter( i ) ) );
        
        for j in [ 1 .. Length( tester_names ) ] do
            
            for i in [ 1 .. Length( tester_names[ j ] ) ] do
                
                if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                    
                    Remove( tester_names[ j ], i );
                    
                fi;
                
            od;
            
            tester_names[ j ] := JoinStringsWithSeparator( tester_names[ j ], " and " );
            
        od;
        
        tester_names := JoinStringsWithSeparator( tester_names, " and " );
        
        label_rand_hash := Concatenation( [ name, String( Random( 0, HOMALG_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
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
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_info[ 1 ].chapter_info[ 2 ] ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_info[ 1 ].chapter_info[ 2 ],
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareCategory( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

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
InstallGlobalFunction( DeclareAttributeWithDocumentation,

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
InstallGlobalFunction( DeclarePropertyWithDocumentation,

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