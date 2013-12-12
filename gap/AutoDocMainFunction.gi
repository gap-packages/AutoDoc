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

InstallGlobalFunction( AUTODOC_WriteOnce,
            
  function( record, name, val )
    
    if not IsBound( record.(name) ) then
        
        record.(name) := val;
        
    fi;
    
end );

##
InstallGlobalFunction( AUTODOC_APPEND_STRING_ITERATIVE,
                       
  function( arg )
    local string, i;
    
    string := arg[ 1 ];
    
    for i in [ 2 .. Length( arg ) ] do
        
        Append( string, arg[ i ] );
        
    od;
    
    Append( string, "\n" );
    
end );

##
InstallGlobalFunction( AUTODOC_APPEND_RECORD_WRITEONCE,
                       
  function( rec_1, rec_2 )
    local names_list, i;
    
    names_list := RecNames( rec_2 );
    
    for i in names_list do
        
        if not IsBound( rec_1.( i ) ) then
            
            rec_1.( i ) := rec_2.( i );
            
        fi;
        
    od;
    
end );

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
        
        if IsString( i ) then
            
            i := [ "Package", i ];
            
        fi;
        
        AppendTo( filestream, "<!ENTITY ", i[ 2 ], " '<", i[ 1 ], ">", i[ 2 ], "</", i[ 1 ], ">'>\n" );
        
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
InstallGlobalFunction( ExtractTitleInfoFromPackageInfo,
                       
  function( package_name )
    local package_info, title_rec, author_list, i, tmp_list, j, author_rec, author_string;
    
    package_info := PackageInfo( package_name )[ 1 ];
    
    if IsBound( package_info.AutoDoc ) then
        
        title_rec := package_info.AutoDoc.TitlePage;
        
    else
        
        title_rec := rec( );
        
    fi;
    
    AUTODOC_WriteOnce( title_rec, "Title", package_name );
    
    AUTODOC_WriteOnce( title_rec, "Subtitle", ReplacedString( package_info.Subtitle, "GAP", "&GAP;" ) );
    
    AUTODOC_WriteOnce( title_rec, "Version", package_info.Version );
    
    ## Sanitize author info
    
    if not IsBound( title_rec.Author ) then
        
        author_list := [ ];
        
        i := 1;
        
        for author_rec in package_info.Persons do
            
            author_string := "";
            
            AUTODOC_APPEND_STRING_ITERATIVE( author_string, author_rec.FirstNames, " ", author_rec.LastName, "<Alt Only=\"LaTeX\"><Br/></Alt>" );
            
            tmp_list := SplitString( author_rec.PostalAddress, "\n" );
            
            AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Address>" );
            
            for j in tmp_list do
                
                AUTODOC_APPEND_STRING_ITERATIVE( author_string, j, "<Br/>" );
                
            od;
            
            AUTODOC_APPEND_STRING_ITERATIVE( author_string, "</Address>" );
            
            AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Email>", author_rec.Email, "</Email>" );
            
            AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Homepage>", author_rec.WWWHome, "</Homepage>" );
            
            author_list[ i ] := author_string;
            
            i := i + 1;
            
        od;
        
        title_rec.Author := author_list;
        
    fi;
    
    AUTODOC_WriteOnce( title_rec, "Date", package_info.Date );
    
    return title_rec;
    
end );

