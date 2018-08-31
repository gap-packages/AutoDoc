#############################################################################
##
##  AutoDoc package
##
##  Copyright 2018
##    Contributed by Glen Whitney, studioinfinity.org
##
## Licensed under the GPL 2 or later.
##
#############################################################################

LoadPackage( "AutoDoc" );

# First test all of the worksheets present in the test directory.
# Here's the format in which they should be specified. There should be a
# subdirectory tst/worksheets. That in turn should have two subdirectories for
# each worksheet it is desired to test: <worksheetname>.sheet and
# <worksheetname>.expected. What will happen is that AutoDocWorksheet will be
# called on all of the files in <worksheetname>.sheet, writing into a
# directory <worksheetname>.actual. Each of the files in
# <worksheetname>.expected will be compared to the same-named file in
# <worksheetname>.actual and any differences will be considered an error. For
# convenience, the output directory <worksheetname>.actual will be located
# alongside <worksheetname>.expected if the parent directory is writable,
# otherwise it will be placed in a temporary directory.

ws_collections :=
    DirectoriesPackageLibrary( "AutoDoc", "tst/worksheets" );
if Length( ws_collections ) < 1 then
    Print( "#I There is no worksheet directory tst/worksheets for Autodoc\n" );
    Print( "#I Errors detected while testing\n" );
    FORCE_QUIT_GAP(1);
fi;
ws_collection_dir := ws_collections[ 1 ];
ws_collection_path := Filename( ws_collection_dir, "" );
all_ok := true;
for ws in DirectoryContents( ws_collection_dir ) do
    if not EndsWith( ws, ".sheet" ) then
        continue;
    fi;
    Print( "#I Testing worksheet ", ws, "\n" );
    # determine the output directory
    if IsWritableFile( ws_collection_path ) then
        outpath := Filename( ws_collection_dir,
                             Concatenation( ws{[1..Length(ws)-6]}, ".actual" ) );
        outdir := Directory( outpath );
        if IsExistingFile( outpath ) then
            for of in DirectoryContents( outdir ) do
                RemoveFile( Filename( outdir, of ) );
            od;
        fi;
    else
        outdir := DirectoryTemporary( );
    fi;
    # determine the list of files in the worksheet
    ws_dir := Directory( Filename( ws_collection_dir, ws ) );
    ws_f := DirectoryContents( ws_dir );
    wfs := [ ];
    for w in ws_f do
        if w = "." or w = ".." then continue; fi;
        Add( wfs, Filename( ws_dir, w ) );
    od;
    Print( "#I ... consisting of files ", wfs, "\n" );
    # Run the worksheet
    AutoDocWorksheet( wfs, rec( dir := outdir ) );
    # Check the results
    ex_dir := Directory( Filename( ws_collection_dir,
                                   Concatenation( ws{[1..Length(ws)-6]},
                                                  ".expected" ) ) );
    ex_ls := DirectoryContents( ex_dir );
    for ex in ex_ls do
        if ex = "." or ex = ".." then continue; fi;
        exf := Filename( ex_dir, ex );
        af := Filename( outdir, ex );
        if not IsExistingFile( af ) then
            Print( "#I Error: AutoDocWorksheet did not produce ", ex );
            all_ok := false;
            continue;
        fi;
        dif := Concatenation( af, ".diff" );
        command := Concatenation( "diff -s -c ", exf, " ", af, " > ", dif );
        Exec( command );
        report := ReadAll( InputTextFile( dif ) );
        desired := Concatenation( "Files ", exf, " and ", af,
                                  " are identical\n" );
        if report <> desired then
            Print( "#I Differences for ", ex, "\n" );
            Print( report, "\n" );
            all_ok := false;
        fi;
    od;
od;
if all_ok then
  Print( "#I No errors detected while testing\n" );
else
  Print( "#I Errors detected while testing\n" );
fi;

# Finally run any standard-format .tst in the tst directory
Print( "\n#I Running TestDirectory as well:\n\n" );
TestDirectory( DirectoriesPackageLibrary( "AutoDoc", "tst" ),
               rec( exitGAP := true )
             );

FORCE_QUIT_GAP(1); # should only be reached in case of error
