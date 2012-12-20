#############################################################################
##
##  InstallMethodWithDocumentation.gi         AutoDoc package
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
                documentation_headers_main_file := false,
                path_to_xmlfiles := "",
                default_chapter := rec( ),
                random_value := 10^10
              )
           );

##
InstallGlobalFunction( CreateDefaultChapterData,
                       
  function( package_name )
    local chapter_name, default_chapter_record, list_of_types, i;
    
    if not IsString( package_name ) then
        
        Error( "CreateDefaultChapterData must be called with a possible package name\n" );
        
    fi;
    
    chapter_name := Concatenation( package_name, "_automatic_generated_documentation" );
    
    default_chapter_record := AUTOMATIC_DOCUMENTATION.default_chapter;
    
    list_of_types := [ "categories", "methods", "attributes", "properties", "global_functions", "global_variables" ];
    
    for i in list_of_types do
        
        default_chapter_record.(i) := [ chapter_name,
                                        Concatenation( package_name, "_automatic_generated_documentation_of_", i ) ];
        
    od;
    
    return true;
    
end );

##
InstallGlobalFunction( CreateTitlePage,
                       
  function( package_name )
    local filestream, package_info, author_records;
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, "title.xml" ), false );
    
    AppendTo( filestream, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( filestream, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( filestream, "<TitlePage>\n" );
    
    AppendTo( filestream, Concatenation( "<Title>&", package_name, ";</Title>\n" ) );
    
    package_info := PackageInfo( package_name )[ 1 ];
    
    AppendTo( filestream, Concatenation( "<Subtitle>", ReplacedString( package_info.Subtitle, "GAP", "&GAP;" ), "</Subtitle>" ) );
    
    AppendTo( filestream, "<TitleComment>(<E>this manual is still under construction</E>)\n" );
    AppendTo( filestream, "<Br/><Br/>\n" );
    AppendTo( filestream, "This manual is best viewed as an <B>HTML</B> document.\n" );
    AppendTo( filestream, "An <B>offline</B> version should be included in the documentation\n" );
    AppendTo( filestream, "subfolder of the package.\n" );
    AppendTo( filestream, "<Br/><Br/>\n" );
    AppendTo( filestream, "</TitleComment>\n" );
    
    AppendTo( filestream, "<Version>Version <#Include SYSTEM \"../VERSION\"></Version>\n" );
    
    for author_records in package_info.Persons do
        
        if author_records.IsAuthor then
            
            AppendTo( filestream, Concatenation( "<Author>", Concatenation( author_records.FirstNames, " ", author_records.LastName ), "<Alt Only=\"LaTeX\"><Br/></Alt>\n" ) );
            AppendTo( filestream, Concatenation( "<Address>", author_records.PostalAddress, "</Address>\n" ) );
            AppendTo( filestream, Concatenation( "<Email>", author_records.Email, "</Email>\n" ) );
            AppendTo( filestream, Concatenation( "<Homepage>", author_records.WWWHome, "</Homepage>\n" ) );
            AppendTo( filestream, "</Author>\n" );
            
        fi;
        
    od;
    
    AppendTo( filestream, Concatenation( "<Date>", package_info.Date, "</Date>\n" ) );
    
    AppendTo( filestream, "<Copyright>\n" );
    AppendTo( filestream, "This package may be distributed under the terms and conditions of the\n" );
    AppendTo( filestream, "GNU Public License Version 2.\n" );
    AppendTo( filestream, "</Copyright>\n" );
    
    AppendTo( filestream, "<Acknowledgements>\n" );
    
    AppendTo( filestream, "</Acknowledgements>\n" );
    
    AppendTo( filestream, "</TitlePage>\n" );
    
    CloseStream( filestream );
    
    return true;
    
end );

##
## Call this with the packagename. It creates a simple main file. Call it with package name and maybe a list of entities.

InstallGlobalFunction( CreateMainPage,
                       
  function( arg )
    local package_name, entities, filestream, i;
    
    package_name := arg[ 1 ];
    
    if Length( arg ) = 2 then
        
        entities := arg[ 2 ];
        
        Add( entities, package_name );
        
    elif Length( arg ) = 1 then
        
        entities := [ "GAP4", "Maple", "Mathematica", "Singular", "Plural", "Sage", "python", "cython", 
                      "C", "MAGMA", "Macaulay2", "IO", "homalg", "ResidueClassRingForHomalg", "LIRNG", "LIMAP",
                      "LIMAT", "COLEM", "LIMOD", "LIMOR", "LICPX", "ExamplesForHomalg", "alexander", "Gauss",
                      "GaussForHomalg", "HomalgToCAS", "IO_ForHomalg", "MapleForHomalg", "RingsForHomalg",
                      "LessGenerators", "Yoneda", "Sheaves", "SCO", "LocalizeRingForHomalg", "GAPDoc", "AutoDoc",
                      package_name ];
        
    else
        
        Error( "Wrong number of arguments\n" );
        
    fi;
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, package_name, ".xml" ), false );
    
    AppendTo( filestream, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n" );
    
    AppendTo( filestream, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );
    
    AppendTo( filestream, "<!ENTITY see '<Alt Only=\"LaTeX\">$\to$</Alt><Alt Not=\"LaTeX\">--&gt;</Alt>'>\n" );
    
    for i in entities do
        
        AppendTo( filestream, Concatenation( "<!ENTITY ", i, " '<Package>", i, "</Package>'>\n" ) );
        
    od;
    
    AppendTo( filestream, "]\n>\n" );
    
    AppendTo( filestream, Concatenation( "<Book Name=\"", package_name, "\">\n" ) );
    
    AppendTo( filestream, "<#Include SYSTEM \"title.xml\">\n" );
    
    AppendTo( filestream, "<TableOfContents/>\n" );
    
    AppendTo( filestream, "<Body>\n" );
    
    AppendTo( filestream, Concatenation( "<Index>&", package_name, ";</Index>\n" ) );
    
    AppendTo( filestream, "<#Include SYSTEM \"AutoDocMainFile.xml\">\n" );
    
    AppendTo( filestream, "</Body>\n<TheIndex/>\n</Book>" );
    
    CloseStream( filestream );
    
    return true;
    
end );

