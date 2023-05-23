# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

# Given a string containing a ".", , return its suffix,
# i.e. the bit after the last ".". For example, given "test.txt",
# it returns "txt".
BindGlobal( "AUTODOC_GetSuffix",
function(str)
    local i;
    i := Length(str);
    while i > 0 and str[i] <> '.' do i := i - 1; od;
    if i = 0 then return ""; fi;
    return str{[i+1..Length(str)]};
end );

# Scan the given (by name) subdirs of a package dir for
# files with one of the given extensions, and return the corresponding
# filenames, as relative paths (relative to the package dir).
#
# For example, the invocation
#   AUTODOC_FindMatchingFiles(pkgdir, [ "gap/" ], [ "gi", "gd" ]);
# might return a list looking like
#  [ "gap/AutoDocMainFunction.gd", "gap/AutoDocMainFunction.gi", ... ]
BindGlobal( "AUTODOC_FindMatchingFiles",
function (pkgdir, subdirs, extensions)
    local d_rel, d, tmp, files, result;

    result := [];

    for d_rel in subdirs do
        # Get the absolute path to the directory in side the package...
        d := Filename( pkgdir, d_rel );
        if not IsDirectoryPath( d ) then
            continue;
        fi;
        d := Directory( d );
        # ... but also keep the relative path (such as "gap")
        if d_rel = "" or d_rel = "." then
            d_rel := "";
        else
            d_rel := Directory( d_rel );
        fi;

        files := DirectoryContents( d );
        Sort( files );
        for tmp in files do
            if not AUTODOC_GetSuffix( tmp ) in extensions then
                continue;
            fi;
            if not IsReadableFile( Filename( d, tmp ) ) then
                continue;
            fi;
            if d_rel = "" then
                Add( result, tmp );
            else
                Add( result, Filename( d_rel, tmp ) );
            fi;
        od;
    od;
    return result;
end );