##
## This creates a titlepage out of an argument record.
## Please make sure that every entry in the record
## has the name of its tag, even title etc.
## Please note that entities will be treatened
## seperately.
InstallGlobalFunction( CreateTitlePage,
                       
  function( argument_rec )
    local indent, tag, names, filestream, dir, entity_list, OutWithTag, Out, i;
    
    if not IsBound( argument_rec.dir ) then
        
        Error( "directory must be given" );
        
    fi;
    
    dir := argument_rec.dir;
    
    Unbind( argument_rec.dir );
    
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
        if not IsList( content ) then
            Error( "can only print string or list of strings" );
        fi;
        
        if IsString( content ) then
            
            content := [ content ];
            
        fi;
        
        s := ListWithIdenticalEntries( indent * 2, ' ');
        
        AppendTo( filestream, s, "<", tag, ">\n" );
        for l in content do
            AppendTo( filestream, s, "  ", l, "\n" );
        od;
        AppendTo( filestream, s, "</", tag, ">\n" );
        
    end;
    
    Out( AUTODOC_XML_HEADER );
    
    Out( "<TitlePage>\n" );
    
    indent := indent + 1;
    
    for i in [ "Title", "Subtitle", "Version", "TitleComment" ] do
        
        if IsBound( argument_rec.( i ) ) then
            
            OutWithTag( i, argument_rec.( i ) );
            
        fi;
        
    od;
    
    if IsBound( argument_rec.Author ) then
        
        for i in argument_rec.Author do
            
            OutWithTag( "Author", i );
            
        od;
        
    fi;
    
    for i in [ "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ] do
        
        if IsBound( argument_rec.( i ) ) then
            
            OutWithTag( i, argument_rec.( i ) );
            
        fi;
        
    od;
    
    Out( "</TitlePage>" );
    
end );

InstallGlobalFunction( AUTODOC_PROCESS_INTRO_STRINGS,
                       
  function( introduction_list )
    local tree, intro, intro_string, i;
    
    tree := ValueOption( "Tree" );
    
    if tree = fail then
        
        tree := DocumentationTree( );
        
    fi;
    
    for intro in introduction_list do
        
        if Length( intro ) = 2 then
            
            intro_string := intro[ 2 ];
            
            if IsString( intro_string ) then
                
                intro_string := [ intro_string ];
                
            fi;
            
            for i in intro_string do
                
                Add( ChapterInTree( tree, ReplacedString( intro[ 1 ], " ", "_" ) ), i );
                
            od;
            
        elif Length( intro ) = 3 then
            
            intro_string := intro[ 3 ];
            
            if IsString( intro_string ) then
                
                intro_string := [ intro_string ];
                
            fi;
            
            for i in intro_string do
                
                Add( SectionInTree( tree, ReplacedString( intro[ 1 ], " ", "_" ), ReplacedString( intro[ 2 ], " ", "_" ) ), i );
                
            od;
            
        else
            
            Error( "wrong format of introduction string list\n" );
            
        fi;
        
    od;
    
    return tree;
    
end );


#
# Note: the optional arguments name_documentation_file, create_full_docu and
# entities are intentionally undocumented and are only here for backward
# compatibility. We should remove them completely at some point.
InstallGlobalFunction( CreateAutomaticDocumentation,

  function( arg_rec )
    local path_to_xmlfiles, tree;

    path_to_xmlfiles := arg_rec.path_to_xmlfiles;

    if IsString( path_to_xmlfiles ) then
        path_to_xmlfiles := Directory( path_to_xmlfiles );
    fi;
    
    tree := arg_rec.tree;
    
    WriteDocumentation( tree, path_to_xmlfiles );
    
    return true;

end );

##
## Optional argument is PackageName, which creates a 
## Default chapter record. This is not availible for
## worksheets.
InstallGlobalFunction( AutoDocScanFiles,
                       
  function( files_to_scan )
    local package_name, default_chapter_record, tree;
    
    package_name := ValueOption( "PackageName" );
    
    if IsString( package_name ) then
        
        default_chapter_record := CreateDefaultChapterData( package_name );
        
    else
        
        default_chapter_record := rec( );
        
    fi;
    
    tree := ValueOption( "Tree" );
    
    if tree = fail then
        
        tree := DocumentationTree( );
        
    fi;
    
    AutoDoc_Parser_ReadFiles( files_to_scan, tree, default_chapter_record );
    
    return tree;
    
end );

##
InstallGlobalFunction( AutoDocWorksheet,
                       
  function( filelist )
    local folder, filename, folder_length, filestream, plain_filename, title, author, output_folder, testfile,
          book_name, maketest_commands, commands, bibfile, bib_tmp, tree, table_of_contents, i,
          testfile_output_folder, current_directory_set, entity_list, maketest_record, testfile_name;
    
    scaffold := ValueOption( "scaffold" );
    
    if scaffold = fail then
        
        scaffold := rec( TitlePage := rec( ) );
        
    fi;
    
    if not IsBound( scaffold.TitlePage ) then
        
        scaffold.TitlePage := rec( );
        
    fi;
    
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
    
    tree := AutoDocScanFiles( filelist );
    
    if IsBound( tree!.worksheet_dependencies ) then
        
        for i in tree!.worksheet_dependencies do
            
            if CallFuncList( TestPackageAvailability, Concatenation( i, [ true ] ) ) = fail then
                
                Error( Concatenation( "Package ", i[ 1 ], " is not loadable" ) );
                
            fi;
            
        od;
        
    fi;
    
    TitlePage := scaffold.TitlePage;
    
    AUTODOC_APPEND_RECORD_WRITEONCE( TitlePage, tree!.TitlePage );
    
    book_name := ValueOption( "BookName" );

    TitlePage := scaffold.TitlePage;
    
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
            
            if IsString( i ) then
                
                i := [ "Package", i ];
                
            fi;
            
            AppendTo( filestream, "<!ENTITY ", i[ 2 ], " '<", i[ 1 ], ">", i[ 2 ], "</", i[ 1 ], ">'>\n" );
            
        od;
        
    fi;
    
    AppendTo( filestream, "]\n>\n" );
    
    AppendTo( filestream, "<Book Name=\"", book_name, "\">\n" );
    
    AppendTo( filestream, "<#Include SYSTEM \"Title.xml\">\n" );
    
    TitlePage.dir := output_folder;
    
    CreateTitlePage( TitlePage );
    
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
    
    if IsString( maketest_commands ) then
        
        maketest_commands := [ maketest_commands ];
        
    fi;
    
    current_directory_set := false;
    
    if testfile <> false then
        
        if IsString( testfile ) then
            
            testfile_name := testfile;
            
            testfile := rec( );
            
        elif IsBool( testfile ) then
            
            testfile := rec( );
            
            testfile_name := "maketest.g";
            
        fi;
        
        AUTODOC_WriteOnce( testfile, "name", testfile_name );
        
        testfile_output_folder := ValueOption( "TestFileOutputFolder" );
        
        if testfile_output_folder = fail then
            
            testfile_output_folder := output_folder;
            
        elif IsString( testfile_output_folder ) and LowercaseString( testfile_output_folder ) = "current" then
            
            testfile_output_folder := DirectoryCurrent( );
            
            current_directory_set := true;
            
        elif IsString( testfile_output_folder ) then
            
            testfile_output_folder := Directory( testfile_output_folder );
            
        else
            
            Error( "TestFileOutputFolder must be \"current\" or directory" );
            
        fi;
        
        AUTODOC_WriteOnce( testfile, "folder", testfile_output_folder );
        
        if IsString( testfile.folder ) then
            
            testfile.folder := Directory( testfile.folder );
            
        fi;
        
        AUTODOC_WriteOnce( testfile, "commands", maketest_commands );
        
        if current_directory_set then
            
            AUTODOC_WriteOnce( testfile, "scan_dir", Directory( "." ) );
            
        fi;
        
        AUTODOC_WriteOnce( testfile, "scan_dir", output_folder );
        
        AUTODOC_WriteOnce( testfile, "book_name", book_name );
        
        CreateMakeTest( testfile );
        
    fi;
    
    return true;
    
end );

InstallGlobalFunction( CreateMakeTest,
                       
  function( argument_rec )
    local filename, folder, filestream, i, scan_dir, book_name, scan_list;
    
    if IsBound( argument_rec.files_to_scan ) then
        
        scan_list := argument_rec.files_to_scan;
        
    else
        
        scan_list := [ ];
        
    fi;
    
    if IsBound( argument_rec.name ) then
        
        filename := argument_rec.name;
        
    else
        
        filename := "maketest.g";
        
    fi;
    
    if IsBound( argument_rec.folder ) then
        
        folder := argument_rec.folder;
        
    else
        
        folder := Directory( "." );
        
    fi;
    
    filestream := AUTODOC_OutputTextFile( folder, filename );
    
    if IsBound( argument_rec.commands ) and IsList( argument_rec.commands ) then
        
        if IsString( argument_rec.commands ) and argument_rec.commands <> [ ] then
            
            argument_rec.commands := [ argument_rec.commands ];
            
        fi;
        
        for i in argument_rec.commands do
            
            AppendTo( filestream, i );
            
            AppendTo( filestream, "\n\n" );
            
        od;
        
    fi;
    
    AppendTo( filestream, "AUTODOC_file_scan_list := ", scan_list, ";\n\n" );
    
    AppendTo( filestream, "LoadPackage( \"GAPDoc\" );\n\n" );
    
    if IsBound( argument_rec.scan_dir ) then
        
        scan_dir := argument_rec.scan_dir;
        
    else
        
        scan_dir := ".";
        
    fi;
    
    if IsBound( argument_rec.book_name ) then
        
        book_name := argument_rec.book_name;
        
    else
        
        Error( "No book name given to extract the examples." );
        
    fi;
    
    AppendTo( filestream, "example_tree := ExtractExamples( ", scan_dir, ", \"", Concatenation( book_name, ".xml" ),"\", AUTODOC_file_scan_list, 500 );\n\n" );
    
    AppendTo( filestream, "RunExamples( example_tree, rec( compareFunction := \"uptowhitespace\" ) );\n\n" );
    
    AppendTo( filestream, "QUIT;\n" );
    
    CloseStream( filestream );
    
end );