##
## Call this with the name of the chapter without whitespaces. THEY MUST BE UNDERSCORES! IMPORTANT! UNDERSCORES!
InstallGlobalFunction( CreateNewChapterXMLFile,
                       
  function( chapter_name )
    local filename, filestream, name_chapter;
    
    if IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.chapter_name ) then
        
        return true;
        
    fi;
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name) := rec( sections := rec( ) );
    
    filename := Concatenation( chapter_name, ".xml" );
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, filename ), false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).main_filestream := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, Concatenation( "<#Include SYSTEM \"", filename, "\">" ) );
    
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
    local filename, filestream, name_chapter;
    
    if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name) ) then
        
        CreateNewChapterXMLFile( chapter_name );
        
    fi;
    
    if IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).sections.(section_name) ) then
        
        return true;
        
    fi;
    
    filename := Concatenation( chapter_name, "Section", section_name, ".xml" );
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, filename ), false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).sections.(section_name) := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).main_filestream, Concatenation( "<#Include SYSTEM \"", filename, "\">\n" ) );
    
    AppendTo( filestream, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( filestream, "<!--\n This is an automatically generated file. \n -->\n" );
    
    AppendTo( filestream, Concatenation( [ "<Section Label=\"", section_name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    name_chapter := ReplacedString( section_name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", name_chapter, "</Heading>\n" ] ) );
    
    return true;
    
end );

##
## Gets three strings. Initialises everything.
InstallGlobalFunction( CreateAutomaticDocumentation,

  function( arg )
    local package_name, name_documentation_file, path_to_xmlfiles, create_full_docu, introduction_list, entities, 
          dependencies, intro, chapter_record, section_stream, intro_string;
    
    package_name := arg[ 1 ];
    
    name_documentation_file := arg[ 2 ];
    
    path_to_xmlfiles := arg[ 3 ];
    
    create_full_docu := arg[ 4 ];
    
    CreateDefaultChapterData( package_name );
    
    AUTOMATIC_DOCUMENTATION.path_to_xmlfiles := path_to_xmlfiles;
    
    ## First of all, make shure $package_name is the only package to be loaded:
    dependencies := PackageInfo( package_name )[ 1 ].Dependencies;
    
    List( dependencies.NeededOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    
    List( dependencies.SuggestedOtherPackages, i -> LoadPackage( i[ 1 ] ) );
    ## Now loading $package_name only loads ONE package.
    
    ## Initialising the filestreams.
    AUTOMATIC_DOCUMENTATION.enable_documentation := true;
    
    AUTOMATIC_DOCUMENTATION.documentation_stream := OutputTextFile( name_documentation_file, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers_main_file := OutputTextFile( Concatenation( path_to_xmlfiles, "AutoDocMainFile.xml" ), false );
    
    ## Creating a header for the xml file.
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, "<!--\n This is an automatically generated file. \n -->\n" );
    
    if Length( arg ) = 5 then
        
        if Length( arg[ 5 ] ) > 0 then
            
            if IsString( arg[ 5 ][ 1 ] ) then
                
                entities := arg[ 5 ];
                
            elif IsList( arg[ 5 ][ 1 ] ) and not IsString( arg[ 5 ][ 1 ] ) then
                
                introduction_list := arg[ 5 ];
                
            fi;
            
        fi;
        
    elif Length( arg ) = 6 then
        
        introduction_list := arg[ 5 ];
        
        entities := arg[ 6 ];
        
    fi;
    
    if create_full_docu then
        
        CreateTitlePage( package_name );
        
        if IsBound( entities ) then
            
            CreateMainPage( package_name, entities );
            
        else
            
            CreateMainPage( package_name );
            
        fi;
        
    fi;
    
    if IsBound( introduction_list ) then
      
        for intro in arg[ 5 ] do
            
            if Length( intro ) = 2 then
                
                CreateNewChapterXMLFile( intro[ 1 ] );
                
                intro_string := intro[ 2 ];
                
                if not IsString( intro_string ) then
                    
                    intro_string := JoinStringsWithSeparator( intro_string, " " );
                    
                fi;
                
                AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(intro[ 1 ]).main_filestream, intro[ 2 ] );
                
            elif Length( intro ) = 3 then
                
                CreateNewSectionXMLFile( intro[ 1 ], intro[ 2 ] );
                
                intro_string := intro[ 3 ];
                
                if not IsString( intro_string ) then
                    
                    intro_string := JoinStringsWithSeparator( intro_string, " " );
                    
                fi;
                
                AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(intro[ 1 ]).sections.(intro[ 2 ]), intro[ 3 ] );
                
            else
                
                Error( "wrong format of introduction string list\n" );
                
            fi;
        
        od;
        
    fi;
    
    ## Magic!
    LoadPackage( package_name );
    
    ## Close header file and streams
    
    for chapter_record in RecNames(AUTOMATIC_DOCUMENTATION.documentation_headers) do
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_record).main_filestream, "</Chapter>" );
        
        CloseStream( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_record).main_filestream );
        
        for section_stream in RecNames( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_record).sections ) do
            
            AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_record).sections.(section_stream), "</Section>" );
            
            CloseStream( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_record).sections.(section_stream) );
            
        od;
        
    od;
    
    CloseStream( AUTOMATIC_DOCUMENTATION.documentation_stream );
    
    CloseStream( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file );
    
    return true;

