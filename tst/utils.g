# Helpers shared by the package-level AutoDoc regression tests.
#
# AUTODOC_RunPackageScenario runs one makedoc-based scenario for the
# tst/AutoDocTest fixture package in an isolated temporary copy.
# Arguments:
#   pkgdir   absolute path to tst/AutoDocTest/
#   olddir   caller's original working directory, restored on exit
#   scenario record describing the scenario to run; it must contain
#            `name` and `makedoc`, and may additionally specify:
#            - `stub_gapdoc := true` to skip the expensive GAPDoc post-pass
#            - `doc_expected := "tst/...expected"` for full doc-file diffs
#            - `tst_expected := "tst/...expected"` for extracted-test diffs
#            - `doc_present := [ ... ]` / `doc_absent := [ ... ]` for
#              presence/absence checks
AUTODOC_RunPackageScenario := function( pkgdir, olddir, scenario )
    local tempdir, docdir, tstdir, ex_dir, files, expected, actual,
          old_makegapdocdoc, old_copyhtmlstylefiles, old_manuallab,
          old_autodoc_level, old_gapdoc_level, old_warning_level, f,
          source_doc_files, source_tst_files;

    tempdir := Filename(
        DirectoryTemporary(),
        Concatenation( "autodoctest-", scenario.name )
    );
    if IsDirectoryPath( tempdir ) then
        RemoveDirectoryRecursively( tempdir );
    fi;

    # Work in a temporary package copy so the checked-in fixture tree stays
    # untouched and the scenario can freely create/remove generated files.
    Exec( Concatenation( "cp -R \"", pkgdir, "\" \"", tempdir, "\"" ) );
    ChangeDirectoryCurrent( tempdir );

    if IsBound( scenario.prepare ) then
        scenario.prepare( tempdir );
    fi;

    docdir := Directory( Concatenation( tempdir, "/doc" ) );
    # Keep only handwritten fixture inputs in doc/. Any pre-existing generated
    # output would otherwise make presence/absence checks depend on stale files
    # from the repository checkout instead of this scenario run.
    source_doc_files := [
        "AutoDocTest.bib",
        "appendix.autodoc",
        "appendix1.xml",
        "chapter1.xml",
        "chapter2.autodoc",
        "extract-examples.xml",
        "manual.six",
    ];
    for f in DirectoryContents( docdir ) do
        if f = "." or f = ".." or f in source_doc_files then
            continue;
        fi;
        RemoveFile( Filename( docdir, f ) );
    od;

    tstdir := Directory( Concatenation( tempdir, "/tst" ) );
    # Likewise, keep the package's test driver but remove any generated .tst
    # files so extract_examples checks only inspect fresh output.
    source_tst_files := [ "testall.g" ];
    for f in DirectoryContents( tstdir ) do
        if f = "." or f = ".." or f in source_tst_files then
            continue;
        fi;
        RemoveFile( Filename( tstdir, f ) );
    od;

    if IsBound( scenario.stub_gapdoc ) and scenario.stub_gapdoc then
        # These scenarios only care about scaffold-side file creation, not the
        # full GAPDoc build. Stub the GAPDoc entry points to keep the test fast
        # and to avoid requiring files that are intentionally not generated.
        old_makegapdocdoc := MakeGAPDocDoc;
        old_copyhtmlstylefiles := CopyHTMLStyleFiles;
        old_manuallab := GAPDocManualLabFromSixFile;
        MakeReadWriteGlobal( "MakeGAPDocDoc" );
        MakeReadWriteGlobal( "CopyHTMLStyleFiles" );
        MakeReadWriteGlobal( "GAPDocManualLabFromSixFile" );
        MakeGAPDocDoc := function( arg... ) return true; end;
        CopyHTMLStyleFiles := function( arg... ) return true; end;
        GAPDocManualLabFromSixFile := function( arg... ) return true; end;

        # AutoDoc checks that manual.six is readable before calling the
        # stubbed GAPDocManualLabFromSixFile hook.
        actual := OutputTextFile( Filename( docdir, "manual.six" ), false );
        CloseStream( actual );
    fi;

    old_autodoc_level := InfoLevel( InfoAutoDoc );
    old_gapdoc_level := InfoLevel( InfoGAPDoc );
    old_warning_level := InfoLevel( InfoWarning );
    SetInfoLevel( InfoAutoDoc, 0 );
    SetInfoLevel( InfoGAPDoc, 0 );
    SetInfoLevel( InfoWarning, 0 );
    Read( scenario.makedoc : nopdf );
    SetInfoLevel( InfoAutoDoc, old_autodoc_level );
    SetInfoLevel( InfoGAPDoc, old_gapdoc_level );
    SetInfoLevel( InfoWarning, old_warning_level );

    if IsBound( scenario.stub_gapdoc ) and scenario.stub_gapdoc then
        # Restore the real GAPDoc hooks before the next scenario runs.
        MakeGAPDocDoc := old_makegapdocdoc;
        CopyHTMLStyleFiles := old_copyhtmlstylefiles;
        GAPDocManualLabFromSixFile := old_manuallab;
    fi;

    if IsBound( scenario.doc_expected ) then
        # Compare the generated documentation tree against a stored fixture.
        ex_dir := Directory( Concatenation( pkgdir, scenario.doc_expected ) );
        files := DirectoryContents( ex_dir );
        files := Filtered( files, file -> file <> "." and file <> ".." );
        Sort( files );
        for f in files do
            expected := Filename( ex_dir, f );
            actual := Filename( docdir, f );
            if not IsReadableFile( actual ) then
                Error( "missing generated file ", f, " in scenario ", scenario.name );
            fi;
            if 0 <> AUTODOC_Diff( "-u", expected, actual ) then
                Error( "diff detected in scenario ", scenario.name, " for file ", f );
            fi;
        od;
    fi;

    if IsBound( scenario.tst_expected ) then
        # Compare extracted example tests against stored expected .tst files.
        ex_dir := Directory( Concatenation( pkgdir, scenario.tst_expected ) );
        files := DirectoryContents( ex_dir );
        files := Filtered( files, file -> file <> "." and file <> ".." );
        Sort( files );
        for f in files do
            expected := Filename( ex_dir, f );
            actual := Filename( tstdir, f );
            if not IsReadableFile( actual ) then
                Error( "missing extracted test ", f, " in scenario ", scenario.name );
            fi;
            if 0 <> AUTODOC_Diff( "-u", expected, actual ) then
                Error( "diff detected in scenario ", scenario.name, " for test ", f );
            fi;
        od;
    fi;

    if IsBound( scenario.doc_present ) then
        # Some scenarios only care whether specific files were generated.
        for f in scenario.doc_present do
            actual := Filename( docdir, f );
            if not IsReadableFile( actual ) then
                Error( "missing expected generated file ", f, " in scenario ", scenario.name );
            fi;
        od;
    fi;

    if IsBound( scenario.doc_absent ) then
        # And some assert that a file was intentionally not generated.
        for f in scenario.doc_absent do
            actual := Filename( docdir, f );
            if IsExistingFile( actual ) then
                Error( "unexpected generated file ", f, " in scenario ", scenario.name );
            fi;
        od;
    fi;

    ChangeDirectoryCurrent( olddir );
    RemoveDirectoryRecursively( tempdir );
end;