#
InstallGlobalFunction( AutoDoc,
function( arg )
    local pkgname, pkginfo, pkgdir,
          opt, scaffold, gapdoc, maketest, extract_examples, autodoc, i,
          doc_dir, doc_dir_rel, tmp, key, val, file,
          pkgdirstr, docdirstr,
          title_page, tree, is_worksheet,
          position_document_class,
          args;

    if Length( arg ) >= 3 then
        Error( "too many arguments" );
    fi;

    # check whether the last argument is an options record
    if Length( arg ) > 0 and IsRecord( arg[Length(arg)] ) then
        opt := Remove( arg );
    else
        opt := rec();
    fi;

    # check the first argument
    if Length(arg) = 0 then
        pkgdir := DirectoryCurrent( );
    elif IsString( arg[1] ) then
        pkgname := Remove( arg, 1 );
    elif IsDirectory( arg[1] ) then
        pkgdir := Remove( arg, 1 );
    fi;

    # if there are any arguments left, at least one was of unsupported type
    if Length(arg) > 0 then
        Error( "wrong arguments" );
    fi;

    if IsBound( pkgdir ) then
        is_worksheet := false;
        file := Filename( pkgdir, "PackageInfo.g" );
        if not IsExistingFile( file ) then
            Error( "no package name given and no PackageInfo.g file found" );
        elif not IsReadableFile( file ) then
            Error( "cannot read PackageInfo.g" );
        fi;
        Unbind( GAPInfo.PackageInfoCurrent );
        Read( file );
        if not IsBound( GAPInfo.PackageInfoCurrent ) then
            Error( "reading PackageInfo.g failed" );
        fi;
        pkginfo := GAPInfo.PackageInfoCurrent;
        if IsRecord( pkginfo.PackageDoc ) then
            pkginfo.PackageDoc:= [ pkginfo.PackageDoc ];
        fi;
        pkgname := pkginfo.PackageName;

    elif pkgname = "AutoDocWorksheet" then
        # For internal use only -- for details, refer to the AutoDocWorksheet() function.
        is_worksheet := true;
        pkginfo := rec( );
        pkgdir := DirectoryCurrent( );

    else
        is_worksheet := false;
        pkginfo := PackageInfo( pkgname );
        if IsEmpty( pkginfo ) then
            Error( "Could not find package ", pkgname );
        elif Length( pkginfo ) > 1 then
            Info( InfoWarning, 1, "multiple versions of package ", pkgname, " are present, using the first one" );
        fi;
        pkginfo := pkginfo[ 1 ];
        pkgdir := Directory( pkginfo.InstallationPath );
    fi;

    #
    # Check for user supplied options. If present, they take
    # precedence over any defaults as well as the opt record.
    #
    for key in [ "dir", "scaffold", "autodoc", "gapdoc", "maketest", "extract_examples" ] do
        val := ValueOption( key );
        if val <> fail then
            opt.(key) := val;
        fi;
    od;

    #
    # Setup the output directory
    #
    if not IsBound( opt.dir ) then
        doc_dir := "doc";
    elif IsString( opt.dir ) or IsDirectory( opt.dir ) then
        doc_dir := opt.dir;
    else
        Error( "opt.dir must be a string containing a path, or a directory object" );
    fi;

    if IsString( doc_dir ) then
        # Record the relative version of the path
        # FIXME: this assumes that doc_dir contains a relative path in the first place...
        doc_dir_rel := Directory( doc_dir );

        # We intentionally do not use
        #   DirectoriesPackageLibrary( pkgname, "doc" )
        # because it returns an empty list if the subdirectory is missing.
        # But we want to handle that case by creating the directory.
        doc_dir := Filename( pkgdir, doc_dir );
        doc_dir := Directory( doc_dir );

    else
        # In this case, if doc_dir happens to lie below pkgdir, we want the
        # doc_dir_rel to be the difference; if not we avoid binding doc_dir_rel
        # and leave MakeGAPDocDoc to muddle through with absolute paths.
        pkgdirstr := Filename( pkgdir, "" );
        docdirstr := Filename( doc_dir, "" );
        if StartsWith( docdirstr, pkgdirstr ) then
            doc_dir_rel :=
            Directory( docdirstr{[(Length(pkgdirstr)+1)..Length(docdirstr)]} );
        fi;
    fi;

    # Ensure the output directory exists, create it if necessary
    AUTODOC_CreateDirIfMissing(Filename(doc_dir, ""));

    # Let the developer know where we are generating the documentation.
    # This helps diagnose problems where multiple instances of a package
    # are visible to GAP and the wrong one is used for generating the
    # documentation.
    Info( InfoGAPDoc, 1, "Generating documentation in ", doc_dir, "\n" );

    #
    # Extract scaffolding settings, which can be controlled via
    # opt.scaffold or pkginfo.AutoDoc. The former has precedence.
    #
    if not IsBound(opt.scaffold) then
        # Default: enable scaffolding if and only if pkginfo.AutoDoc is present
        if IsBound( pkginfo.AutoDoc ) then
            scaffold := rec( );
        fi;
    elif IsRecord(opt.scaffold) then
        scaffold := opt.scaffold;
    elif IsBool(opt.scaffold) then
        if opt.scaffold = true then
            scaffold := rec();
        fi;
    else
        Error("opt.scaffold must be a bool or a record");
    fi;

    # Merge pkginfo.AutoDoc into scaffold
    if IsBound(scaffold) and IsBound( pkginfo.AutoDoc ) then
        for key in RecNames( pkginfo.AutoDoc ) do
            if IsBound( scaffold.(key) ) then
                Print("WARNING: ", key, " specified in both PackageInfo.AutoDoc and opt.scaffold\n");
            else
                scaffold.(key) := pkginfo.AutoDoc.(key);
            fi;
        od;

    fi;

    if IsBound( scaffold ) then
        AUTODOC_SetIfMissing( scaffold, "TitlePage", rec() );
        AUTODOC_SetIfMissing( scaffold, "MainPage", true );
    fi;


    #
    # Extract AutoDoc settings
    #
    if not IsBound(opt.autodoc) and not is_worksheet then
        # Enable AutoDoc support if the package depends on AutoDoc.
        tmp := Concatenation( pkginfo.Dependencies.NeededOtherPackages,
                              pkginfo.Dependencies.SuggestedOtherPackages );
        ## Empty entries are allowed in Dependencies
        tmp := Filtered( tmp, i -> i <> [ ] );
        if ForAny( tmp, x -> LowercaseString(x[1]) = "autodoc" ) then
            autodoc := rec();
        fi;
    elif IsRecord(opt.autodoc) then
        autodoc := opt.autodoc;
    elif IsBool(opt.autodoc) and opt.autodoc = true then
        autodoc := rec();
    fi;

    if IsBound(autodoc) then
        if not IsBound( autodoc.files ) then
            autodoc.files := [ ];
        elif not IsList( autodoc.files ) then
            Error("autodoc.files must be a list");
        elif Length(autodoc.files) >0 and IsString( autodoc.files ) then
            Error("autodoc.files must be a list of strings, not a string");
        fi;

        if not is_worksheet then
            if not IsBound( autodoc.scan_dirs ) then
                autodoc.scan_dirs := [ ".", "gap", "lib", "examples", "examples/doc" ];
            fi;
            Append( autodoc.files, AUTODOC_FindMatchingFiles(pkgdir, autodoc.scan_dirs, [ "g", "gi", "gd", "autodoc" ]) );
            autodoc.files := DuplicateFreeList( autodoc.files );
        fi;

        # Make sure all of the files exist, making the file names absolute if
        # necessary
        for i in [ 1 .. Length( autodoc.files ) ] do
            if IsExistingFile( autodoc.files[ i ] ) then continue; fi;
            if IsExistingFile( Filename( pkgdir, autodoc.files[ i ] ) ) then
                autodoc.files[ i ] := Filename( pkgdir, autodoc.files[ i ] );
                continue;
            fi;
            Error( autodoc.files[ i ], " does not specify an existing file either as an absolute path or relative to the package directory" );
        od;

        if not IsBound( autodoc.level ) then
            autodoc.level := 0;
        fi;
    fi;

    #
    # Extract GAPDoc settings
    #
    if not IsBound( opt.gapdoc ) then
        # Enable GAPDoc support by default
        gapdoc := rec();
    elif IsRecord( opt.gapdoc ) then
        gapdoc := opt.gapdoc;
    elif IsBool( opt.gapdoc ) and opt.gapdoc = true then
        gapdoc := rec();
    fi;

    if IsBound( gapdoc ) then
        
        AUTODOC_SetIfMissing( gapdoc, "main", pkgname );

        if IsBound( pkginfo.PackageDoc ) and not IsEmpty( pkginfo.PackageDoc ) then
            if Length( pkginfo.PackageDoc ) > 1 then
                Print("WARNING: Package contains multiple books, only using the first one\n");
            fi;
            gapdoc.bookname := pkginfo.PackageDoc[1].BookName;
            gapdoc.SixFile := pkginfo.PackageDoc[1].SixFile;
        elif not is_worksheet then
            # Default: book name = package name
            gapdoc.bookname := pkgname;
            gapdoc.SixFile := "doc/manual.six";

            Print("\n");
            Print("WARNING: PackageInfo.g is missing a PackageDoc entry!\n");
            Print("Without this, your package manual will not be recognized by the GAP help system.\n");
            Print("You can correct this by adding the following to your PackageInfo.g:\n");
            Print("PackageDoc := rec(\n");
            Print("  BookName  := ~.PackageName,\n");
            Print("  ArchiveURLSubset := [\"doc\"],\n");
            Print("  HTMLStart := \"doc/chap0.html\",\n");
            Print("  PDFFile   := \"doc/manual.pdf\",\n");
            Print("  SixFile   := \"doc/manual.six\",\n");
            Print("  LongTitle := ~.Subtitle,\n");
            Print("),\n");
            Print("\n");
        fi;

        if not IsBound( gapdoc.files ) then
            gapdoc.files := [];
        elif not IsList( gapdoc.files ) then
            Error("gapdoc.files must be a list");
        elif not ForAll( gapdoc.files, IsString ) then
            Error("gapdoc.files must be a list of strings, not a string");
        fi;

        if not is_worksheet then
            if not IsBound( gapdoc.scan_dirs ) then
                gapdoc.scan_dirs := [ ".", "gap", "lib", "examples", "examples/doc" ];
            fi;
            Append( gapdoc.files, AUTODOC_FindMatchingFiles(pkgdir, gapdoc.scan_dirs, [ "g", "gi", "gd" ]) );
        fi;

        # Attempt to weed out duplicates as they may confuse GAPDoc (this
        # will not work if there are any non-normalized paths in the list).
        gapdoc.files := Set( gapdoc.files );

        # If possible, convert the file paths in gapdoc.files, which are
        # relative to the package directory, to paths which are relative to
        # the doc directory.

        if IsBound( doc_dir_rel ) then
            # For this, we assume that doc_dir_rel is normalized (e.g.
            # it does not contains '//') and relative.
            # FIXME: this is an ugly hack, can't we do something better?
            tmp := Number( Filename( doc_dir_rel, "" ), x -> x = '/' );
            tmp := Concatenation( ListWithIdenticalEntries(tmp, "../") );
            gapdoc.files := List( gapdoc.files, f -> Concatenation( tmp, f ) );
        else
            # Here presumably the doc_dir was given by an absolute path that
            # does not lie below the package dir. In that case, we can't make
            # the gapdoc.files relative to the doc dir, but rather we have no
            # choice but to make them absolute, which MakeGAPDocDoc can handle,
            # even if perhaps less gracefully/portably.
            gapdoc.files := List( gapdoc.files, f -> Filename( pkgdir, f ) );
        fi;
    fi;


    # read tree
    # FIXME: shouldn't tree be declared inside of an 'if IsBound(autodoc)' section?
    tree := DocumentationTree( );

    if IsBound( autodoc ) then
        if IsBound( autodoc.section_intros ) then
            AUTODOC_PROCESS_INTRO_STRINGS( autodoc.section_intros, tree );
        fi;

        AutoDocScanFiles( autodoc.files, pkgname, tree );
    fi;

    if is_worksheet then
        # FIXME: We use scaffold and autodoc here without checking whether
        # they are bound. Does that mean worksheets always use them?
        if IsBound( scaffold.TitlePage.Title ) then
            pkgname := scaffold.TitlePage.Title;

        elif IsBound( tree!.TitlePage.Title ) then
            pkgname := tree!.TitlePage.Title;

        elif IsBound( autodoc.files ) and Length( autodoc.files ) > 0  then
            tmp := autodoc.files[ 1 ];

            # Remove everything before the last '/'
            tmp := SplitString(tmp, "/");
            tmp := tmp[Length(tmp)];

            # Remove everything after the first '.'
            tmp := SplitString(tmp, ".");
            tmp := tmp[1];

            pkgname := tmp;

        else
            Error( "could not figure out a title." );
        fi;

        if not IsString( pkgname ) then
            pkgname := JoinStringsWithSeparator( pkgname, " " );
        fi;

        gapdoc.main := ReplacedString( pkgname, " ", "_" );
        gapdoc.bookname := ReplacedString( pkgname, " ", "_" );
    fi;

    #
    # Generate scaffold
    #
    if IsBound( scaffold ) then
        ## Syntax is [ "class", [ "options" ] ]
        if IsBound( scaffold.document_class ) then
            position_document_class := PositionSublist( GAPDoc2LaTeXProcs.Head, "documentclass" );

            if IsString( scaffold.document_class ) then
                scaffold.document_class := [ scaffold.document_class ];
            fi;

            if position_document_class = fail then
                Error( "something is wrong with the LaTeX header" );
            fi;

            GAPDoc2LaTeXProcs.Head := Concatenation(
                  GAPDoc2LaTeXProcs.Head{[ 1 .. PositionSublist( GAPDoc2LaTeXProcs.Head, "{", position_document_class ) ]},
                  scaffold.document_class[ 1 ],
                  GAPDoc2LaTeXProcs.Head{[ PositionSublist( GAPDoc2LaTeXProcs.Head, "}", position_document_class ) .. Length( GAPDoc2LaTeXProcs.Head ) ]} );

            if Length( scaffold.document_class ) = 2 then

                GAPDoc2LaTeXProcs.Head := Concatenation(
                      GAPDoc2LaTeXProcs.Head{[ 1 .. PositionSublist( GAPDoc2LaTeXProcs.Head, "[", position_document_class ) ]},
                      scaffold.document_class[ 2 ],
                      GAPDoc2LaTeXProcs.Head{[ PositionSublist( GAPDoc2LaTeXProcs.Head, "]", position_document_class ) .. Length( GAPDoc2LaTeXProcs.Head ) ]} );
            fi;
        fi;

        if IsBound( scaffold.latex_header_file ) then
            GAPDoc2LaTeXProcs.Head := StringFile( scaffold.latex_header_file );
        fi;

        # check for legacy gapdoc_latex_options
        if IsBound( scaffold.gapdoc_latex_options ) then
            Info( InfoWarning, 1, TextAttr.1,
                  "WARNING: Please replace the DEPRECATED option <scaffold.gapdoc_latex_options> ",
                  "by <gapdoc.LaTeXOptions>", TextAttr.reset );
            if not IsBound( gapdoc.LaTeXOptions ) then
                gapdoc.LaTeXOptions := scaffold.gapdoc_latex_options;
            fi;
        fi;

        AUTODOC_SetIfMissing( scaffold, "includes", [ ] );

        if IsBound( autodoc ) then
            # If scaffold.includes is already set, then we add
            # AutoDocMainFile.xml to it, but *only* if it not already
            # there. This way, package authors can control where
            # it is put in their includes list.
            if not _AUTODOC_GLOBAL_OPTION_RECORD.AutoDocMainFile in scaffold.includes then
                Add( scaffold.includes, _AUTODOC_GLOBAL_OPTION_RECORD.AutoDocMainFile );
            fi;
        fi;

        if IsBound( scaffold.bib ) and IsBool( scaffold.bib ) then
            if scaffold.bib = true then
                scaffold.bib := Concatenation( pkgname, ".bib" );
            else
                Unbind( scaffold.bib );
            fi;
        elif not IsBound( scaffold.bib ) then
            # If there is a doc/PKG.bib file, assume that we want to reference it in the scaffold.
            tmp := Concatenation( pkgname, ".bib" );
            if IsReadableFile( Filename( doc_dir, tmp ) ) then
                scaffold.bib := tmp;
            fi;
        fi;

        AUTODOC_SetIfMissing( scaffold, "index", true );

        if IsBound( gapdoc ) then
            if AUTODOC_GetSuffix( gapdoc.main ) = "xml" then
                scaffold.main_xml_file := gapdoc.main;
            else
                scaffold.main_xml_file := Concatenation( gapdoc.main, ".xml" );
            fi;
        fi;

        if IsBound( scaffold.TitlePage ) and scaffold.TitlePage <> false then
            title_page := ShallowCopy( scaffold.TitlePage );

            AUTODOC_MergeRecords( title_page, tree!.TitlePage );

            if not is_worksheet then
                AUTODOC_MergeRecords( title_page, ExtractTitleInfoFromPackageInfo( pkginfo ) );
            fi;

            # Worksheets get date as a list
            if is_worksheet then
                title_page!.Date := Concatenation( title_page!.Date );
            fi;

            CreateTitlePage( doc_dir, title_page );
        fi;

        CreateEntitiesPage( gapdoc.bookname, doc_dir, scaffold );

        if IsBound( scaffold.MainPage ) and scaffold.MainPage <> false then
            CreateMainPage( gapdoc.bookname, doc_dir, scaffold );
        fi;
    fi;

    #
    # Write AutoDoc XML files
    #
    if IsBound( autodoc ) then
        WriteDocumentation( tree, doc_dir, autodoc.level );
        if IsBound( gapdoc ) then
            if IsBound( doc_dir_rel ) then
                Add( gapdoc.files, "_Chunks.xml" );
            else
                Add( gapdoc.files, Filename( doc_dir, "_Chunks.xml" ) );
            fi;
        fi;
    fi;


    #
    # Run GAPDoc
    #
    if IsBound( gapdoc ) then

        AUTODOC_SetIfMissing(gapdoc, "LaTeXOptions", rec() );
        if not IsRecord( gapdoc.LaTeXOptions ) then
            Error("gapdoc.LaTeXOptions must be a record");
        fi;
        for key in RecNames( gapdoc.LaTeXOptions ) do
            if not IsString( gapdoc.LaTeXOptions.( key ) )
               and IsList( gapdoc.LaTeXOptions.( key ) )
               and LowercaseString( gapdoc.LaTeXOptions.( key )[ 1 ] ) = "file" then
                gapdoc.LaTeXOptions.( key ) := StringFile( gapdoc.LaTeXOptions.( key )[ 2 ] );
            fi;
        od;


        # Ask GAPDoc to use UTF-8 as input encoding for LaTeX, as the XML files
        # of the documentation are also in UTF-8 encoding, and may contain characters
        # not contained in the default Latin 1 encoding.
        AUTODOC_SetIfMissing( gapdoc.LaTeXOptions, "InputEncoding", "utf8" );
        SetGapDocLaTeXOptions( gapdoc.LaTeXOptions );
        
        ## HACK: If there is an empty index, MakeGAPDocDoc throws an error when creating the pdf.
        ## this addition prevents this by fake adding the index to the page number log. See issue 106.
        ## FIXME: Once an empty index is allowed in GapDoc, this should be removed.
        GAPDoc2LaTeXProcs.Tail := Concatenation(
            "\\immediate\\write\\pagenrlog{[\"Ind\", 0, 0], \\arabic{page},}\n",
            GAPDoc2LaTeXProcs.Tail );

        # Default parameters for MakeGAPDocDoc
        args := [ doc_dir, gapdoc.main, gapdoc.files, gapdoc.bookname, "MathJax" ];

        # Don't try to generate PDFs if pdflatex is not available
        if Filename( DirectoriesSystemPrograms(), "pdflatex" ) = fail then
            Add(args, "nopdf" );
        fi;

        # The global option "relativePath" can be set to ensure the manual
        # is built in such a way that all references to the GAP reference manual
        # are using relative file paths. This is mainly useful when building
        # a package manual for use in a distribution tarball.
        
        tmp := ValueOption( "relativePath" );
        
        if IsBound( gapdoc.gap_root_relative_path ) and tmp = fail then ## the option overrides the settings in the call.
            tmp := gapdoc.gap_root_relative_path;
        fi;
        
        if tmp = true then
            Add( args, "../../.." );
        elif IsString( tmp ) then
            Add( args, tmp );
        fi;

        # don't build PDF docs if the environment variable NOPDF is set
        if IsBound( GAPInfo.SystemEnvironment.NOPDF ) then
            Add( args, "nopdf" );
        fi;

        # Finally, invoke GAPDoc
        CallFuncList( MakeGAPDocDoc, args );

        # NOTE: We cannot just write CopyHTMLStyleFiles(doc_dir) here, as
        # CopyHTMLStyleFiles its argument directly to Directory(), leading
        # to an error in all GAP versions up to and including 4.8.6. This
        # will be fixed with GAP 4.9, where Directory() is made idempotent.
        CopyHTMLStyleFiles( Filename( doc_dir, "" ) );

        # The following (undocumented) API is there for compatibility
        # with old-style gapmacro.tex based package manuals. It
        # produces a manual.lab file which those packages can use if
        # they wish to link to things in the manual we are currently
        # generating. This can probably be removed eventually, but for
        # now, doing it does not hurt.

        # FIXME: It seems that this command does not work if pdflatex
        #        is not present. Maybe we should remove it.

        if IsBound( gapdoc.SixFile ) then
            file := Filename(pkgdir, gapdoc.SixFile);
            if file = fail or not IsReadableFile(file) then
                Error("could not open `", file, "' for package `", pkgname, "'.\n");
            fi;
            GAPDocManualLabFromSixFile( gapdoc.bookname, file );
        fi;

    fi;

    #
    # Handle maketest (deprecated; consider using extract_examples instead)
    #

    if IsBound( opt.maketest ) then
        if IsRecord( opt.maketest ) then
            maketest := opt.maketest;
        elif opt.maketest = true then
            maketest := rec( );
        fi;
    fi;

    if IsBound( maketest ) then
    
        AUTODOC_SetIfMissing( maketest, "filename", "maketest.g" );
        AUTODOC_SetIfMissing( maketest, "commands", [ ] );

        CreateMakeTest( pkgdir, doc_dir, gapdoc.main, gapdoc.files, maketest );
    fi;

    #
    # Handle extract_examples
    #

    if IsBound( opt.extract_examples ) then
        if IsRecord( opt.extract_examples ) then
            extract_examples := opt.extract_examples;
        elif opt.extract_examples = true then
            extract_examples := rec( );
        fi;
    fi;

    if IsBound( extract_examples ) then
        if is_worksheet then
            # HACK: not even sure this is really what we want for worksheets, but
            # it is useful for our "dogfood" test suite
            pkgdir := doc_dir;
        fi;
        if not IsBound( extract_examples.units ) then
            extract_examples.units := "Chapter";
        fi;
        if not IsBound( extract_examples.skip_empty_in_numbering ) then
            extract_examples.skip_empty_in_numbering := true;
        fi;
        AUTODOC_ExtractMyManualExamples( pkgname, pkgdir, doc_dir, gapdoc.main, gapdoc.files, extract_examples );
    fi;

    return true;
end );