end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareCategoryWithDocumentation,

  function( arg )
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method DeclareCategoryWithDocumentation must be called with 3, 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments := arg[ 4 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
                
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
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Filt Type=\"Category\" Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\" />\n" ] ) );
        AppendTo( doc_stream, "##    <Returns><C>true</C> or <C>false</C></Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareCategory( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareRepresentationWithDocumentation,

  function( arg )
    local name, tester, req_entries, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method DeclareCategoryWithDocumentation must be called with 4, 5 or 6 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    req_entries := arg[ 3 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 4 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments := arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := "arg";
                
            else
                
                Error( "the 4th argument is unrecognized" );
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.categories;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Filt Type=\"Representation\" Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\" />\n" ] ) );
        AppendTo( doc_stream, "##    <Returns><C>true</C> or <C>false</C></Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareRepresentation( name, tester, req_entries );
    
    return true;
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

  function( arg )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method DeclareOperationWithDocumentation must be called with 4, 5, or 6 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        return_value := arg[ 4 ];
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments :=  arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
                
                arguments := JoinStringsWithSeparator( arguments );
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
            
            arguments := JoinStringsWithSeparator( arguments );
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
            
        fi;
        
        tester_names := List( tester, i -> ShallowCopy( NamesFilter( i ) ) );
        
        for j in [ 1 .. Length( tester_names ) ] do
            
            for i in [ 1 .. Length( tester_names[ j ] ) ] do
                
                if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                    
                    Remove( tester_names[ j ], i );
                    
                fi;
                
            od;
            
            
            if Length( tester_names[ j ] ) = 0 then
                
                tester_names[ j ] := "IsObject";
                
            else
                
                tester_names[ j ] := JoinStringsWithSeparator( tester_names[ j ], " and " );
                
            fi;
            
        od;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        tester_names := JoinStringsWithSeparator( tester_names, ", " );
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Oper Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareOperation( name, tester );
    
    return true;
    
end );

