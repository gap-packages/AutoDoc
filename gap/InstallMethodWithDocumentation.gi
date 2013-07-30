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
                random_value := 10^10,
                grouped_items := rec( ),
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
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, "title.xml" ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
    indent := 0;
    Out := function(arg)
        local s;
        s := ListWithIdenticalEntries( indent * 2, ' ');
        Append( s,  Concatenation( arg ) );
        AppendTo( filestream, s );
    end;
    
    Out( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n\n" );
    
    Out( "<!--\n This is an automatically generated file. \n -->\n" );

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
    
    Out( "<TitleComment>(<E>this manual is still under construction</E>)\n" );
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
        tmp := titlepage.Copyright;
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
    
    filestream := OutputTextFile( Concatenation( AUTOMATIC_DOCUMENTATION.path_to_xmlfiles, package_name, ".xml" ), false );
    
    SetPrintFormattingStatus( filestream, false );
    
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
    
    SetPrintFormattingStatus( filestream, false );
    
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
    
    SetPrintFormattingStatus( filestream, false );
    
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
          dependencies, intro, chapter_record, section_stream, intro_string, group_names, current_group;
    
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
    
    SetPrintFormattingStatus( AUTOMATIC_DOCUMENTATION.documentation_stream, false );
    
    AUTOMATIC_DOCUMENTATION.documentation_headers_main_file := OutputTextFile( Concatenation( path_to_xmlfiles, "AutoDocMainFile.xml" ), false );
    
    SetPrintFormattingStatus( AUTOMATIC_DOCUMENTATION.documentation_headers_main_file, false );
    
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
        
        AutoDoc_WriteGroupedEntry( AUTOMATIC_DOCUMENTATION.documentation_stream, current_group.label_rand_hash, current_group.elements, current_group.return_value, current_group.description, current_group.label_list );
        
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

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareCategoryWithDocumentation,

  function( arg )
    local name, tester;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareCategory( name, tester );
    
    return CallFuncList( CreateDocEntryForCategory, arg );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclareRepresentationWithDocumentation,

  function( arg )
    local name, tester, req_entries;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    req_entries := arg[ 3 ];
    
    DeclareRepresentation( name, tester, req_entries );
    
    return CallFuncList( CreateDocEntryForRepresentation, arg );
    
end );

##
## Call this with arguments name, list of tester, return value, description, arguments as list or string. The last one is optional
InstallGlobalFunction( DeclareOperationWithDocumentation,

  function( arg )
    local name, tester;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareOperation( name, tester );
    
    return CallFuncList( CreateDocEntryForOperation, arg );
    
end );

##
## Call this with arguments name, tester, return value, description, arguments. The last one is optional
InstallGlobalFunction( DeclareAttributeWithDocumentation,

  function( arg )
    local name, tester;
    
    if not Length( arg ) in [ 4 .. 7 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareAttribute( name, tester );
    
    return CallFuncList( CreateDocEntryForAttribute, arg );
    
end );

##
## Call this with arguments name, tester, description, arguments. The last one is optional
InstallGlobalFunction( DeclarePropertyWithDocumentation,

  function( arg )
    local name, tester, description, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    tester := arg[ 2 ];
    
    DeclareProperty( name, tester );
    
    return CallFuncList( CreateDocEntryForProperty, arg );
    
end );

##
## Call this with arguments function name, short description, list of tester, return value, description, arguments as list or string,
## chapter and section info, and function. 6 and 7 are optional
InstallGlobalFunction( InstallMethodWithDocumentation,

  function( arg )
    local name, short_descr, func, tester, description, return_value, arguments, chapter_info,
          tester_names, i, j, label_rand_hash, doc_stream;
    
    if not Length( arg ) in [ 6 .. 8 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    short_descr := arg[ 2 ];
    
    tester := arg[ 3 ];
    
    func := arg[ Length( arg ) ];
    
    InstallMethod( name, short_descr, tester, func );
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        name := NameFunction( name );
        
        description := arg[ 4 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "5th argument must be a string or a list of strings" );
            
        fi;
        
        return_value := arg[ 5 ];
        
        if Length( arg ) = 7 then
            
            if IsString( arg[ 6 ] ) then
                
                arguments :=  arg[ 6 ];
                
                chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.methods;
                
            elif IsList( arg[ 6 ] ) and not IsString( arg[ 6 ] ) then
                
                chapter_info := arg[ 6 ];
                
                arguments := List( [ 1 .. Length( tester ) ], i -> Concatenation( [ "arg", String( i ) ] ) );
                
                arguments := JoinStringsWithSeparator( arguments );
                
            fi;
            
        elif Length( arg ) = 8 then
            
            arguments := arg[ 6 ];
            
            chapter_info := arg[ 7 ];
            
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
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, "##    <Meth Arg=\"", arguments, "\" Name=\"", name, "\" Label=\"", short_descr, ", for ", tester_names, "\"/>\n" );
        AppendTo( doc_stream, "##    <Returns>", return_value, "</Returns>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        
        for i in description do
            
            AppendTo( doc_stream, "##      ", i, "\n" );
            
        od;
        
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    return true;
    
end );

##
## Call this with arguments name, return value, description, arguments as string, chapter and section as a list of two strings. The last two are optional
InstallGlobalFunction( DeclareGlobalFunctionWithDocumentation,

  function( arg )
    local name, description, return_value, arguments, chapter_info,
          label_rand_hash, doc_stream, i, grouping, is_grouped, option_record, label_list, label_name;
    
    if not Length( arg ) in [ 3 .. 6 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        option_record := arg[ Length( arg ) ];
        
        if not IsRecord( option_record ) then
            
            option_record := rec( );
            
        else
            
            Remove( arg );
            
        fi;
        
        if IsBound( option_record.group ) then
            
            is_grouped := true;
            
            grouping := option_record.group;
            
            if not IsString( grouping ) then
                
                Error( "group name must be a string." );
                
            fi;
            
        else
            
            is_grouped := false;
            
        fi;
        
        description := arg[ 2 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "second argument must be a string or a list of strings" );
            
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
        
        label_list := [ ];
        
        if IsBound( option_record.label ) and IsString( option_record.label ) then
            
            label_list := [ option_record.label ];
            
        fi;
        
        label_name := "";
        
        if IsBound( option_record.function_label ) and IsString( option_record.function_label ) then
            
            label_name := option_record.function_label;
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] },
                                          String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        if is_grouped and not IsBound( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping) ) then
            
            AUTOMATIC_DOCUMENTATION.grouped_items.(grouping) := rec( elements := [ ],
                                                                          description := [ ],
                                                                          label_rand_hash := label_rand_hash,
                                                                          chapter_info := chapter_info,
                                                                          return_value := "",
                                                                          label_list := label_list,
                                                                         );
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
            AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                      "<#Include Label=\"", label_rand_hash, "\">\n" );
            
        elif not is_grouped then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
            AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                      "<#Include Label=\"", label_rand_hash, "\">\n" );
            
        fi;
        
        if is_grouped then
            
            Add( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).elements, [ "Func", arguments, name, label_name ] ); ## Empty string might cause problems.
            
            AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).description := Concatenation( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).description, description );
            
            AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).return_value := return_value;
            
            AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).label_list := Concatenation( AUTOMATIC_DOCUMENTATION.grouped_items.(grouping).label_list, label_list );
            
        else
            
            doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
            
            AutoDoc_WriteEntry( doc_stream, label_rand_hash, "Func", arguments, name, label_name, return_value, description, label_list );
            
        fi;
        
    fi;
    
    DeclareGlobalFunction( name );
    
    return true;
    
