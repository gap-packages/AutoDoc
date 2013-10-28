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
                package_name := "",
                path_to_xmlfiles := Directory(""),
                default_chapter := rec( ),
              )
           );

##
InstallValue( AUTODOC_XML_HEADER, 
    Concatenation(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n",
    "<!-- This is an automatically generated file. -->\n"
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
        
        default_chapter_record.(i) := [ chapter_name, Concatenation( chapter_name, "_of_", i ) ];
        
    od;
    
    return default_chapter_record;
    
end );

##
InstallGlobalFunction( CreateTitlePage,
                       
  function( arg )
    local package_name, dir, opt, filestream, indent, package_info, titlepage, author_records, tmp, lines, Out, OutWithTag;
    
    package_name := arg[ 1 ];
    package_info := PackageInfo( package_name )[ 1 ];

    dir := arg[ 2 ];
    if IsString(dir) then
        dir := Directory(dir);
    fi;
    
    if IsBound( package_info.AutoDoc ) then
        opt := package_info.AutoDoc;
    else
        opt := rec();
    fi;

    if Length( arg ) = 3 then
        if IsRecord( arg[ 3 ] ) then
            opt := arg[ 3 ];
        else
            Error( "Third parameter must be a record" );
        fi;
    elif Length( arg ) > 3 then
        Error( "Wrong number of arguments\n" );
    fi;


    filestream := AUTODOC_OutputTextFile( dir, "title.xml" );
    
    indent := 0;
    Out := function(arg)
        local s;
        s := ListWithIdenticalEntries( indent * 2, ' ');
        Append( s, Concatenation( arg ) );
        AppendTo( filestream, s );
    end;
    
    OutWithTag := function( tag, content )
        local lines, s, l;
        if not IsString( content ) then
            content := Concatenation( content );
        fi;
        lines := SplitString( content, "\n" );
        s := ListWithIdenticalEntries( indent * 2, ' ');
        if Length(lines) = 1 then
            AppendTo( filestream, s, "<", tag, ">", content, "</", tag, ">\n" );
        else
            AppendTo( filestream, s, "<", tag, ">\n" );
            for l in lines do
                AppendTo( filestream, s, "  ", l, "\n" );
            od;
            AppendTo( filestream, s, "</", tag, ">\n" );
        fi;
    end;
    
    Out( AUTODOC_XML_HEADER );

    Out( "<TitlePage>\n" );
    
    indent := indent + 1;
    
    OutWithTag( "Title", [ "&", package_name, ";" ] );
    
    if IsBound(opt.TitlePage) then
        titlepage := StructuralCopy(opt.TitlePage);
    else
        titlepage := rec();
    fi;

    if IsBound(titlepage.Subtitle) then
        tmp := titlepage.Subtitle;
        Unbind( titlepage.Subtitle );
    else
        tmp := ReplacedString( package_info.Subtitle, "GAP", "&GAP;" );
    fi;
    OutWithTag( "Subtitle", tmp );
    
    Out( "<TitleComment>\n" );
    if IsBound(titlepage.TitleComment) then
        Out( titlepage.TitleComment );
        Unbind( titlepage.TitleComment );
    else
        indent := indent + 1;
        # TODO: Do we really want this (resp. any) default string?
        Out( "<Br/><Br/>\n" );
        Out( "This manual is best viewed as an <B>HTML</B> document.\n" );
        Out( "An <B>offline</B> version should be included in the documentation\n" );
        Out( "subfolder of the package.\n" );
        Out( "<Br/><Br/>\n" );
        indent := indent - 1;
    fi;
    Out( "</TitleComment>\n" );
    
    OutWithTag( "Version", [ "Version ", package_info.Version ] );
    
    for author_records in package_info.Persons do
        
        # FIXME: Why not show maintainers?
        # We should show them, but could add a flag indicating they are not authors
        #if author_records.IsAuthor then
            
            Out( "<Author>", Concatenation(
                   author_records.FirstNames, " ", author_records.LastName ), "<Alt Only=\"LaTeX\"><Br/></Alt>\n" );
            indent := indent + 1;

            # TODO: Properly indent strings containing newlines
            if IsBound(author_records.PostalAddress) then
                Out( "<Address>\n" );
                indent := indent + 1;
                lines := SplitString( author_records.PostalAddress, "\n" );
                for tmp in lines do
                    # TODO: Make the <Br/> here optionally, or even remove it entirely?
                    Out( tmp, "<Br/>\n" );
                od;
                #Out( author_records.PostalAddress, "\n" );
                indent := indent - 1;
                Out( "</Address>\n" );
            fi;
            if IsBound(author_records.Email) then
                OutWithTag( "Email", author_records.Email );
            fi;
            if IsBound(author_records.WWWHome) then
                OutWithTag( "Homepage", author_records.WWWHome );
            fi;
            indent := indent - 1;

            Out( "</Author>\n" );
            
        #fi;
        
    od;
    
    OutWithTag( "Date", package_info.Date );

    if IsBound(titlepage.Copyright) then
        OutWithTag( "Copyright", titlepage.Copyright );
        Unbind( titlepage.Copyright );
    else
        # TODO: Do we really want this (resp. any) default string?
        OutWithTag( "Copyright", [
            "This package may be distributed under the terms and conditions of the\n",
            "GNU Public License Version 2.\n",
            ]
        );
    fi;

    for tmp in RecNames(titlepage) do
        OutWithTag( tmp, titlepage.(tmp) );
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
    local package_name, dir, opt, filename, filestream, i, package_info;
    
    package_name := arg[ 1 ];
    package_info := PackageInfo( package_name )[ 1 ];

    dir := arg[ 2 ];
    if IsString(dir) then
        dir := Directory(dir);
    fi;

    if IsBound( package_info.AutoDoc ) then
        opt := package_info.AutoDoc;
    else
        opt := rec();
    fi;

    if Length( arg ) = 3 then
        if IsRecord( arg[ 3 ] ) then
            opt := arg[ 3 ];
        else
            # HACK: Support old-style calling with entities list as second parameter
            # This is not supported anymore, please see line 250s
            opt.entities := arg[ 2 ];
        fi;
    elif Length( arg ) > 3 then
        Error( "Wrong number of arguments\n" );
    fi;
    
    if not IsBound( opt.entities ) then
        
        opt.entities := [];
        
    fi;

    # TODO: Allow more complicated entities definitions: E.g. by allowing pairs
    #  [ name, value ]
    # TODO: and if we do that, then do not add package_name unconditionally to the list,
    # to allow the package author to define this entity slightly differently...
    Add( opt.entities, package_name );
    
    if IsBound( opt.main_xml_file ) then
        
        filename := opt.main_xml_file;
        
    else
        
        filename := Concatenation( package_name, ".xml" );
        
    fi;
    
    filestream := AUTODOC_OutputTextFile( dir, filename );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );
    
    AppendTo( filestream, "<!ENTITY see '<Alt Only=\"LaTeX\">$\to$</Alt><Alt Not=\"LaTeX\">--&gt;</Alt>'>\n" );
    
    for i in opt.entities do
        
        AppendTo( filestream, "<!ENTITY ", i, " '<Package>", i, "</Package>'>\n" );
        
    od;
    
    AppendTo( filestream, "]\n>\n" );
    
    AppendTo( filestream, "<Book Name=\"", package_name, "\">\n" );
    
    AppendTo( filestream, "<#Include SYSTEM \"title.xml\">\n" );
    
    AppendTo( filestream, "<TableOfContents/>\n" );
    
    AppendTo( filestream, "<Body>\n" );
    
    AppendTo( filestream, "<Index>&", package_name, ";</Index>\n" );

    if IsBound( opt.includes ) then
        
        for i in opt.includes do
            
            AppendTo( filestream, "<#Include SYSTEM \"", i, "\">\n" );
            
        od;
        
    else
        
        # TODO: Move "AutoDocMainFile.xml" to a global constant, and/or make it customizable?
        # It is also referenced in CreateAutomaticDocumentation()

        AppendTo( filestream, "<#Include SYSTEM \"AutoDocMainFile.xml\">\n" );
        
    fi;
    
    AppendTo( filestream, "</Body>\n" );

    if IsBound( opt.appendix ) then
        
        for i in opt.appendix do
            
            AppendTo( filestream, "<#Include SYSTEM \"", i, "\">\n" );
            
        od;
        
    fi;
    
    if IsBound( opt.bib ) then
        
        AppendTo( filestream, "<Bibliography Databases=\"", opt.bib, "\"/>\n" );

    fi;
    
    AppendTo( filestream, "<TheIndex/>\n" );

    AppendTo( filestream, "</Book>\n" );
    
    CloseStream( filestream );
    
    return true;
    
end );

