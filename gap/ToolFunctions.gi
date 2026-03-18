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
    local result, JoinRelativePath, AddMatchingFiles, d_rel;

    result := [];

    JoinRelativePath := function( dir, entry )
        if dir = "" then
            return entry;
        fi;
        return Concatenation( dir, "/", entry );
    end;

    AddMatchingFiles := function( abs_dir, rel_dir, recursive )
        local abs_dir_obj, entries, entry, abs_entry, rel_entry;

        abs_dir_obj := Directory( abs_dir );
        entries := DirectoryContents( abs_dir_obj );
        Sort( entries );
        for entry in entries do
            if entry = "." or entry = ".." then
                continue;
            fi;
            abs_entry := Filename( abs_dir_obj, entry );
            rel_entry := JoinRelativePath( rel_dir, entry );
            if IsDirectoryPath( abs_entry ) then
                if recursive then
                    AddMatchingFiles( abs_entry, rel_entry, true );
                fi;
            elif AUTODOC_GetSuffix( entry ) in extensions and
                 IsReadableFile( abs_entry ) then
                Add( result, rel_entry );
            fi;
        od;
    end;

    for d_rel in subdirs do
        if d_rel = "" or d_rel = "." then
            AddMatchingFiles( Filename( pkgdir, "" ), "", false );
        elif not IsDirectoryPath( Filename( pkgdir, d_rel ) ) then
            continue;
        else
            AddMatchingFiles( Filename( pkgdir, d_rel ), d_rel, true );
        fi;
    od;
    return result;
end );

# Ensure that the directory named by the given path string exists, creating any
# missing parent directories on the way. Relative paths are accepted and `.` /
# `..` components are normalized before creating directories.
InstallGlobalFunction( "AUTODOC_CreateDirIfMissing",
function(d)
    local tmp, components, normalized, current, component;
    if not IsDirectoryPath(d) then
        components := SplitString( d, "/" );
        normalized := [ ];
        for component in components do
            if component = "" or component = "." then
                continue;
            elif component = ".." then
                if StartsWith( d, "/" ) then
                    if Length( normalized ) > 0 then
                        Remove( normalized );
                    fi;
                elif Length( normalized ) > 0 and Last( normalized ) <> ".." then
                    Remove( normalized );
                else
                    Add( normalized, component );
                fi;
            else
                Add( normalized, component );
            fi;
        od;

        current := "";
        if StartsWith( d, "/" ) then
            current := "/";
        fi;
        for component in normalized do
            Append( current, component );
            Append( current, "/" );
            if not IsDirectoryPath( current ) then
                tmp := CreateDir( current ); # Note: CreateDir is currently undocumented
                if tmp = fail then
                    Error("Cannot create directory ", current, "\n",
                          "Error message: ", LastSystemError().message, "\n");
                    return false;
                fi;
            fi;
        od;
    fi;
    return true;
end );

InstallGlobalFunction( "AUTODOC_CurrentDirectory",
function(args...)
    local pwd, result;
    pwd := Filename( DirectoriesSystemPrograms(), "pwd" );
    if pwd = fail then
        Error("failed to locate 'pwd' tool");
    fi;
    result := "";
    Process(DirectoryCurrent(), pwd, InputTextNone(), OutputTextString(result, true), []);
    return Chomp(result);
end);

InstallGlobalFunction( "AUTODOC_LineStartsCDATA",
function(line)
    # Phase 1 keeps CDATA encoded as raw strings; Parser.gi still injects such
    # fragments directly, so other layers must continue to detect them.
    return PositionSublist(line, "<![CDATA[") <> fail;
end);

InstallGlobalFunction( "AUTODOC_LineEndsCDATA",
function(line)
    return PositionSublist(line, "]]>") <> fail;
end);

InstallGlobalFunction( "AUTODOC_EscapeCDATAContent",
function(text)
    return ReplacedString(text, "]]>", "]]]]><![CDATA[>");
end);


InstallGlobalFunction( "AUTODOC_OutputTextFile",
function( dir, filename )
    local filestream;
    filename := Filename( dir, filename );
    filestream := OutputTextFile( filename, false );
    SetPrintFormattingStatus( filestream, false );
    return filestream;
end );

