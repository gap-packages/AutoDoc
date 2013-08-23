#############################################################################
##
##  Magic.gi                                         AutoDoc package
##
##  Copyright 2013, Max Horn, JLU Giessen
##
#############################################################################

# Check if a string has the given suffix or not. Another
# name for this would "StringEndsWithOtherString".
# For example, AUTODOC_HasSuffix("file.gi", ".gi") returns
# true while AUTODOC_HasSuffix("file.txt", ".gi") returns false.
BindGlobal( "AUTODOC_HasSuffix",
function(str, suffix)
    local n, m;
    n := Length(str);
    m := Length(suffix);
    return n >= m and str{[n-m+1..n]} = suffix;
end );

# Given a string containing a ".", , return its suffix,
# i.e. the bit after the last ".". For example, given "test.txt",
# it returns "txt".
BindGlobal( "AUTODOC_GetSuffix",
function(str)
    local i;
    i := Length(str);
    while i > 0 and str[i] <> '.' do i := i - 1; od;
    if i < 0 then return ""; fi;
    return str{[i+1..Length(str)]};
end );

# Check whether the given directory exists, and if not, attempt
# to create it.
BindGlobal( "AUTODOC_CreateDirIfMissing",
function(d)
    local tmp;
    if not IsDirectoryPath(d) then
        tmp := CreateDir(d); # Note: CreateDir is currently undocumented
        if tmp = fail then
            Error("Cannot create directory ", d, "\n",
                  "Error message: ", LastSystemError().message, "\n");
            return false;
        fi;
    fi;
    return true;
end );


# Scan the given (by name) subdirs of a package dir for
# files with one of the given extensions, and return the corresponding
# filenames, as relative paths (relative to the package dir).
#
# For example, the invocation
#   AUTODOC_FindMatchingFiles("AutoDoc", [ "gap/" ], [ "gi", "gd" ]);
# might return a list looking like
#  [ "gap/AutoDocMainFunction.gd", "gap/AutoDocMainFunction.gi", ... ]
BindGlobal( "AUTODOC_FindMatchingFiles",
function (pkg, subdirs, extensions)
    local d_rel, d, tmp, files, result;

    result := [];

    for d_rel in subdirs do
        # Get the absolute path to the directory in side the package...
        d := DirectoriesPackageLibrary( pkg, d_rel );
        if IsEmpty( d ) then
            continue;
        fi;
        d := d[1];
        # ... but also keep the relative path (such as "gap")
        d_rel := Directory( d_rel );

        files := DirectoryContents( d );
        Sort( files );
        for tmp in files do
            if not AUTODOC_GetSuffix( tmp ) in [ "g", "gi", "gd" ] then
                continue;
            fi;
            if not IsReadableFile( Filename( d, tmp ) ) then
                continue;
            fi;
            Add( result, Filename( d_rel, tmp ) );
        od;
    od;
    return result;
end );


