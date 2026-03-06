if fail = LoadPackage("AutoDoc") then
    Error("failed to load AutoDoc package");
fi;
LoadPackage("io", false);

SetInfoLevel(InfoAutoDoc, 1);

AUTODOC_RegenWorkSheetExpected := function(wsdir, ws)
    local sheetdir, expecteddir, filenames, old, f, tstfiles, x;

    sheetdir := Filename(wsdir, Concatenation(ws, ".sheet"));
    if not IsString(sheetdir) or not IsDirectoryPath(sheetdir) then
        Error("could not access tst/worksheets/", ws, ".sheet/");
    fi;
    sheetdir := Directory(sheetdir);

    expecteddir := Filename(wsdir, Concatenation(ws, ".expected"));
    if IsDirectoryPath(expecteddir) then
        RemoveDirectoryRecursively(expecteddir);
    fi;
    AUTODOC_CreateDirIfMissing(expecteddir);
    expecteddir := Directory(expecteddir);

    filenames := DirectoryContents(sheetdir);
    filenames := Filtered(filenames, f -> f <> "." and f <> "..");
    filenames := Filtered(filenames,
                    f -> not IsDirectoryPath(Filename(sheetdir, f)));
    Sort(filenames);
    filenames := List(filenames, f -> Filename(sheetdir, f));

    old := InfoLevel(InfoGAPDoc);
    SetInfoLevel(InfoGAPDoc, 0);
    AutoDocWorksheet(filenames, rec(dir := expecteddir, extract_examples := true));
    SetInfoLevel(InfoGAPDoc, old);

    # Keep only deterministic reference outputs.
    filenames := DirectoryContents(expecteddir);
    filenames := Filtered(filenames, f -> f <> "." and f <> "..");
    for f in filenames do
        if f = "tst" then
            tstfiles := DirectoryContents(Filename(expecteddir, "tst"));
            tstfiles := Filtered(tstfiles, x -> x <> "." and x <> "..");
            for x in tstfiles do
                if PositionSublist(x, ".tst") <> Length(x) - 3 then
                    RemoveFile(Filename(Filename(expecteddir, "tst"), x));
                fi;
            od;
            continue;
        fi;
        if PositionSublist(f, ".xml") <> Length(f) - 3 then
            RemoveFile(Filename(expecteddir, f));
        fi;
    od;
end;

AUTODOC_RegenAllWorkSheetExpected := function()
    local wsdir, ws;
    wsdir := DirectoriesPackageLibrary("AutoDoc", "tst/worksheets");
    wsdir := wsdir[1];
    if not IsDirectoryPath(wsdir) then
        Error("could not access tst/worksheets/");
    fi;

    for ws in ["general", "autoplain"] do
        AUTODOC_RegenWorkSheetExpected(wsdir, ws);
    od;
end;

AUTODOC_RegenManualExpected := function()
    local pkgdir, olddir, tempdir, expecteddir, files, old_gapdoc_level,
          old_warning_level, file, docdir;

    pkgdir := DirectoriesPackageLibrary("AutoDoc", "");
    pkgdir := pkgdir[1];
    if not IsDirectoryPath(pkgdir) then
        Error("could not access AutoDoc package directory");
    fi;

    olddir := AUTODOC_CurrentDirectory();
    tempdir := Filename(DirectoryTemporary(), "autodoc-manual-expected");
    if IsDirectoryPath(tempdir) then
        RemoveDirectoryRecursively(tempdir);
    fi;

    Exec(Concatenation("cp -R \"", Filename(pkgdir, ""), "\" \"", tempdir, "\""));
    if not IsDirectoryPath(tempdir) then
        Error("failed to create temporary package copy");
    fi;

    docdir := Concatenation(tempdir, "/doc");
    files := DirectoryContents(docdir);
    files := Filtered(files,
        f -> f <> "." and f <> ".." and
             Length(f) >= 6 and f[1] = '_' and
             PositionSublist(f, ".xml") = Length(f) - 3);
    for file in files do
        RemoveFile(Concatenation(docdir, "/", file));
    od;

    old_gapdoc_level := InfoLevel(InfoGAPDoc);
    old_warning_level := InfoLevel(InfoWarning);
    SetInfoLevel(InfoGAPDoc, 0);
    SetInfoLevel(InfoWarning, 0);
    ChangeDirectoryCurrent(tempdir);
    Read("makedoc.g");
    ChangeDirectoryCurrent(olddir);
    SetInfoLevel(InfoGAPDoc, old_gapdoc_level);
    SetInfoLevel(InfoWarning, old_warning_level);

    expecteddir := Filename(pkgdir, "tst/manual.expected");
    if IsDirectoryPath(expecteddir) then
        RemoveDirectoryRecursively(expecteddir);
    fi;
    AUTODOC_CreateDirIfMissing(expecteddir);

    docdir := Concatenation(tempdir, "/doc");
    files := DirectoryContents(docdir);
    files := Filtered(files,
        f -> f <> "." and f <> ".." and
             Length(f) >= 6 and f[1] = '_' and
             PositionSublist(f, ".xml") = Length(f) - 3);
    Sort(files);
    for file in files do
        Exec(Concatenation(
            "cp \"", docdir, "/", file, "\" \"",
            expecteddir, "/", file, "\""
        ));
    od;

    RemoveDirectoryRecursively(tempdir);
end;

AUTODOC_RegenAllWorkSheetExpected();
AUTODOC_RegenManualExpected();
QUIT_GAP(0);