##
## Gets three strings. Initialises everything.
#
# Note: the optional arguments name_documentation_file, create_full_docu and
# entities are intentionally undocumented and are only here for backward
# compatibility. We should remove them completely at some point.
InstallGlobalFunction( CreateAutomaticDocumentation,

  function( arg )
    local package_name, path_to_xmlfiles, create_full_docu, introduction_list, entities, 
          dependencies, intro, chapter_record, section_stream, intro_string, group_names, current_group, files_to_scan, i,
          default_chapter_record, tree;
    
    files_to_scan := ValueOption( "files_to_scan" );
    
    if files_to_scan = fail then
        
        files_to_scan := [ ];
        
    fi;
    
    package_name := arg[ 1 ];
    
    if Length( arg ) >= 3 and IsString( arg[ 2 ] ) and IsString( arg[ 3 ] ) then

        Remove( arg, 2 ); # former name_documentation_file, ignore
    
    fi;

    path_to_xmlfiles := arg[ 2 ];

    if IsString( path_to_xmlfiles ) then
        path_to_xmlfiles := Directory( path_to_xmlfiles );
    fi;
    
    if Length( arg ) >= 3 and IsBool( arg[ 3 ] ) then
        create_full_docu := Remove( arg, 3 );
    else
        create_full_docu := false;
    fi;
    
    default_chapter_record := CreateDefaultChapterData( package_name );
    
    AUTOMATIC_DOCUMENTATION.path_to_xmlfiles := path_to_xmlfiles;
    
    AUTOMATIC_DOCUMENTATION.package_name := package_name;
    
    ## Initialising the filestreams.
    AUTOMATIC_DOCUMENTATION.enable_documentation := true;
    
    if Length( arg ) = 3 then
        
        if Length( arg[ 3 ] ) > 0 then
            
            if IsString( arg[ 3 ][ 1 ] ) then
                
                entities := arg[ 3 ];
                
            elif IsList( arg[ 3 ][ 1 ] ) then
                
                introduction_list := arg[ 3 ];
                
            fi;
            
        fi;
        
    elif Length( arg ) = 4 then
        
        introduction_list := arg[ 3 ];
        
        entities := arg[ 4 ];
        
    fi;
    
    if create_full_docu then
        
        CreateTitlePage( package_name, path_to_xmlfiles );
        
        if IsBound( entities ) then
            
            CreateMainPage( package_name, path_to_xmlfiles, entities );
            
        else
            
            CreateMainPage( package_name, path_to_xmlfiles );
            
        fi;
        
    fi;
    
    AUTOMATIC_DOCUMENTATION.tree := DocumentationTree( );
    
    tree := AUTOMATIC_DOCUMENTATION.tree;
    
    if IsBound( introduction_list ) then
      
        for intro in introduction_list do
            
            if Length( intro ) = 2 then
                
                intro_string := intro[ 2 ];
                
                Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationText( intro_string, [ ReplacedString( intro[ 1 ], " ", "_" ) ] ) );
                
            elif Length( intro ) = 3 then
                
                intro_string := intro[ 3 ];
                
                Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationText( intro_string, [ ReplacedString( intro[ 1 ], " ", "_" ), ReplacedString( intro[ 2 ], " ", "_" ) ] ) );
                
            else
                
                Error( "wrong format of introduction string list\n" );
                
            fi;
        
        od;
        
    fi;
    
    if LowercaseString( package_name ) = "autodoc" then
        
        ReadPackage( "AutoDoc", "gap/AutoDocDocEntries.g" );
        
    else
        
        LoadPackage( package_name );
        
    fi;
    
    ##Use parser now.
    AutoDoc_Parser_ReadFiles( files_to_scan, AUTOMATIC_DOCUMENTATION.tree, default_chapter_record );
    
    WriteDocumentation( tree, path_to_xmlfiles );
    
    return true;