# AutoDoc(pkg[, opt])
#
InstallGlobalFunction( AutoDoc,
function( arg )
    local pkg, package_info, opt, scaffold, gapdoc, autodoc,
          pkg_dir, doc_dir, doc_dir_rel, d, tmp;
    
    pkg := arg[1];
    package_info := PackageInfo( pkg )[ 1 ];
    pkg_dir := DirectoriesPackageLibrary( pkg, "" )[1];

    if Length(arg) >= 2 then
        opt := arg[2];
    else
        opt := rec();
    fi;

    # Check for certain user supplied options, and if present, add them
    # to the opt record.
    tmp := function( key )
        local val;
        val := ValueOption( key );
        if val <> fail then
            opt.(key) := val;
        fi;
    end;
    
    tmp( "dir" );
    tmp( "scaffold" );
    tmp( "autodoc" );
    tmp( "gapdoc" );
    
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
        doc_dir_rel := Directory( doc_dir );

        # We intentionally do not use
        #   DirectoriesPackageLibrary( pkg, "doc" )
        # because it returns an empty list if the subdirectory is missing.
        # But we want to handle that case by creating the directory.
        doc_dir := Filename(pkg_dir, doc_dir);
        doc_dir := Directory(doc_dir);

    else
        # TODO: doc_dir_rel = ... ?
    fi;

    # Ensure the output directory exists, create it if necessary
    AUTODOC_CreateDirIfMissing(Filename(doc_dir, ""));
    
    # Let the developer know where we are generating the documentation.
    # This helps diagnose problems where multiple instances of a package
    # are visible to GAP and the wrong one is used for generating the
    # documentation.
    # TODO: Using Info() instead of Print?
    Print( "Generating documentation in ", doc_dir, "\n" );

    #
    # Extract scaffolding settings, which can be controlled via
    # opt.scaffold or package_info.AutoDoc. The former has precedence.
    #
    if not IsBound(opt.scaffold) then
        # Default: enable scaffolding if and only if package_info.AutoDoc is present
        if IsBound( package_info.AutoDoc ) then
            scaffold := rec();
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

    # Merge package_info.AutoDoc into scaffold
    if IsBound(scaffold) and IsBound( package_info.AutoDoc ) then
        for d in RecNames( package_info.AutoDoc ) do
            if not IsBound( scaffold.( d ) ) then
                scaffold.( d ) := package_info.AutoDoc.( d );
            fi;
        od;
    fi;

    
    #
    # Extract AutoDoc settings
    #
    if not IsBound(opt.autodoc) then
        # Enable AutoDoc support if the package depends on AutoDoc.
        tmp := Concatenation( package_info.Dependencies.NeededOtherPackages,
                              package_info.Dependencies.SuggestedOtherPackages );
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
            
        fi;
        
        if not IsBound( autodoc.scan_dirs ) then
            autodoc.scan_dirs := [ "gap", "lib", "examples", "examples/doc" ];
        fi;
        
        if not IsBound( autodoc.level ) then
            
            autodoc.level := 0;
            
        fi;
        
        PushOptions( rec( level_value := autodoc.level ) );
        
        Append( autodoc.files, AUTODOC_FindMatchingFiles(pkg, autodoc.scan_dirs, [ "g", "gi", "gd" ]) );
        
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

        if not IsBound( gapdoc.main ) then
            gapdoc.main := pkg;
        fi;

        # FIXME: the following may break if a package uses more than one book
        if IsBound( package_info.PackageDoc ) and IsBound( package_info.PackageDoc[1].BookName ) then
            gapdoc.bookname := package_info.PackageDoc[1].BookName;
        else
            # Default: book name = package name
            gapdoc.bookname := pkg;

            Print("\n");
            Print("WARNING: PackageInfo.g is missing a PackageDoc entry!\n");
            Print("Without this, your package manual will not be recognized by the GAP help system.\n");
            Print("You can correct this by adding the following to your PackageInfo.g:\n");
            Print("PackageDoc := rec(\n");
            Print("  BookName  := ~.PackageName,\n");
            #Print("  BookName  := \"", pkg, "\",\n");
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
        fi;

        if not IsBound( gapdoc.scan_dirs ) then
            gapdoc.scan_dirs := [ "gap", "lib", "examples", "examples/doc" ];
        fi;

        Append( gapdoc.files, AUTODOC_FindMatchingFiles(pkg, gapdoc.scan_dirs, [ "g", "gi", "gd" ]) );

        # Attempt to weed out duplicates as they may confuse GAPDoc (this
        # won't work if there are any non-normalized paths in the list).
        gapdoc.files := Set( gapdoc.files );
        
        # Convert the file paths in gapdoc.files, which are relative to
        # the package directory, to paths which are relative to the doc directory.
        # For this, we assume that doc_dir_rel is normalized (e.g.
        # it does not contains '//') and relative.
        d := Number( Filename( doc_dir_rel, "" ), x -> x = '/' );
        d := Concatenation( ListWithIdenticalEntries(d, "../") );
        gapdoc.files := List( gapdoc.files, f -> Concatenation( d, f ) );

    fi;
    
    
    #
    # Generate scaffold
    #
    if IsBound( scaffold ) then

        if not IsBound( scaffold.includes ) then
            scaffold.includes := [ ];
        fi;

        if IsBound( autodoc ) then
            # If scaffold.includes is already set, then we add
            # AutoDocMainFile.xml to it, but *only* if it not already
            # there. This way, package authors can control where
            # it is put in their includes list.
            if not "AutoDocMainFile.xml" in scaffold.includes then
                Add( scaffold.includes, "AutoDocMainFile.xml" );
            fi;
        fi;

        if IsBound( scaffold.bib ) and IsBool( scaffold.bib ) then
            if scaffold.bib = true then
                scaffold.bib := Concatenation( pkg, ".bib" );
            else
                Unbind( scaffold.bib );
            fi;
        elif not IsBound( scaffold.bib ) then
            # If there is a doc/PKG.bib file, assume that we want to reference it in the scaffold.
            if IsReadableFile( Filename( doc_dir, Concatenation( pkg, ".bib" ) ) ) then
                scaffold.bib := Concatenation( pkg, ".bib" );
            fi;
        fi;

        if IsBound( gapdoc ) then
            if AUTODOC_GetSuffix( gapdoc.main ) = "xml" then
                scaffold.main_xml_file := gapdoc.main;
            else
                scaffold.main_xml_file := Concatenation( gapdoc.main, ".xml" );
            fi;
        fi;

        # TODO: It should be possible to only rebuild the title page. (Perhaps also only the main page? but this is less important)
        
        CreateTitlePage( pkg, doc_dir, scaffold );
        
        CreateMainPage( pkg, doc_dir, scaffold );

    fi;
    
    #
    # Run AutoDoc
    #
    if IsBound( autodoc ) then
    
        if IsBound( autodoc.section_intros ) then
            
            CreateAutomaticDocumentation( pkg, doc_dir, autodoc.section_intros : files_to_scan := autodoc.files );
            
        else
            
            CreateAutomaticDocumentation( pkg, doc_dir : files_to_scan := autodoc.files );
            
        fi;

    fi;
    
    
    #
    # Run GAPDoc
    #
    if IsBound( gapdoc ) then

        # Ask GAPDoc to use UTF-8 as input encoding for LaTeX, as the XML files
        # of the documentation are also in UTF-8 encoding, and may contain characters
        # not contained in the default Latin 1 encoding.
        SetGapDocLaTeXOptions( "utf8" );

        MakeGAPDocDoc( doc_dir, gapdoc.main, gapdoc.files, gapdoc.bookname, "MathJax" );

        CopyHTMLStyleFiles( Filename( doc_dir, "" ) );

        # The following (undocumented) API is there for compatibility
        # with old-style gapmacro.tex based package manuals. It
        # produces a manual.lab file which those packages can use if
        # they wish to link to things in the manual we are currently
        # generating. This can probably be removed eventually, but for
        # now, doing it does not hurt.
        GAPDocManualLab( pkg );

    fi;

    return true;
end );
