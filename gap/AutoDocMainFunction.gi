#############################################################################
##
##  AutoDoc package
##
##  Copyright 2007-2013,   Sebastian Gutsche, University of Kaiserslautern
##                         Max Horn, Justus-Liebig-Universität Gießen
##
##  
##
#############################################################################

##
InstallValue( AUTOMATIC_DOCUMENTATION,
              rec(
                enable_documentation := false,
                documentation_stream := false,
                documentation_headers := rec( ),
                documentation_headers_main_file := false,
                path_to_xmlfiles := Directory(""),
                default_chapter := rec( ),
                label_counter := 0,
                grouped_items := rec( ),
              )
           );


BindGlobal("AUTODOC_XML_HEADER", Concatenation(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n",
    "<!--\n This is an automatically generated file. \n -->\n"
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
    local filestream, indent, package_info, titlepage, author_records, tmp, lines, Out;
    
    filestream := OutputTextFile( Filename( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, "title.xml" ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
    indent := 0;
    Out := function(arg)
        local s;
        s := ListWithIdenticalEntries( indent * 2, ' ');
        Append( s,  Concatenation( arg ) );
        AppendTo( filestream, s );
    end;
    
    Out( AUTODOC_XML_HEADER );

    Out( "<TitlePage>\n" );
    
    indent := indent + 1;
    
    Out( "<Title>&", package_name, ";</Title>\n" );
    
    package_info := PackageInfo( package_name )[ 1 ];
    
    if IsBound(package_info.AutoDoc) and IsBound(package_info.AutoDoc.TitlePage) then
        titlepage := StructuralCopy(package_info.AutoDoc.TitlePage);
    else
        titlepage := rec();
    fi;

    if IsBound(titlepage.Subtitle) then
        tmp := titlepage.Subtitle;
        Unbind( titlepage.Subtitle );
    else
        tmp := ReplacedString( package_info.Subtitle, "GAP", "&GAP;" );
    fi;
    Out( "<Subtitle>", tmp, "</Subtitle>\n" );
    
    Out( "<TitleComment>\n" );
    indent := indent + 1;
    Out( "<Br/><Br/>\n" );
    Out( "This manual is best viewed as an <B>HTML</B> document.\n" );
    Out( "An <B>offline</B> version should be included in the documentation\n" );
    Out( "subfolder of the package.\n" );
    Out( "<Br/><Br/>\n" );
    indent := indent - 1;
    Out( "</TitleComment>\n" );
    
    Out( "<Version>Version <#Include SYSTEM \"../VERSION\"></Version>\n" );
    
    for author_records in package_info.Persons do
        
        if author_records.IsAuthor then
            
            Out( "<Author>", Concatenation(
                   author_records.FirstNames, " ", author_records.LastName ), "<Alt Only=\"LaTeX\"><Br/></Alt>\n" );
            indent := indent + 1;

            # TODO: Properly indent strings containing newlines
            Out( "<Address>\n" );
            indent := indent + 1;
            lines := SplitString( author_records.PostalAddress, "\n" );
            for tmp in lines do
               Out( tmp, "<Br/>\n" );
            od;
            #Out( author_records.PostalAddress, "\n" );
            indent := indent - 1;
            Out( "</Address>\n" );
            Out( "<Email>", author_records.Email, "</Email>\n" );
            Out( "<Homepage>", author_records.WWWHome, "</Homepage>\n" );
            indent := indent - 1;

            Out( "</Author>\n" );
            
        fi;
        
    od;
    
    Out( Concatenation( "<Date>", package_info.Date, "</Date>\n" ) );

    Out( "<Copyright>\n" );
    if IsBound(titlepage.Copyright) then
        Out( titlepage.Copyright );
        Unbind( titlepage.Copyright );
    else
        Out( "This package may be distributed under the terms and conditions of the\n" );
        Out( "GNU Public License Version 2.\n" );
    fi;
    Out( "</Copyright>\n" );

    for tmp in RecNames(titlepage) do
        Out( "<", tmp, ">\n" );
        Out( titlepage.(tmp) );
        Out( "</", tmp, ">\n" );
    od;

    indent := indent - 1;
    Out( "</TitlePage>\n" );
    
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
    
    filestream := OutputTextFile( Filename( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, Concatenation( package_name, ".xml" ) ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
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
    
    filestream := OutputTextFile( Filename( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, filename ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).main_filestream := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, Concatenation( "<#Include SYSTEM \"", filename, "\">" ) );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
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
    
    filestream := OutputTextFile( Filename( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, filename ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).sections.(section_name) := filestream;
    
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_name).main_filestream, Concatenation( "<#Include SYSTEM \"", filename, "\">\n" ) );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
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
          dependencies, intro, chapter_record, section_stream, intro_string, group_names, current_group;
    
    package_name := arg[ 1 ];
    
    name_documentation_file := arg[ 2 ];
    
    path_to_xmlfiles := arg[ 3 ];

    if IsString( path_to_xmlfiles ) then
        path_to_xmlfiles := Directory( path_to_xmlfiles );
    fi;
    
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
    
    SetPrintFormattingStatus( AUTOMATIC_DOCUMENTATION.documentation_stream, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers_main_file := OutputTextFile( Filename( path_to_xmlfiles, "AutoDocMainFile.xml" ), false );
    
    SetPrintFormattingStatus( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, false );
    
    ## Creating a header for the xml file.
    AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, AUTODOC_XML_HEADER );
    
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
                
                AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(intro[ 1 ]).main_filestream, intro_string );
                
            elif Length( intro ) = 3 then
                
                CreateNewSectionXMLFile( intro[ 1 ], intro[ 2 ] );
                
                intro_string := intro[ 3 ];
                
                if not IsString( intro_string ) then
                    
                    intro_string := JoinStringsWithSeparator( intro_string, " " );
                    
                fi;
                
                AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(intro[ 1 ]).sections.(intro[ 2 ]), intro_string );
                
            else
                
                Error( "wrong format of introduction string list\n" );
                
            fi;
        
        od;
        
    fi;
    
    ## Magic!
    LoadPackage( package_name );
    
    ## Write out the groups
    
    for group_names in RecNames( AUTOMATIC_DOCUMENTATION.grouped_items ) do
        
        current_group := AUTOMATIC_DOCUMENTATION.grouped_items.(group_names);
        
        AutoDoc_WriteGroupedEntry( AUTOMATIC_DOCUMENTATION.documentation_stream, current_group.label_hash, current_group.elements, current_group.return_value, current_group.description, current_group.label_list );
        
    od;
    
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