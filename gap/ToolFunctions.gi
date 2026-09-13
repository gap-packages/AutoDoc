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

# Not DirectoryCurrent: its cached value goes stale when the directory is
# changed other than by ChangeDirectoryCurrent. Not the `pwd` program either,
# which under MSYS2 prints a path native Windows programs cannot use.
InstallGlobalFunction( "AUTODOC_CurrentDirectory",
function(args...)
    return GAP_getcwd();
end);

# Whether <path> is absolute: it starts with a slash, or on Windows with a
# drive, as in `C:/`.
InstallGlobalFunction( "AUTODOC_IsAbsolutePath",
function( path )
    return StartsWith( path, "/" ) or
           ( ARCH_IS_WINDOWS() and Length( path ) >= 3 and
             path[2] = ':' and path[3] in "/\\" );
end );

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

# Return the deepest directory containing all of the given paths, as a string
# ending in "/", or fail if they share none. This is derived purely from the
# given strings, so unlike the working directory it is unaffected by where a
# command was started or by symlinks on the way to the files.
InstallGlobalFunction( "AUTODOC_CommonParentDirectory",
function( paths )
    local components, common, i, n;

    if IsEmpty( paths ) then
        return fail;
    fi;

    # keep the directory components, dropping the file name
    components := List( paths,
                        p -> SplitString( p, "/" ) );
    components := List( components, c -> c{[ 1 .. Length( c ) - 1 ]} );

    common := components[1];
    for i in [ 2 .. Length( components ) ] do
        n := 0;
        while n < Length( common ) and n < Length( components[i] )
              and common[ n + 1 ] = components[i][ n + 1 ] do
            n := n + 1;
        od;
        common := common{[ 1 .. n ]};
    od;

    if IsEmpty( common ) then
        return fail;
    fi;

    return Concatenation( JoinStringsWithSeparator( common, "/" ), "/" );
end );

# Render a source file path for display and for recording in generated files:
# relative to the package directory when it lies below it, else relative to
# the working directory, else the bare filename. Absolute paths would make
# generated output depend on where the package happens to live.
InstallGlobalFunction( "AUTODOC_RelativeSourcePath",
function( path, pkgdir )
    local prefix, candidate;

    for candidate in [ pkgdir, Directory( AUTODOC_CurrentDirectory() ) ] do
        prefix := Filename( candidate, "" );
        if prefix <> fail and Length( prefix ) > 1 and StartsWith( path, prefix ) then
            return path{ [ Length( prefix ) + 1 .. Length( path ) ] };
        fi;
    od;

    return Last( SplitString( path, "/" ) );
end );

# Elements whose content is a manual example, i.e. those GAPDoc's
# ExtractExamplesXMLTree collects. Only these are worth annotating.
BindGlobal( "AUTODOC_EXAMPLE_ELEMENTS", [ "Example", "Log" ] );

BindGlobal( "AUTODOC_SOURCE_MARKER_PREFIX", "<!--AutoDocSource " );
BindGlobal( "AUTODOC_SOURCE_MARKER_SUFFIX", "-->" );
BindGlobal( "AUTODOC_CDATA_CLOSE", "]]></" );

# Render the provenance of an example node as an XML comment, e.g.
#   <!--AutoDocSource gap/Foo.gd:137-141-->
# GAPDoc parses these into XMLCOMMENT nodes which every output backend
# ignores, so they are invisible in the built manual; AutoDoc reads them back
# in AUTODOC_RemapSourcePositions to report the true origin of an example.
#
# Returns fail if the node carries no position, is not an example, or if the
# path cannot be represented in an XML comment.
InstallGlobalFunction( "AUTODOC_SourceMarker",
function( node )
    local position, end_position, text;

    if not IsBound( node!.element_name ) or
       not node!.element_name in AUTODOC_EXAMPLE_ELEMENTS or
       not IsBound( node!.source_position ) or
       node!.source_position = fail then
        return fail;
    fi;

    position := node!.source_position;
    if IsBound( node!.source_end_position ) and node!.source_end_position <> fail then
        end_position := node!.source_end_position;
    else
        end_position := position;
    fi;

    # XML forbids "--" inside comments, and ">" would end ours early. Rather
    # than mangle the path, drop the marker and fall back to reporting the
    # generated XML file, as AutoDoc did before markers existed.
    if PositionSublist( position.filename, "--" ) <> fail or
       '>' in position.filename then
        Info( InfoAutoDoc, 1, "WARNING: cannot record source position for ",
              position.filename, ", path is not valid inside an XML comment" );
        return fail;
    fi;

    text := Concatenation(
        AUTODOC_SOURCE_MARKER_PREFIX,
        position.filename, ":",
        String( position.line ), "-", String( end_position.line ),
        AUTODOC_SOURCE_MARKER_SUFFIX
    );
    return text;
end );

