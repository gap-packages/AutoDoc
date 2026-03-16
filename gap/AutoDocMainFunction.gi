# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

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
    list_of_types := Set(
        List(
            RecNames( AUTODOC_ITEM_TYPE_INFO ),
            n -> AUTODOC_ITEM_TYPE_INFO.( n ).chapter_bucket
        )
    );

    for i in list_of_types do
        default_chapter_record.(i) := [ chapter_name, Concatenation( chapter_name, "_of_", i ) ];
    od;

    return default_chapter_record;
end );

##
InstallGlobalFunction( CreateEntitiesPage,
    function( book_name, dir, opt )
    local filestream, ent, val, entities;

    if not IsBound( opt.entities ) then
        entities := rec();
    elif IsRecord( opt.entities ) then
        entities := opt.entities;
    else
        Error("CreateEntitiesPage: <opt.entities> must be a record");
    fi;

    # add book_name unconditionally to the list of entities
    if not IsBound(entities.(book_name)) then
        entities.(book_name) := Concatenation( "<Package>", book_name, "</Package>" );
    fi;

    # open the target XML file
    filestream := AUTODOC_OutputTextFile( dir, "_entities.xml" );

    # output all entities
    # (sort the key names to get stable order across all GAP versions)
    for ent in Set(RecNames(entities)) do
        val := String(entities.(ent));

        # escape single quotes, if any
        val := ReplacedString( val, "'", "\\\'" );
        # convert spaces in entity name to underscores
        ent := ReplacedString( ent, " ", "_" );

        AppendTo( filestream, "<!ENTITY ", ent, " '", val, "'>\n" );
    od;

    CloseStream( filestream );

end );

##
InstallGlobalFunction( CreateMainPage,
  function( book_name, dir, opt )
    local filestream, i;

    # open the target XML file
    filestream := AUTODOC_OutputTextFile( dir, opt.main_xml_file );

    # output the initial file header
    AppendTo( filestream, AUTODOC_XML_HEADER );
    AppendTo( filestream, "<!DOCTYPE Book SYSTEM \"gapdoc.dtd\"\n[\n" );
    AppendTo( filestream, "    <#Include SYSTEM \"_entities.xml\">\n");
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
    if IsBound( opt.autodoc_appendix_file ) and
       ( not IsBound( opt.appendix ) or not opt.autodoc_appendix_file in opt.appendix ) then
        AppendTo( filestream, "<#Include SYSTEM \"", opt.autodoc_appendix_file, "\">\n" );
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

    if IsBound( pkginfo.AutoDoc ) and IsBound( pkginfo.AutoDoc.TitlePage ) then
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
                    author_rec.FirstNames, " ", author_rec.LastName );
            if IsBound( author_rec.PostalAddress ) then
                tmp_list := SplitString( StripBeginEnd( author_rec.PostalAddress, "\n\r" ), "\n" );
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
    local indent, tag, names, filestream, entity_list, OutWithTag, Out, i,
          parsed_date, NormalizeTitlePageContent;

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

    # Parser state can leave title-page fields as a list of lines. Normalize
    # them here so trailing blank lines do not leak into output or filenames,
    # while still preserving intentional internal line breaks for multiline fields.
    NormalizeTitlePageContent := function( content )
        local normalized;

        if IsString( content ) then
            content := [ content ];
        fi;
        normalized := List( content, line -> StripBeginEnd( line, "\n\r" ) );
        while Length( normalized ) > 0 and
              IsString( normalized[ Length( normalized ) ] ) and
              StripBeginEnd( normalized[ Length( normalized ) ], " \t\r\n" ) = "" do
            Remove( normalized );
        od;
        if Length( normalized ) = 1 then
            return normalized[ 1 ];
        fi;
        return normalized;
    end;

    Out( AUTODOC_XML_HEADER );
    Out( "<TitlePage>\n" );
    indent := indent + 1;

    for i in [ "Title", "Subtitle", "Version", "TitleComment" ] do
        if IsBound( argument_rec.( i ) ) then
            OutWithTag( i, NormalizeTitlePageContent( argument_rec.( i ) ) );
        fi;
    od;

    if IsBound( argument_rec.Author ) then
        for i in List( argument_rec.Author, NormalizeTitlePageContent ) do
            if not IsString( i ) or StripBeginEnd( i, " \t\r\n" ) <> "" then
                OutWithTag( "Author", i );
            fi;
        od;
    fi;

    if IsBound( argument_rec.Date ) then
        if IsString( argument_rec.Date ) then
            argument_rec.Date := Chomp( argument_rec.Date ); # remove trailing newlines, if present

            # PackageInfo.g dates are normalized, but @Date should also allow
            # free-form text when the input is not one of the supported date formats.
            parsed_date := AUTODOC_ParseDate( argument_rec.Date );
            if parsed_date <> fail then
                argument_rec.Date := AUTODOC_FormatDate( parsed_date );
            fi;
        fi;
        OutWithTag( "Date", NormalizeTitlePageContent( argument_rec.Date ) );
    fi;

    for i in [ "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ] do
        if IsBound( argument_rec.( i ) ) then
            OutWithTag( i, NormalizeTitlePageContent( argument_rec.( i ) ) );
        fi;
    od;

    Out( "</TitlePage>" );
    
    CloseStream( filestream );
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

# The following function is based on code by Alexander Konovalov
BindGlobal("AUTODOC_ExtractMyManualExamples",
function( pkgname, pkgdir, docdir, main, files, opt )
    local tst, i, s, basename, name, output, ch, a, location, pos, comment, pkgdirString,
      nonempty_units_found, number_of_digits, lpkgname, tstdir;
    Info(InfoAutoDoc, 1, "Extracting manual examples for ", pkgname, " package ...");

    lpkgname := LowercaseString(pkgname);
    lpkgname := ReplacedString(lpkgname, " ", "_");

    if not EndsWith(main, ".xml") then
        main := Concatenation( main, ".xml" );
    fi;
    tst:=ExtractExamples( docdir, main, files, opt.units );
    Info(InfoAutoDoc, 1, Length(tst), " ", LowercaseString( opt.units ), "s detected");
    pkgdirString := Filename(pkgdir, "");

    if IsDirectory( opt.subdir ) then
        tstdir := Filename( opt.subdir, "" );
    else
        tstdir := Filename( pkgdir, opt.subdir );
    fi;
    AUTODOC_CreateDirIfMissing(tstdir);
    tstdir := Directory(tstdir);

    # first delete all old extracted tests in case chapter numbering etc. changed
    for s in DirectoryContents(tstdir) do
        # check prefix and suffix...
        if StartsWith(s, lpkgname) and EndsWith(s, ".tst")
            # ... and between them, there should be only digits (at least 2)...
            and Length(s) - Length(lpkgname) - 4 >= 2
            and ForAll(s{[1 + Length(lpkgname) .. Length(s) - 4]}, IsDigitChar) then
                RemoveFile(Filename(tstdir, s));
        fi;
    od;

    #
    nonempty_units_found := 0;
    number_of_digits := Length( String( Length( tst ) ) );
    if number_of_digits = 1 then
        number_of_digits := 2;
    fi;
    for i in [ 1 .. Length(tst) ] do
        Info(InfoAutoDoc, 1,  opt.units, " ", i, "...");
        if Length( tst[i] ) = 0 then
            Info(InfoAutoDoc, 1, "no examples");
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
        CloseStream( output );
        Info(InfoAutoDoc, 1, "extracted ", Length(ch), " examples");
    od;
end);