##
InstallGlobalFunction( AutoDoc_WriteDocEntry,
  function( filestream, list_of_records, heading )
    local return_value, return_value_sources, description,
          description_sources, current_description, labels, i,
          item_type_info;

    # look for a good return value (it should be the same everywhere)
    for i in list_of_records do
        if IsBound( i!.return_value ) then
            if IsList( i!.return_value ) and Length( i!.return_value ) > 0 then
                return_value := i!.return_value;
                return_value_sources := i!.return_value_source_positions;
                break;
            elif IsBool( i!.return_value ) then
                return_value := i!.return_value;
                return_value_sources := [ ];
                break;
            fi;
        fi;
    od;

    if not IsBound( return_value ) then
        return_value := false;
        return_value_sources := [ ];
    fi;

    if IsList( return_value ) and ( not IsString( return_value ) ) and return_value <> "" then
        return_value := JoinStringsWithSeparator( return_value, " " );
    fi;

    # collect description (for readability not in the loop above)
    description := [ ];
    description_sources := [ ];
    for i in list_of_records do
        current_description := i!.description;
        if IsString( current_description ) then
            current_description := [ current_description ];
        fi;
        Append( description, current_description );
        Append( description_sources, i!.description_source_positions );
    od;

    labels := [ ];
    for i in list_of_records do
        if HasGroupName( i ) then
            Add( labels, GroupName( i ) );
        fi;
    od;
    if Length( labels ) > 1 then
        labels :=  [ labels[ 1 ] ];
    fi;

    # Write stuff out

    # First labels, this has no effect in the current GAPDoc, btw.
    AppendTo( filestream, "<ManSection" );
    for i in labels do
        AppendTo( filestream, " Label=\"", i, "\"" );
    od;
    AppendTo( filestream, ">\n" );

    # Next possibly the heading for the entry
    if IsString( heading ) then
        AppendTo( filestream, "<Heading>", heading, "</Heading>\n" );
    fi;

    # Function headers
    for i in list_of_records do
        item_type_info := AUTODOC_ITEM_TYPE_INFO.( i!.item_type );
        if IsBound( item_type_info.item_type_override ) then
            AppendTo( filestream, "  <", item_type_info.item_type_override, " " );
        else
            AppendTo( filestream, "  <", i!.item_type, " " );
        fi;
        if item_type_info.is_function_like and i!.arguments <> fail then
            AppendTo( filestream, "Arg=\"", i!.arguments, "\" " );
        fi;
        if IsBound( item_type_info.filter_type ) then
            AppendTo( filestream, "Type=\"", item_type_info.filter_type, "\" " );
        fi;
        AppendTo( filestream, "Name=\"", i!.name, "\" " );
        if i!.tester_names <> fail and i!.tester_names <> "" then
            AppendTo( filestream, "Label=\"", i!.tester_names, "\"" );
        fi;
        AppendTo( filestream, "/>\n" );
    od;

    if return_value <> false then
        if IsString( return_value ) then
            return_value := [ return_value ];
        fi;
        AppendTo( filestream, " <Returns>" );
        AUTODOC_WriteDocumentationListWithSource(
            return_value,
            return_value_sources,
            filestream
        );
        AppendTo( filestream, "</Returns>\n" );
    fi;

    AppendTo( filestream, " <Description>\n" );
    AUTODOC_WriteDocumentationListWithSource(
        description,
        description_sources,
        filestream
    );
    AppendTo( filestream, " </Description>\n" );

    AppendTo( filestream, "</ManSection>\n\n" );
end );

InstallGlobalFunction( AUTODOC_WriteDocumentationListWithSource,
  function( node_list, source_positions, filestream )
    local current_source_positions, current_string_list, i, next_source_index,
          FlushConvertedStrings;

    FlushConvertedStrings := function()
        AUTODOC_WriteStringListWithSource(
            current_string_list,
            current_source_positions,
            filestream
        );
        current_string_list := [ ];
        current_source_positions := [ ];
    end;

    current_string_list := [ ];
    current_source_positions := [ ];
    next_source_index := 1;
    for i in [ 1 .. Length( node_list ) ] do
        if IsString( node_list[ i ] ) then
            Add( current_string_list, ShallowCopy( node_list[ i ] ) );
            if source_positions = fail or next_source_index > Length( source_positions ) then
                Add( current_source_positions, fail );
            else
                Add( current_source_positions, source_positions[ next_source_index ] );
            fi;
            next_source_index := next_source_index + 1;
        else
            FlushConvertedStrings();
            WriteDocumentation( node_list[ i ], filestream );
        fi;
    od;
    FlushConvertedStrings();
end );