# Rewrite GAPDoc's origin list in place so that text AutoDoc generated is
# attributed to the file it was generated *from*.
#
# `str` is a composed document as returned by ComposedDocument, and `src` the
# accompanying list of [position, filename, line] triples which
# OriginalPositionDocument searches. Each marker claims the element that
# follows it, up to and including the line closing its CDATA block. Within
# that region we report the recorded start line, except for the closing line,
# which gets the recorded end line. ExtractExamplesXMLTree only ever looks up
# the start and stop of an example, so both of its lookups land exactly.
#
#   <!--AutoDocSource gap/Foo.gd:137-141-->   <- marker at position p
#   <Example><![CDATA[                        <- reported as gap/Foo.gd:137
#   gap> 1+1;
#   2
#   ]]></Example>                             <- reported as gap/Foo.gd:141
InstallGlobalFunction( "AUTODOC_RemapSourcePositions",
function( str, src )
    local marker_start, marker_end, region_start, region_end, colon, dash,
          body, filename, start_line, end_line, first, last, i;

    marker_start := PositionSublist( str, AUTODOC_SOURCE_MARKER_PREFIX );

    while marker_start <> fail do
        marker_end := PositionSublist( str, AUTODOC_SOURCE_MARKER_SUFFIX, marker_start );
        if marker_end = fail then
            break;
        fi;
        marker_end := marker_end + Length( AUTODOC_SOURCE_MARKER_SUFFIX ) - 1;
        region_start := marker_start;

        body := str{ [ marker_start + Length( AUTODOC_SOURCE_MARKER_PREFIX )
                       .. marker_end - Length( AUTODOC_SOURCE_MARKER_SUFFIX ) ] };

        # Split "path/to/file.gd:137-141" from the right, so that paths
        # containing ':' or '-' survive.
        colon := Length( body );
        while colon > 0 and body[ colon ] <> ':' do colon := colon - 1; od;
        dash := Length( body );
        while dash > colon and body[ dash ] <> '-' do dash := dash - 1; od;

        marker_start := PositionSublist( str, AUTODOC_SOURCE_MARKER_PREFIX, marker_end );

        if colon = 0 or dash <= colon then
            continue;
        fi;

        filename := body{ [ 1 .. colon - 1 ] };
        start_line := Int( body{ [ colon + 1 .. dash - 1 ] } );
        end_line := Int( body{ [ dash + 1 .. Length( body ) ] } );
        if start_line = fail or end_line = fail then
            continue;
        fi;

        # The marker describes exactly one element, which AutoDoc always
        # writes CDATA-wrapped, so its closing line is the first one holding
        # "]]></". Everything after that belongs to unrelated generated text
        # and keeps its own origin.
        region_end := PositionSublist( str, AUTODOC_CDATA_CLOSE, marker_end );
        if region_end = fail or ( marker_start <> fail and region_end > marker_start ) then
            continue;
        fi;
        region_end := Position( str, '\n', region_end );
        if region_end = fail then
            region_end := Length( str );
        fi;

        first := PositionSorted( src, [ region_start ] );
        last := PositionSorted( src, [ region_end ] ) - 1;
        for i in [ first .. last ] do
            if not IsBound( src[ i ] ) then
                continue;
            fi;
            src[ i ][ 2 ] := filename;
            if i = last then
                src[ i ][ 3 ] := end_line;
            else
                src[ i ][ 3 ] := start_line;
            fi;
        od;
    od;
end );

# Output of a previous manual build. Staging a documentation directory copies
# its inputs only; these are large, regenerated anyway, and never read back.
# Kept in sync with the `clean` target of the Makefile.
BindGlobal( "AUTODOC_BUILD_ARTIFACT_EXTENSIONS",
  [ "aux", "bbl", "blg", "brf", "css", "dvi", "html", "idx", "ilg", "ind",
    "js", "lab", "log", "out", "pdf", "pnr", "ps", "six", "tex", "toc",
    "txt" ] );

# Recursively copy the contents of directory `src` into directory `dst`,
# skipping build artifacts.
#
# GAP has no CopyFile, so this goes through StringFile/FileString. Those read
# and write raw bytes, so binary inputs such as images survive.
InstallGlobalFunction( "AUTODOC_StageDirectory",
function( src, dst )
    local entry, entries, source_path, target_path, contents;

    AUTODOC_CreateDirIfMissing( Filename( dst, "" ) );

    entries := DirectoryContents( src );
    if entries = fail then
        # Nothing to stage; a package may not have a doc directory yet.
        return;
    fi;

    for entry in entries do
        if entry = "." or entry = ".." then
            continue;
        fi;

        source_path := Filename( src, entry );

        if IsDirectoryPath( source_path ) then
            AUTODOC_StageDirectory( Directory( source_path ),
                                    Directory( Filename( dst, entry ) ) );
            continue;
        fi;

        if AUTODOC_GetSuffix( entry ) in AUTODOC_BUILD_ARTIFACT_EXTENSIONS then
            continue;
        fi;

        contents := StringFile( source_path );
        if contents = fail then
            continue;
        fi;

        target_path := Filename( dst, entry );
        if FileString( target_path, contents ) = fail then
            Error( "failed to stage ", source_path, " to ", target_path );
        fi;
    od;
end );
