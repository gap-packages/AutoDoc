# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

##
InstallValue( AUTODOC_XML_HEADER,
    Concatenation(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n",
    "<!-- This is an automatically generated file. -->\n"
    )
);

InstallValue( _AUTODOC_GLOBAL_OPTION_RECORD,
              rec( AutoDocMainFile := "_AutoDocMainFile.xml" ) );


InstallGlobalFunction( AUTODOC_SetIfMissing,
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
## Given two records, this adds all key/values pairs of the
## second record to the first record, unless the first record already
## has an entry for that key.
InstallGlobalFunction( AUTODOC_MergeRecords,
  function( dst, src )
    local key;
    for key in RecNames( src ) do
        AUTODOC_SetIfMissing( dst, key, src.( key ) );
    od;
end );

##
InstallGlobalFunction( CreateDefaultChapterData,
  function( pkgname )
    local chapter_name, default_chapter_record, list_of_types, i;

    if not IsString( pkgname ) then
        Error( "CreateDefaultChapterData must be called with a possible package name\n" );
    fi;

    chapter_name := Concatenation( pkgname, "_automatic_generated_documentation" );
    default_chapter_record := rec();
    list_of_types := [ "categories", "methods", "attributes", "properties",
                       "global_functions", "global_variables", "info_classes" ];

    for i in list_of_types do
        default_chapter_record.(i) := [ chapter_name, Concatenation( chapter_name, "_of_", i ) ];
    od;

    return default_chapter_record;
end );

##
InstallGlobalFunction( CreateMainPage,
  function( book_name, dir, opt )
    local filestream, i, ent, val, entities;

    if IsString(dir) then
        dir := Directory(dir);
    fi;

    if not IsBound( opt.entities ) then
        entities := rec();
    elif IsList( opt.entities ) then
        entities := rec();
        for i in opt.entities do
            if IsString( i ) then
                ent := i;
                val := Concatenation("<Package>", ent, "</Package>");
            else
                ent := i[2];
                val := Concatenation("<", i[1], ">", ent, "</", i[1], ">");
            fi;
            entities.(ent) := val;
        od;
    elif IsRecord( opt.entities ) then
        entities := opt.entities;
    else
        Error("CreateMainPage: <opt.entities> must be a list or a record");
    fi;

    # add book_name unconditionally to the list of entities
    if not IsBound(entities.(book_name)) then
        entities.(book_name) := Concatenation( "<Package>", book_name, "</Package>" );
    fi;

    # for backwards compatibility: add &see; entity
    if not IsBound(entities.see) then
        entities.see := """<Alt Only="LaTeX">$\to$</Alt><Alt Not="LaTeX">--&gt;</Alt>""";
    fi;

    # open the target XML file
    filestream := AUTODOC_OutputTextFile( dir, opt.main_xml_file );

    # output the initial file header
    AppendTo( filestream, AUTODOC_XML_HEADER );
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );

    # output all entities
    for ent in RecNames(entities) do
        val := String(entities.(ent));

        # escape single quotes, if any
        val := ReplacedString( val, "'", "\\\'" );
        # convert spaces in entity name to underscores
        ent := ReplacedString( ent, " ", "_" );

        AppendTo( filestream, "<!ENTITY ", ent, " '", val, "'>\n" );
    od;
    AppendTo( filestream, "]\n>\n" );

    # now start the actual book
    AppendTo( filestream, "<Book Name=\"", ReplacedString( book_name, " ", "_" ), "\">\n" );
    AppendTo( filestream, "<#Include SYSTEM \"title.xml\">\n" );
    if not IsBound( opt.table_of_contents ) or opt.table_of_contents <> false then
        AppendTo( filestream, "<TableOfContents/>\n" );
    fi;
    AppendTo( filestream, "<Body>\n" );

    if IsBound( opt.includes ) then
        for i in opt.includes do
            AppendTo( filestream, "<#Include SYSTEM \"", i, "\">\n" );
        od;
    else
        AppendTo( filestream, "<#Include SYSTEM \"", _AUTODOC_GLOBAL_OPTION_RECORD.AutoDocMainFile, "\">\n" );
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
InstallGlobalFunction( ExtractTitleInfoFromPackageInfo,
  function( pkginfo )
    local title_rec, i, tmp_list, j, author_rec, author_string;

    if IsBound( pkginfo.AutoDoc ) then
        title_rec := ShallowCopy( pkginfo.AutoDoc.TitlePage );
    else
        title_rec := rec( );
    fi;

    AUTODOC_SetIfMissing( title_rec, "Title", pkginfo.PackageName );
    AUTODOC_SetIfMissing( title_rec, "Subtitle", ReplacedString( pkginfo.Subtitle, "GAP", "&GAP;" ) );
    AUTODOC_SetIfMissing( title_rec, "Version", pkginfo.Version );

    ## Sanitize author info
    if not IsBound( title_rec.Author ) then
        title_rec.Author := [ ];
        i := 1;
        for author_rec in pkginfo.Persons do
            if not author_rec.IsAuthor then
                continue;
            fi;
            author_string := "";
            AUTODOC_APPEND_STRING_ITERATIVE( author_string,
                    author_rec.FirstNames, " ", author_rec.LastName,
                    "<Alt Only=\"LaTeX\"><Br/></Alt>" );
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
            title_rec.Author[ i ] := author_string;
            i := i + 1;
        od;
    fi;
    AUTODOC_SetIfMissing( title_rec, "Date", pkginfo.Date );
    return title_rec;
end );

##
## This creates a titlepage out of an argument record.
## Please make sure that every entry in the record
## has the name of its tag, even title etc.
## Please note that entities will be treated
## separately.
InstallGlobalFunction( CreateTitlePage,
  function( dir, argument_rec )
    local indent, tag, names, filestream, entity_list, OutWithTag, Out, i;

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

    if IsBound( argument_rec.Date ) then
        # try to parse the date in format DD/MM/YYYY (we also accept single
        # digit day or month, which is formally not allowed in PackageInfo.g,
        # but happens in a few legacy packages)
        argument_rec.Date := Chomp( argument_rec.Date ); # remove trailing newlines, if present
        i := SplitString( argument_rec.Date, "/" );
        if Length( argument_rec.Date ) in [8..10] and Length( i ) = 3 then
            i := List(i, Int);
            OutWithTag( "Date", AUTODOC_FormatDate(i[3], i[2], i[1]) );
        else
            # try to parse the date in ISO8601 format YYYY-MM-DD (here we are strict)
            i := SplitString( argument_rec.Date, "-" );
            if Length( argument_rec.Date ) = 10 and Length( i ) = 3 then
                i := List(i, Int);
                OutWithTag( "Date", AUTODOC_FormatDate(i[1], i[2], i[3]) );
            else
                Print("Warning: could not parse package date '", argument_rec.Date, "'\n");
                OutWithTag( "Date", argument_rec.Date );
            fi;
        fi;
    fi;

    for i in [ "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ] do
        if IsBound( argument_rec.( i ) ) then
            OutWithTag( i, argument_rec.( i ) );
        fi;
    od;

    Out( "</TitlePage>" );
end );

InstallGlobalFunction( AUTODOC_PROCESS_INTRO_STRINGS,
  function( introduction_list, tree )
    local intro, intro_string, i;

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
                Add( SectionInTree( tree, ReplacedString( intro[ 1 ], " ", "_" ),
                                          ReplacedString( intro[ 2 ], " ", "_" ) ), i );
            od;
        else
            Error( "wrong format of introduction string list\n" );
        fi;
    od;

    return tree;
end );

##
## Optional argument is PackageName, which creates a
## Default chapter record. This is not available for
## worksheets.
InstallGlobalFunction( AutoDocScanFiles,
  function( files_to_scan, pkgname, tree )
    local default_chapter_record;

    default_chapter_record := CreateDefaultChapterData( pkgname );
    AutoDoc_Parser_ReadFiles( files_to_scan, tree, default_chapter_record );
    return tree;
end );

##
InstallGlobalFunction( AutoDocWorksheet,
  function( arg )
    local autodoc_rec, scaffold_rec;

    if Length( arg ) = 1 then
        arg[ 2 ] := rec( );
    fi;

    scaffold_rec := ValueOption( "scaffold" );
    if scaffold_rec = fail then
        scaffold_rec := rec( );
    fi;
    AUTODOC_SetIfMissing( scaffold_rec, "index", false );

    if Length( arg ) = 2 then
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
  function( pkgdir, doc_dir, main, files_to_scan, argument_rec )
    local filename, filestream, i;

    if IsBound( argument_rec.name ) then
        filename := argument_rec.name;
    else
        filename := "maketest.g";
    fi;

    filestream := AUTODOC_OutputTextFile( pkgdir, filename );

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

    AppendTo( filestream, "AUTODOC_file_scan_list := ", files_to_scan, ";\n\n" );
    AppendTo( filestream, "LoadPackage( \"GAPDoc\" );\n\n" );

    if not EndsWith(main, ".xml") then
        main := Concatenation( main, ".xml" );
    fi;

    AppendTo( filestream, "example_tree := ExtractExamples( ", doc_dir, ", ",
                          "\"", main, "\", ",
                          "AUTODOC_file_scan_list, 500 );\n\n" );
    AppendTo( filestream, "RunExamples( example_tree, rec( compareFunction := \"uptowhitespace\" ) );\n\n" );
    AppendTo( filestream, "QUIT;\n" );

    CloseStream( filestream );
end );

# The following function is based on code by Alexander Konovalov
BindGlobal("AUTODOC_ExtractMyManualExamples",
function( pkgname, pkgdir, docdir, main, files, opt )
    local tst, i, s, basename, name, output, ch, a, location, pos, comment,
      pkgdirString, absPkgdirString,
      nonempty_units_found, number_of_digits, lpkgname, tstdir;
    Print("Extracting manual examples for ", pkgname, " package ...\n" );

    lpkgname := LowercaseString(pkgname);
    lpkgname := ReplacedString(lpkgname, " ", "_");

    if not EndsWith(main, ".xml") then
        main := Concatenation( main, ".xml" );
    fi;
    tst:=ExtractExamples( docdir, main, files, opt.units );
    Print(Length(tst), " ", LowercaseString( opt.units ), "s detected\n");
    pkgdirString := Filename(pkgdir, "");
    absPkgdirString := AUTODOC_AbsolutePath(pkgdirString);

    # ensure the 'tst' directory exists
    tstdir := Filename(pkgdir, "tst");
    AUTODOC_CreateDirIfMissing(tstdir);
    tstdir := Directory(tstdir);

    # first delete all old extracted tests in case chapter numbering etc. changed
    for s in DirectoryContents(tstdir) do
        # check prefix and suffix...
        if StartsWith(s, lpkgname) and EndsWith(s, ".tst") then
            # ... and between them, there should be only digits...
            if ForAll(s{[1 + Length(lpkgname) .. Length(s) - 4]}, IsDigitChar) then
                RemoveFile(Filename(tstdir, s));
            fi;
        fi;
    od;

    #
    nonempty_units_found := 0;
    number_of_digits := Length( String( Length( tst ) ) );
    if number_of_digits = 1 then
        number_of_digits := 2;
    fi;
    for i in [ 1 .. Length(tst) ] do
        Print( opt.units, " ", i, " : \c" );
        if Length( tst[i] ) = 0 then
            Print("no examples \n" );
            continue;
        fi;
        nonempty_units_found := nonempty_units_found + 1;
        if opt.skip_empty_in_numbering then
            s := String( nonempty_units_found );
        else
            s := String( i );
        fi;
        # pad s to number_of_digits
        s := Concatenation( ListWithIdenticalEntries( number_of_digits - Length( s ), '0' ), s );
        basename := Concatenation( lpkgname, s, ".tst" );
        name := Filename( tstdir, basename );
        output := OutputTextFile( name, false ); # to empty the file first
        SetPrintFormattingStatus( output, false ); # to avoid line breaks
        ch := tst[i];
        AppendTo(output, "# ", pkgname, ", ", LowercaseString( opt.units ), " ", i, "\n");
        AppendTo(output,
"""#
# DO NOT EDIT THIS FILE - EDIT EXAMPLES IN THE SOURCE INSTEAD!
#
# This file has been generated by AutoDoc. It contains examples extracted from
# the package documentation. Each example is preceded by a comment which gives
# the name of a GAPDoc XML file and a line range from which the example were
# taken. Note that the XML file in turn may have been generated by AutoDoc
# from some other input.
#
""");
        AppendTo(output, "gap> START_TEST(\"", basename, "\");\n\n");
        for a in ch do
            location := a[2][1];
            if StartsWith(location, pkgdirString) then
                comment := location{[ Length(pkgdirString)+1 .. Length(location) ]};
            elif StartsWith(location, absPkgdirString) then
                comment := location{[ Length(absPkgdirString)+1 .. Length(location) ]};
            else
                pos := PositionSublist(location, LowercaseString(pkgname));
                if pos <> fail then
                    comment := location{[ pos+Length(pkgname)+1 .. Length(location) ]};
                else
                    pos := PositionSublist(location,"./");
                    if pos <> fail then
                        comment := location{[ pos+2 .. Length(location) ]};
                    else
                        Error("oops");
                    fi;
                fi;
            fi;
            AppendTo(output, "# ", comment, ":", a[2][2], "-", a[2][3]);
            if not StartsWith(a[1], "\n") then
                AppendTo(output, "\n");
            fi;
            if not EndsWith(a[1], "\n") then
                AppendTo(output, a[1], "\n\n");
            else
                AppendTo(output, a[1], "\n");
            fi;
        od;
        AppendTo(output, "#\n");
        AppendTo(output, "gap> STOP_TEST(\"", basename, "\", 1);\n");
        Print("extracted ", Length(ch), " examples\n");
    od;
end);