InstallGlobalFunction( AUTODOC_WriteStringListWithSource,
  function( string_list, source_positions, filestream )
    local converted_string_list, in_cdata, item;

    if string_list = [ ] then
        return;
    fi;
    converted_string_list := AUTODOC_ConvertMarkdownToGAPDocXML( string_list, source_positions );
    in_cdata := false;
    for item in converted_string_list do
        if not IsString( item ) then
            WriteDocumentation( item, filestream );
            continue;
        fi;
        if AUTODOC_LineStartsCDATA( item ) then
            in_cdata := true;
        fi;
        if in_cdata = true then
            AppendTo( filestream, Chomp( item ), "\n" );
        else
            WriteDocumentation( item, filestream );
        fi;
        if AUTODOC_LineEndsCDATA( item ) then
            in_cdata := false;
        fi;
    od;
end );

InstallGlobalFunction( AUTODOC_Diff,
function(args...)
    local diff;
    diff := Filename( DirectoriesSystemPrograms(), "diff" );
    if diff = fail then
        Error("failed to locate 'diff' tool");
    fi;
    return Process(DirectoryCurrent(), diff, InputTextUser(), OutputTextUser(), args);
end);

# AUTODOC_TestWorkSheet is used by AutoDocs test suite to test the worksheets
# feature. Its first argument <ws> should be a string, and then
# `tst/worksheets/<ws>` should be a directory containing a worksheet, and
# `tst/worksheets/<ws>.expected` a directory containing the output of
# AutoDocWorksheet for that worksheet. An optional second argument can be used
# to override the options passed to AutoDocWorksheet for a single test case.
#
# Then AUTODOC_TestWorkSheet will again run AutoDocWorksheet, storing the
# output in a temporary directory; it recursively compares all files present in
# the expected output tree so worksheet fixtures can cover nested generated
# output as well. If no differences exist, it outputs nothing.
InstallGlobalFunction( AUTODOC_TestWorkSheet,
function(arg...)
    local ws, options, wsdir, sheetdir, expecteddir, actualdir, filenames, old,
          tmpdir, compare_files, worksheet_options, key;

    if Length( arg ) = 0 or Length( arg ) > 2 then
        Error("usage: AUTODOC_TestWorkSheet( <worksheet>[, <options>] )");
    fi;
    ws := arg[1];
    if Length( arg ) = 2 then
        options := arg[2];
    else
        options := rec( );
    fi;

    # Recurse into expected subdirectories so worksheet fixtures can verify
    # nested output trees such as generated test files below `tst/generated`.
    compare_files := function(expected, actual)
        local names, f, expected_path, actual_path;
        if IsDirectoryPath(expected) then
            if not IsDirectoryPath(actual) then
                Error("expected directory ", actual);
            fi;
            expected := Directory(expected);
            actual := Directory(actual);
            names := DirectoryContents(expected);
            names := Filtered(names, f -> f <> "." and f <> "..");
            Sort(names);
            for f in names do
                expected_path := Filename(expected, f);
                actual_path := Filename(actual, f);
                if not IsDirectoryPath(actual_path) and not IsReadableFile(actual_path) then
                    Error("missing generated file ", actual_path);
                fi;
                compare_files(expected_path, actual_path);
            od;
            return;
        fi;

        if not IsReadableFile(actual) then
            Error("missing generated file ", actual);
        fi;
        if 0 <> AUTODOC_Diff("-u", expected, actual) then
            Error("diff detected in file ", actual);
        fi;
    end;

    # check worksheets dir exists
    wsdir := DirectoriesPackageLibrary("AutoDoc", "tst/worksheets");
    wsdir := wsdir[1];
    if not IsDirectoryPath(wsdir) then
      Error("could not access tst/worksheets/");
    fi;

    # check input dir exists
    sheetdir := Filename(wsdir, Concatenation(ws, ".sheet"));
    if not IsString(sheetdir) or not IsDirectoryPath(sheetdir) then
      Error("could not access tst/", ws, ".sheet/");
    fi;
    sheetdir := Directory(sheetdir);

    # check dir with expected output
    expecteddir := Filename(wsdir, Concatenation(ws, ".expected"));
    if not IsString(expecteddir) or not IsDirectoryPath(expecteddir) then
      Error("could not access tst/", ws, ".expected/");
    fi;
    expecteddir := Directory(expecteddir);

    # create and clear the output directory in a writable temporary location
    tmpdir := Filename(DirectoryTemporary(), Concatenation("autodoc-", ws, ".actual"));
    if IsDirectoryPath(tmpdir) then
      RemoveDirectoryRecursively(tmpdir);
    fi;
    AUTODOC_CreateDirIfMissing(tmpdir);
    actualdir := tmpdir;
    actualdir := Directory(actualdir);

    # Run the worksheet
    filenames := DirectoryContents(sheetdir);
    filenames := Filtered(filenames, f -> f <> "." and f <> "..");
    filenames := List(filenames, f -> Filename(sheetdir, f));

    old := InfoLevel(InfoGAPDoc);
    SetInfoLevel(InfoGAPDoc, 0);
    # Start from the standard worksheet test options, then apply any
    # per-test overrides supplied by the caller.
    worksheet_options := rec(
        dir := actualdir,
        extract_examples := true
    );
    for key in RecNames( options ) do
        worksheet_options.( key ) := options.( key );
    od;
    AutoDocWorksheet(filenames, worksheet_options : nopdf);
    SetInfoLevel(InfoGAPDoc, old);

    # Check the results
    compare_files(expecteddir, actualdir);

    RemoveDirectoryRecursively(tmpdir);
end);