##
## Call this with arguments function name, short description, list of tester, function, return value, description, arguments as list or string, and
## chapter and section info. The last one is optional
InstallGlobalFunction( InstallMethodWithDocumentation,

  function( arg )
    local name, short_descr, func, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 6 and Length( arg ) <> 7 and Length( arg ) <> 8 then
        
        Error( "the method InstallMethodWithDocumentation must be called with 6, 7, or 8 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    short_descr := arg[ 2 ];
    
    tester := arg[ 3 ];
    
    func := arg[ 4 ];
    
    InstallMethod( name, short_descr, tester, func );
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        name := NameFunction( name );
        
        description := arg[ 5 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        return_value := arg[ 6 ];
        
        if Length( arg ) = 7 then
            
            if IsString( arg[ 7 ] ) then
                
                arguments :=  arg[ 7 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
                
            elif IsList( arg[ 7 ] ) and not IsString( arg[ 7 ] ) then
                
                chapter_info := arg[ 7 ];
                
                arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
                
                arguments := JoinStringsWithSeparator( arguments );
                
            fi;
            
        elif Length( arg ) = 8 then
            
            arguments := arg[ 7 ];
            
            chapter_info := arg[ 8 ];
            
        else
            
            arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
            
            arguments := JoinStringsWithSeparator( arguments );
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
            
        fi;
        
        tester_names := List( tester, i -> ShallowCopy( NamesFilter( i ) ) );
        
        for j in [ 1 .. Length( tester_names ) ] do
            
            for i in [ 1 .. Length( tester_names[ j ] ) ] do
                
                if IsMatchingSublist( tester_names[ j ][ i ], "Tester(" ) then
                    
                    Remove( tester_names[ j ], i );
                    
                fi;
                
            od;
            
            
            if Length( tester_names[ j ] ) = 0 then
                
                tester_names[ j ] := "IsObject";
                
            else
                
                tester_names[ j ] := JoinStringsWithSeparator( tester_names[ j ], " and " );
                
            fi;
            
        od;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        tester_names := JoinStringsWithSeparator( tester_names, ", " );
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Meth Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"", short_descr, ", for ", tester_names, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    return true;
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( DeclareAttributeWithDocumentation,

  function( arg )
    local name, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 4 and Length( arg ) <> 5 and Length( arg ) <> 6 then
        
        Error( "the method DeclareAttributeWithDocumentation must be called with 4 or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    return_value := arg[ 4 ];
    
    if Length( arg ) = 5 then
        
        arguments := arg[ 5 ];
        
    else
        
        arguments := "arg";
        
    fi;
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        return_value := arg[ 4 ];
        
        if Length( arg ) = 5 then
            
            if IsString( arg[ 5 ] ) then
                
                arguments :=  arg[ 5 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.attributes;
                
            elif IsList( arg[ 5 ] ) and not IsString( arg[ 5 ] ) then
                
                chapter_info := arg[ 5 ];
                
                arguments := "arg";
                
            fi;
            
        elif Length( arg ) = 6 then
            
            arguments := arg[ 5 ];
            
            chapter_info := arg[ 6 ];
            
        else
            
            arguments := "arg";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.attributes;
            
        fi;
      
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Attr Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareAttribute( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclarePropertyWithDocumentation,

  function( arg )
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method DeclarePropertyWithDocumentation must be called with 3, 4, or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 3 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments := arg[ 4 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.properties;
                
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
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.properties;
            
        fi;
        
        tester_names := ShallowCopy( NamesFilter( tester ) );
        
        for j in [ 1 .. Length( tester_names ) ] do

            if IsMatchingSublist( tester_names[ j ], "Tester(" ) then
                
                Remove( tester_names, j );
                
            fi;
            
        od;
        
        if Length( tester_names ) = 0 then
            
            tester_names := "IsObject";
            
        else
            
            tester_names := JoinStringsWithSeparator( tester_names, " and " );
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Prop Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"for ", tester_names, "\"/>\n" ] ) );
        AppendTo( doc_stream, "##    <Returns><C>true</C> or <C>false</C></Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareProperty( name, tester );
    
    return true;
    
end );

##
## Call this with arguments name, return value, description, arguments as string, chapter and section as a list of two strings. The last two are optional
InstallGlobalFunction( DeclareGlobalFunctionWithDocumentation,

  function( arg )
    local name, description, return_value, arguments, chapter_info,
          label_rand_hash, doc_stream;
    
    if Length( arg ) <> 3 and Length( arg ) <> 4 and Length( arg ) <> 5 then
        
        Error( "the method DeclareGlobalFunctionWithDocumentation must be called with 3, 4, or 5 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 2 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        return_value := arg[ 3 ];
        
        if Length( arg ) = 4 then
            
            if IsString( arg[ 4 ] ) then
                
                arguments :=  arg[ 4 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.global_functions;
                
            elif IsList( arg[ 4 ] ) and not IsString( arg[ 4 ] ) then
                
                chapter_info := arg[ 4 ];
                
                arguments := "args";
                
            fi;
            
        elif Length( arg ) = 5 then
            
            arguments := arg[ 4 ];
            
            chapter_info := arg[ 5 ];
            
        else
            
            arguments := "args";
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.global_functions;
            
        fi;
        
        if Length( return_value ) = 0 then
            
            return_value := "Nothing";
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Func Arg=\"", arguments, "\" Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, Concatenation( [ "##    <Returns>", return_value, "</Returns>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareGlobalFunction( name );
    
    return true;
    
end );

##
## Call this with arguments name, description, chapter and section as a list of two strings. The last one is optional
InstallGlobalFunction( DeclareGlobalVariableWithDocumentation,

  function( arg )
    local name, description, chapter_info,
          label_rand_hash, doc_stream;
    
    if Length( arg ) <> 2 and Length( arg ) <> 3 then
        
        Error( "the method DeclareGlobalVariableWithDocumentation must be called with 2 or 3 arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 2 ];
        
        if not IsString( description ) then
            
            description := JoinStringsWithSeparator( description, " " );
            
        fi;
        
        if Length( arg ) = 3 then
            
            chapter_info := arg[ 3 ];
            
        else
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.global_variables;
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) - 4 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, Concatenation( [ "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" ] ) );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, Concatenation( [ "##    <Var Name=\"", name, "\"/>\n" ] ) );
        AppendTo( doc_stream, "##    <Description>\n" );
        AppendTo( doc_stream, Concatenation( [ "##      ", description, "\n" ] ) );
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  Concatenation( [ "<#Include Label=\"", label_rand_hash, "\">\n" ] ) );
        
    fi;
    
    DeclareGlobalVariable( name );
    
    return true;
    
end );