end );

##
InstallGlobalFunction( SetCurrentAutoDocChapter,
                       
  function( chapter_name )
    
    if not ( AUTOMATIC_DOCUMENTATION.enable_documentation and AUTOMATIC_DOCUMENTATION.package_name = CURRENT_NAMESPACE() ) then
        
        return;
        
    fi;
    
    if not IsString( chapter_name ) then
        
        Error( "Argument must be a string" );
        
    fi;
    
    AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name := ReplacedString( chapter_name, " ", "_" );
    
end );

##
InstallGlobalFunction( ResetCurrentAutoDocChapter,
                       
  function( )
    
    Unbind( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name );
    
    Unbind( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name );
    
end );

##
InstallGlobalFunction( SetCurrentAutoDocSection,
                       
  function( section_name )
    
    if not ( AUTOMATIC_DOCUMENTATION.enable_documentation and AUTOMATIC_DOCUMENTATION.package_name = CURRENT_NAMESPACE() ) then
        
        return;
        
    fi;
    
    if not IsString( section_name ) then
        
        Error( "Argument must be a string" );
        
    fi;
    
    AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name := ReplacedString( section_name, " ", "_" );
    
end );

##
InstallGlobalFunction( ResetCurrentAutoDocSection,
                       
  function( )
    
    Unbind( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name );
    
end );