# Parse a date given as a string. Currently only supports the two formats
# allowed in PackageInfo.g, namely "DD/MM/YYYY" or "YYYY-MM-DD". Returns a
# record with entries `year`, `month`, `day` bound to the corresponding
# integers extracted from the input string.
#
# Returns `fail` if the input could not be parsed.
InstallGlobalFunction( AUTODOC_ParseDate,
function(date)
    local day, month, year;
    if Length(date) <> 10 then
        return fail;
    fi;
    if date{[3,6]} = "//" then
        day := Int(date{[1,2]});
        month := Int(date{[4,5]});
        year := Int(date{[7..10]});
    elif date{[5,8]} = "--" then
        day := Int(date{[9,10]});
        month := Int(date{[6,7]});
        year := Int(date{[1..4]});
    else
        return fail;
    fi;
    if day = fail or month = fail or year = fail then
        return fail;
    fi;
    return rec( day := day, month := month, year := year );
end);

BindGlobal("AUTODOC_months", MakeImmutable([
    "January", "February", "March",
    "April", "May", "June",
    "July", "August", "September",
    "October", "November", "December"
]));

# Format a date into a human readable string; a date may consist of only
# a year; or a year and a month; or a year, month and day. Dates are
# formatted as "2019", resp. "February 2019" resp. "5 February 2019".
#
# The input can be one of the following:
#  - AUTODOC_FormatDate(rec), where <rec> is a record with entries year, month, day;
#  - AUTODOC_FormatDate(year[, month[, day]])
#  - AUTODOC_FormatDate(date_str) where date_str is a string of the form "DD/MM/YYYY" or "YYYY-MM-DD"
# In each case, the year, month or day may be given as either an
# integer, or as a string representing an integer.
InstallGlobalFunction( AUTODOC_FormatDate,
function(arg)
    local date, key, val, result;
    if Length(arg) = 1 and IsRecord(arg[1]) then
        date := ShallowCopy(arg[1]);
    elif Length(arg) = 1 and IsString(arg[1]) then
        date := AUTODOC_ParseDate(arg[1]);
    elif Length(arg) in [1..3] then
        date := rec();
        date.year := arg[1];
        if Length(arg) >= 2 then
            date.month := arg[2];
        fi;
        if Length(arg) >= 3 then
            date.day := arg[3];
        fi;
    fi;
    if not IsBound(date) or date = fail then
        Error("Invalid arguments");
    fi;

    # convert string values to integers
    for key in [ "day", "month", "year" ] do
        if IsBound(date.(key)) then
            val := date.(key);
            if IsString(val) and Length(val) > 0 and ForAll(val, IsDigitChar) then
                date.(key) := Int(val);
            fi;
        fi;
    od;

    if not IsInt(date.year) or date.year < 2000 then
        Error("<year> must be an integer >= 2000, or a string representing such an integer");
    fi;
    result := String(date.year);
    if IsBound(date.month) then
        if not date.month in [1..12] then
            Error("<month> must be an integer in the range [1..12], or a string representing such an integer");
        fi;
        result := Concatenation(AUTODOC_months[date.month], " ", result);
        if IsBound(date.day) then
            if not date.day in [1..31] then
                # TODO: also account for differing length of months
                Error("<day> must be an integer in the range [1..31], or a string representing such an integer");
            fi;
            result := Concatenation(String(date.day), " ", result);
        fi;
    fi;
    return result;
end);