end );

##
## Call this with arguments name, description, chapter and section as a list of two strings. The last one is optional
InstallGlobalFunction( DeclareGlobalVariableWithDocumentation,

  function( arg )
    local name, description, chapter_info,
          label_rand_hash, doc_stream, i;
    
    if not Length( arg ) in [ 2 .. 4 ] then
        
        Error( "wrong number of arguments\n" );
        
        return false;
        
    fi;
    
    name := arg[ 1 ];
    
    if AUTOMATIC_DOCUMENTATION.enable_documentation then
        
        description := arg[ 2 ];
        
        if IsString( description ) then
            
            description := [ description ];
            
        fi;
        
        if not ForAll( description, IsString ) then
            
            Error( "second argument must be a string or a list of strings" );
            
        fi;
        
        if Length( arg ) = 3 then
            
            chapter_info := arg[ 3 ];
            
        else
            
            chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.global_variables;
            
        fi;
        
        label_rand_hash := Concatenation( [ name{ [ 1 .. Minimum( Length( name ), SizeScreen( )[ 1 ] - LogInt( AUTOMATIC_DOCUMENTATION.random_value, 10 ) -22 ) ] }, String( Random( 0, AUTOMATIC_DOCUMENTATION.random_value ) ) ] );
        
        doc_stream := AUTOMATIC_DOCUMENTATION.documentation_stream;
        
        AppendTo( doc_stream, "##  <#GAPDoc Label=\"", label_rand_hash , "\">\n" );
        AppendTo( doc_stream, "##  <ManSection>\n" );
        AppendTo( doc_stream, "##    <Var Name=\"", name, "\"/>\n" );
        AppendTo( doc_stream, "##    <Description>\n" );
        
        for i in description do
            
            AppendTo( doc_stream, "##      ", i, "\n" );
            
        od;
        
        AppendTo( doc_stream, "##    </Description>\n" );
        AppendTo( doc_stream, "##  </ManSection>\n" );
        AppendTo( doc_stream, "##  <#/GAPDoc>\n" );
        AppendTo( doc_stream, "##\n\n" );
        
        if not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]) ) 
           or not IsBound( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]) ) then
            
            CreateNewSectionXMLFile( chapter_info[ 1 ], chapter_info[ 2 ] );
            
        fi;
        
        AppendTo( AUTOMATIC_DOCUMENTATION.documentation_headers.(chapter_info[ 1 ]).sections.(chapter_info[ 2 ]),
                  "<#Include Label=\"", label_rand_hash, "\">\n" );
        
    fi;
    
    DeclareGlobalVariable( name );
    
    return true;
    
end );
