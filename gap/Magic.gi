#############################################################################
##
##  Magic.gi                                         AutoDoc package
##
##  Copyright 2013, Max Horn, JLU Giessen
##
#############################################################################


# TODO: Move CreateTitlePage and CreateMainPage into this file, too?
# Or perhaps move them into new files Scaffold.{gi,gd} ?

BindGlobal( "AUTODOC_HasSuffix",
function(list, suffix)
    local n, m;
    n := Length(list);
    m := Length(suffix);
    return n >= m and list{[n-m+1..n]} = suffix;
end );



# AutoDoc(pkg[, opt])
#
# TODO: Write documentation
#
InstallGlobalFunction( AutoDoc,
function( arg )
    local pkg, package_info, opt, dir, scaffold, gapdoc, autodoc,
            d, files, i, tmp;
    
    pkg := arg[1];
    package_info := PackageInfo( pkg )[ 1 ];

    if Length(arg) >= 2 then
        opt := arg[2];
    else
        opt := rec();
    fi;
    
    
    #
    # Setup the output directory
    #
    if not IsBound(opt.dir) then
        dir := Directory("doc");
    elif IsString(opt.dir) then
        dir := Directory(opt.dir);
    elif IsDirectory(opt.dir) then
        dir := opt.dir;
    else
        Error("opt.dir must be a string containing a path, or a directory object");
    fi;

    # Ensure the output directory exists, create it if necessary
    d := Filename(dir, "");
    if not IsDirectoryPath(d) then
        tmp := CreateDir(d); # Note: CreateDir is currently undocumented
        if tmp = fail then
            Error("Cannot create directory ", d, "\n",
                  "Error message: ", LastSystemError().message, "\n");
            return false;
        fi;
    fi;
    
    
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
        if not IsBound(autodoc.output) then
            # FIXME: is this name good?
            # FIXME: OK to put this generated file into the doc dir?
            autodoc.output := Filename(dir, "AutoDocEntries.g");
            # TODO: many packages use this:   gap/AutoDocEntries.g
            #    perhaps we should do, too?
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

        if not IsBound( gapdoc.main ) then
            gapdoc.main := pkg;
        fi;

        if not IsBound( gapdoc.bookname ) then
            gapdoc.bookname := gapdoc.main;
        fi;

        if not IsBound( gapdoc.files ) then
            gapdoc.files := [];
            # TODO: Add PackageInfo.g  ?  resp.  ../PackageInfo.g
        fi;

        if not IsBound( gapdoc.scan_dirs ) then
            gapdoc.scan_dirs := [ "gap", "lib", "examples", "examples/doc" ];
        fi;

        for d in gapdoc.scan_dirs do
            d := Directory(d);
            if not IsDirectoryPath(Filename(d, "")) then
                continue;
            fi;
            files := DirectoryContents(d);
            files := Filtered( files, x -> 
                AUTODOC_HasSuffix(x, ".gd") or AUTODOC_HasSuffix(x, ".gi") or AUTODOC_HasSuffix(x, ".g") );
            files := List( files, x -> Filename(d, x) );
            files := Filtered( files, IsReadableFile );
            Append( gapdoc.files, files );
        od;

        # Ensure the autodoc output file gets scanned by GAPDoc
        if IsBound( autodoc ) then
            Add( gapdoc.files, autodoc.output );
        fi;
        
        # Attempt to weed out duplicates as they may confuse GAPDoc (this
        # won't work if there are any non-normalized paths in the list).
        gapdoc.files := Set( gapdoc.files );
        
        # Convert the file paths in gapdoc.files, which are relative to
        # the current dir, to paths which are relative to the doc dir.
        # For this, we assume that the dir path is normalized (e.g.
        # it does not contains '//') and relative.
        d := Number( Filename( dir, "" ), x -> x = '/' );
        d := Concatenation( ListWithIdenticalEntries(d, "../") );
        gapdoc.files := List( gapdoc.files, f -> Concatenation( d, f ) );

    fi;
    
    
    #
    # Generate scaffold
    #
    if IsBound( scaffold ) then

        if not IsBound( scaffold.includes ) then
            if IsBound( autodoc ) then
                scaffold.includes := [ "AutoDocMainFile.xml" ];
            else
                scaffold.includes := [ ];
            fi;
        else
            # If scaffold.includes is already set, then we leave it to
            # the package author to decide whether to include AutoDocMainFile.xml,
            # and in which order relative to the other includes...
        fi;

        if IsBound( scaffold.bib ) and IsBool( scaffold.bib ) then
            if scaffold.bib = true then
                scaffold.bib := pkg;
            else
                Unbind( scaffold.bib );
            fi;
        elif not IsBound( scaffold.bib ) then
            # If there is a doc/PKG.bib file, assume that we want to reference it in the scaffold.
            if IsReadableFile( Filename( dir, Concatenation( pkg, ".bib" ) ) ) then
                scaffold.bib := pkg;
            fi;
        fi;

        if IsBound( gapdoc ) then
            scaffold.main_xml_file := Concatenation( gapdoc.main, ".xml" );
        fi;

# TODO: It should be possible to only rebuild the title page. (Perhaps also only the main page? but this is less important)
        
        # TODO: Possibly only pass scaffold.TitlePage???
        CreateTitlePage( pkg, dir, scaffold );
        
        # TODO: Possibly only pass scaffold.entities and scaffold.includes??
        # TODO: Possibly pass gapdoc.main (as another param or via the
        # option record), to make sure the created .tex file get
        # appropriately named?
        CreateMainPage( pkg, dir, scaffold );

    fi;
    
    #
    # Run AutoDoc
    #
    if IsBound( autodoc ) then
# TODO: bring back create_doc param to CreateAutomaticDocumentation for now, to allow migration
    
        if IsBound( autodoc.section_intros ) then
            CreateAutomaticDocumentation( pkg, autodoc.output, dir, false, autodoc.section_intros );
        else
            CreateAutomaticDocumentation( pkg, autodoc.output, dir, false );
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

        MakeGAPDocDoc( dir, gapdoc.main, gapdoc.files, gapdoc.bookname, "MathJax" );

        CopyHTMLStyleFiles( Filename(dir, "") );

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
