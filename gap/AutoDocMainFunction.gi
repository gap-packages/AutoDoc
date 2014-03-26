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
    
    default_chapter_record := rec();
    
    list_of_types := [ "categories", "methods", "attributes", "properties", "global_functions", "global_variables" ];
    
    for i in list_of_types do
        
        default_chapter_record.(i) := [ chapter_name, Concatenation( chapter_name, "_of_", i ) ];
        
    od;
    
    return default_chapter_record;
    
end );

##
## Call this with the packagename. It creates a simple main file. Call it with package name and maybe a list of entities.
InstallGlobalFunction( CreateMainPage,
                       
  function( opt )
    local package_name, dir, filename, filestream, i, package_info, book_name;
    
    if not IsBound( opt.book_name ) then
        
        Error( "book name must be given" );
        
    fi;
    
    book_name := opt.book_name;
    
    dir := opt.dir;
    if IsString(dir) then
        dir := Directory(dir);
    fi;
    
    if not IsBound( opt.entities ) then
        
        opt.entities := [];
        
    fi;
    
    # TODO: and if we do that, then do not add package_name unconditionally to the list,
    # to allow the package author to define this entity slightly differently...
    Add( opt.entities, book_name );
    
    if IsBound( opt.main_xml_file ) then
        
        filename := opt.main_xml_file;
        
    else
        
        filename := Concatenation( book_name, ".xml" );
        
    fi;
    
    filestream := AUTODOC_OutputTextFile( dir, filename );
    
    AppendTo( filestream, AUTODOC_XML_HEADER );
    
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );
    
    AppendTo( filestream, "<!ENTITY see '<Alt Only=\"LaTeX\">$\to$</Alt><Alt Not=\"LaTeX\">--&gt;</Alt>'>\n" );
   
    for i in opt.entities do
        
        ## allow generic entities.
        
        if IsString( i ) and PositionSublist( i, "!ENTITY" ) <> fail then
                
                AppendTo( filestream, i );
                
                AppendTo( filestream, "\n" );
                
                continue;
            
        fi;
        
        if IsString( i ) then
            
            i := [ "Package", i ];
            
        fi;
        
        AppendTo( filestream, "<!ENTITY ", ReplacedString( i[ 2 ], " ", "_" ), " '<", i[ 1 ], ">", i[ 2 ], "</", i[ 1 ], ">'>\n" );
        
    od;
    
    AppendTo( filestream, "]\n>\n" );
    
    AppendTo( filestream, "<Book Name=\"", ReplacedString( book_name, " ", "_" ), "\">\n" );
    
    AppendTo( filestream, "<#Include SYSTEM \"title.xml\">\n" );
    
    if not IsBound( opt.table_of_contents ) or opt.table_of_contents <> false then
        
        AppendTo( filestream, "<TableOfContents/>\n" );
        
    fi;
    
    AppendTo( filestream, "<Body>\n" );
    
    if IsBound( opt.index ) and opt.index = true then
        # FIXME: Why is this here??
        AppendTo( filestream, "<Index>&", book_name, ";</Index>\n" );
        
    fi;

    if IsBound( opt.includes ) then
        
        for i in opt.includes do
            
            AppendTo( filestream, "<#Include SYSTEM \"", i, "\">\n" );
            
        od;
        
    else
        
        # TODO: Move "AutoDocMainFile.xml" to a global constant, and/or make it customizable?
        # It is also referenced in AutoDoc()

        AppendTo( filestream, "<#Include SYSTEM \"AutoDocMainFile.xml\">\n" );
        
    fi;
    
    AppendTo( filestream, "</Body>\n" );

    if IsBound( opt.appendix ) then
        
        for i in opt.appendix do
            
            AppendTo( filestream, "<#Include SYSTEM \"", i, "\">\n" );
            
        od;
        
    fi;
    
    if IsBound( opt.bib ) and opt.bib <> false then
        
        AppendTo( filestream, "<Bibliography Databases=\"", opt.bib, "\"/>\n" );

    fi;
    
    if IsBound( opt.index ) and opt.index = true then
        
        AppendTo( filestream, "<TheIndex/>\n" );
        
    fi;

    AppendTo( filestream, "</Book>\n" );
    
    CloseStream( filestream );
    
    return true;
    
end );

##
InstallGlobalFunction( ExtractMainInfoFromPackageInfo,
                       
  function( package_name )
    local package_info, return_record;
    
    package_info := PackageInfo( package_name )[ 1 ];
    
    if IsBound( package_info.AutoDoc ) then
        
        return_record := package_info.AutoDoc;
        
    else
        
        return_record := rec( );
        
    fi;
    
    return return_record;
    
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
            
            if IsBound( author_rec.PostalAddress ) then
                
                tmp_list := SplitString( author_rec.PostalAddress, "\n" );
                
                AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Address>" );
                
                for j in tmp_list do
                    
                    AUTODOC_APPEND_STRING_ITERATIVE( author_string, j, "<Br/>" );
                    
                od;
                
                AUTODOC_APPEND_STRING_ITERATIVE( author_string, "</Address>" );
                
            fi;
            
            if IsBound( author_rec.Email ) then
                
                AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Email>", author_rec.Email, "</Email>" );
                
            fi;
            
            if IsBound( author_rec.WWWHome ) then
                
                AUTODOC_APPEND_STRING_ITERATIVE( author_string, "<Homepage>", author_rec.WWWHome, "</Homepage>" );
                
            fi;
            
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
                       
  function( arg )
    local arg_list, autodoc_rec, scaffold_rec;
    
    if Length( arg ) = 1 then
        
        arg[ 2 ] := rec( );
        
    fi;
    
    scaffold_rec := ValueOption( "scaffold" );
    
    if scaffold_rec = fail then
        
        scaffold_rec := rec( );
        
    fi;
    
    AUTODOC_WriteOnce( scaffold_rec, "index", false );
    
    if Length( arg ) = 2 then
        
        arg_list := [ "AutoDocWorksheet", arg[ 2 ] ];
        
        autodoc_rec := ValueOption( "autodoc" );
        
        if autodoc_rec = fail then
            
            autodoc_rec := rec( );
            
        fi;
        
        if IsString( arg[ 1 ] ) then
            
            arg[ 1 ] := [ arg[ 1 ] ];
            
        fi;
        
        if IsBound( autodoc_rec.files ) then
            
            Append( autodoc_rec.files, arg[ 1 ] );
            
        else
            
            autodoc_rec.files := arg[ 1 ];
            
        fi;
        
        AutoDoc( "AutoDocWorksheet", arg[ 2 ] : autodoc := autodoc_rec, scaffold := scaffold_rec );
        
    fi;
    
    if Length( arg ) = 0 then
        
        AutoDoc( "AutoDocWorksheet" : scaffold := scaffold_rec );
        
    fi;
    
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
    
    AppendTo( filestream, "## This file is automatically generated by AutoDoc.\n" );
    
    AppendTo( filestream, "## Changes will be discarded by the next call of the AutoDoc method.\n\n\n" );
    
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

