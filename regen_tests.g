if fail = LoadPackage("AutoDoc") then
    Error("failed to load AutoDoc package");
fi;

SetInfoLevel(InfoAutoDoc, 1);

AUTODOC_RegenWorkSheetExpected := function(wsdir, ws)
    local sheetdir, expecteddir, filenames, old;

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

AUTODOC_RegenAllWorkSheetExpected();
QUIT_GAP(0);