##
InstallGlobalFunction( WriteStringIntoDoc,
                       
  function( arg )
    local chapter_info, description, filestream;
    
    if not ( AUTOMATIC_DOCUMENTATION.enable_documentation and AUTOMATIC_DOCUMENTATION.package_name = CURRENT_NAMESPACE() ) then
        
        return;
        
    fi;
    
    description := arg[ 1 ];
    
    if IsString( description ) then
        
        description := [ description ];
        
    fi;
    
    if not IsList( description ) then
        
        Error( "Wrong input" );
        
    fi;
    
    chapter_info := ValueOption( "chapter_info" );
    
    if chapter_info = fail then
        
        if IsBound( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name ) then
            
            chapter_info := [ AUTOMATIC_DOCUMENTATION.default_chapter.current_default_chapter_name ];
            
            if IsBound( AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name ) then
                
                Add( chapter_info, AUTOMATIC_DOCUMENTATION.default_chapter.current_default_section_name );
                
            fi;
            
        else
            
            Error( "no default chapter set" );
            
        fi;
        
    fi;
    
    chapter_info := List( chapter_info, i -> ReplacedString( i, " ", "_" ) );
    
    Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationText( description, chapter_info ) );
    
end );

##
InstallGlobalFunction( AutoDocWorksheet,
                       
  function( filelist )
    local folder, filename, folder_length, filestream, plain_filename, title, author, output_folder, testfile,
          book_name, maketest_commands, commands, bibfile, bib_tmp, tree, write_title_page, table_of_contents, i,
          testfile_output_folder, current_directory_set, entity_list;
    
    write_title_page := false;
    
    if IsString( filelist ) then
        
        filelist := [ filelist ];
        
    fi;
    
    output_folder := ValueOption( "OutputFolder" );
    
    if output_folder = fail then
        
        filename := filelist[ 1 ];
        
        output_folder := StructuralCopy( filename );
        
        while output_folder[ Length( output_folder ) ] <> '/' do
            
            Remove( output_folder, Length( output_folder ) );
            
        od;
        
        folder_length := Length( output_folder );
        
    fi;
    
    output_folder := Directory( output_folder );
    
    tree := DocumentationTree();
    
    ## No default names here.
    AutoDoc_Parser_ReadFiles( filelist, tree, rec( ) );
    
    if IsBound( tree!.worksheet_dependencies ) then
        
        for i in tree!.worksheet_dependencies do
            
            if CallFuncList( TestPackageAvailability, Concatenation( i, [ true ] ) ) = fail then
                
                Error( Concatenation( "Package ", i[ 1 ], " is not loadable" ) );
                
            fi;
            
        od;
        
    fi;
    
    if IsBound( tree!.worksheet_title ) then
        
        title := tree!.worksheet_title;
        
    else
        
        title := fail;
        
    fi;
    
    if IsBound( tree!.worksheet_author ) then
        
        author := tree!.worksheet_author;
        
    else
        
        author := fail;
        
    fi;
    
    book_name := ValueOption( "BookName" );
    
    if book_name = fail then
        
        if title = fail then
            
            book_name := filename{[ folder_length + 1 .. Length( filename ) ]};
            
        else
            
            book_name := ReplacedString( title, " ", "_" );
            
        fi;
        
    fi;
    
    if title = fail then
        
        if book_name = fail then
            
            title := filename{[ folder_length + 1 .. Length( filename ) ]};
            
        else
            
            title := book_name;
            
        fi;
        
    fi;
    
    WriteDocumentation( tree, output_folder );
    
    filestream := AUTODOC_OutputTextFile( output_folder, Concatenation( book_name, ".xml" ) );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );
    
    AppendTo( filestream, "<!ENTITY ", book_name, " '<Package>", book_name, "</Package>'>\n" );
    
    entity_list := ValueOption( "EntityList" );
    
    if IsString( entity_list ) then
        
        entity_list := [ entity_list ];
        
    fi;
    
    if IsList( entity_list ) then
        
        for i in entity_list do
            
            AppendTo( filestream, i, "\n" );
            
        od;
        
    fi;
    
    AppendTo( filestream, "]\n>\n" );
    
    AppendTo( filestream, "<Book Name=\"", book_name, "\">\n" );
    
    AppendTo( filestream, "<TitlePage>\n" );
    
    if title <> fail then
        
        AppendTo( filestream, "<Title>", title, "</Title>\n" );
        
    fi;
    
    if author <> fail then
        
        for i in author do
            
            AppendTo( filestream, "<Author>", i, "</Author>\n" );
            
        od;
        
    fi;
    
    if IsBound( tree!.worksheet_date ) then
        
        AppendTo( filestream, "<Date>", tree!.worksheet_date, "</Date>" );
        
    fi;
    
    if IsBound( tree!.acknowledgements ) then
        
        AppendTo( filestream, "<Acknowledgements>\n" );
        
        for i in tree!.acknowledgements do
            
            AppendTo( filestream, i, "\n" );
            
        od;
        
        AppendTo( filestream, "</Acknowledgements>\n" );
        
    fi;
    
    AppendTo( filestream, "</TitlePage>" );
    
    table_of_contents := ValueOption( "TableOfContents" );
    
    if table_of_contents = true then
        
        AppendTo( filestream, "<TableOfContents/>\n" );
        
    fi;
    
    AppendTo( filestream, "<Body>\n" );
    
    AppendTo( filestream, "<#Include SYSTEM \"AutoDocMainFile.xml\">\n" );
    
    AppendTo( filestream, "</Body>\n" );
    
    bibfile := ValueOption( "Bibliography" );
    
    if bibfile <> fail then
        
        AppendTo( filestream, "<Bibliography Databases=\"", bibfile, "\"/>\n" );
        
    fi;
    
    if ValueOption( "CreateIndex" ) <> fail then
        
        AppendTo( filestream, "<TheIndex/>\n" );
        
    fi;
    
    AppendTo( filestream, "</Book>\n" );
    
    CloseStream( filestream );
    
    SetGapDocLaTeXOptions( "utf8" );
    
    MakeGAPDocDoc( output_folder, book_name, [ ], book_name, "MathJax" );
    
    CopyHTMLStyleFiles( Filename( output_folder, "" ) );
    
    testfile := ValueOption( "TestFile" );
    
    maketest_commands := ValueOption( "TestFileCommands" );
    
    if IsString( maketest_commands ) then
        
        maketest_commands := [ maketest_commands ];
        
    fi;
    
    current_directory_set := false;
    
    if testfile <> false then
        
        if testfile = fail then
            
            testfile := "maketest.g";
            
        fi;
        
        testfile_output_folder := ValueOption( "TestFileOutputFolder" );
        
        if testfile_output_folder = fail then
            
            testfile_output_folder := output_folder;
            
        elif IsString( testfile_output_folder ) and LowercaseString( testfile_output_folder ) = "current" then
            
            testfile_output_folder := DirectoryCurrent( );
            
            current_directory_set := true;
            
        elif IsString( testfile_output_folder ) then
            
            testfile_output_folder := Directory( testfile_output_folder );
            
            current_directory_set := true;
            
        else
            
            Error( "TestFileOutputFolder must be \"current\" or directory" );
            
        fi;
        
        filestream := AUTODOC_OutputTextFile( testfile_output_folder, testfile );
        
        if maketest_commands <> fail then
            
            for commands in maketest_commands do
                
                AppendTo( filestream, commands );
                
                AppendTo( filestream, "\n\n" );
                
            od;
            
        fi;
        
        AppendTo( filestream, "LoadPackage( \"GAPDoc\" );\n\n" );
        
        if current_directory_set = true then
            
            AppendTo( filestream, "example_tree := ExtractExamples( ", output_folder, ", \"", Concatenation( book_name, ".xml" ),"\", [ ], 500 );\n\n" );
            
        else
            
            AppendTo( filestream, "example_tree := ExtractExamples( Directory( \".\" ), \"", Concatenation( book_name, ".xml" ),"\", [ ], 500 );\n\n" );
            
        fi;
        
        AppendTo( filestream, "RunExamples( example_tree, rec( compareFunction := \"uptowhitespace\" ) );\n\n" );
        
        AppendTo( filestream, "QUIT;\n" );
        
    fi;
    
    return true;
    
end );

