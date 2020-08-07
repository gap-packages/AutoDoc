# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

# Check whether the given directory exists, and if not, attempt
# to create it.
InstallGlobalFunction( "AUTODOC_CreateDirIfMissing",
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

InstallGlobalFunction( "AUTODOC_CurrentDirectory",
function()
    return AUTODOC_AbsolutePath(DirectoryCurrent());
end);

# given a path (relative or absolute), return an absolute path pointing to the
# same file or directory.
InstallGlobalFunction( "AUTODOC_AbsolutePath",
function( dir, filename... )
    local pwd, result;
    pwd := Filename( DirectoriesSystemPrograms(), "pwd" );
    if pwd = fail then
        Error("failed to locate 'pwd' tool");
    fi;
    result := "";
    Process(Directory(dir), pwd, InputTextNone(), OutputTextString(result, true), []);
    result := Chomp(result);
    if Length(filename) > 0 and Length(filename[1]) > 0 then
        Append(result, "/");
        Append(result, filename[1]);
    fi;
    return result;
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
  function( filestream, list_of_records, heading, level_value )
    local return_value, description, current_description, labels, i;

    # look for a good return value (it should be the same everywhere)
    for i in list_of_records do
        if IsBound( i!.return_value ) then
            if IsList( i!.return_value ) and Length( i!.return_value ) > 0 then
                return_value := i!.return_value;
                break;
            elif IsBool( i!.return_value ) then
                return_value := i!.return_value;
                break;
            fi;
        fi;
    od;

    if not IsBound( return_value ) then
        return_value := false;
    fi;

    if IsList( return_value ) and ( not IsString( return_value ) ) and return_value <> "" then
        return_value := JoinStringsWithSeparator( return_value, " " );
    fi;

    # collect description (for readability not in the loop above)
    description := [ ];
    for i in list_of_records do
        current_description := i!.description;
        if IsString( current_description ) then
            current_description := [ current_description ];
        fi;
        description := Concatenation( description, current_description );
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
         AppendTo( filestream, "  <", i!.item_type, " " );
        if i!.arguments <> fail and i!.item_type <> "Var" then
            AppendTo( filestream, "Arg=\"", i!.arguments, "\" " );
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
        WriteDocumentation( return_value, filestream, level_value );
        AppendTo( filestream, "</Returns>\n" );
    fi;

    AppendTo( filestream, " <Description>\n" );
    WriteDocumentation( description, filestream, level_value );
    AppendTo( filestream, " </Description>\n" );

    AppendTo( filestream, "</ManSection>\n\n" );
end );

InstallGlobalFunction( AutoDoc_MakeGAPDocDoc_WithoutLatex,

  function(arg)
  local htmlspecial, path, main, files, bookname, gaproot, str,
        r, t, l, latex, null, log, pos, h, i, j;
  htmlspecial := Filtered(arg, a-> a in ["MathML", "Tth", "MathJax"]);
  if Length(htmlspecial) > 0 then
    arg := Filtered(arg, a-> not a in ["MathML", "Tth", "MathJax"]);
  fi;
  path := arg[1];
  main := arg[2];
  files := arg[3];
  bookname := arg[4];
  if IsBound(arg[5]) then
    gaproot := arg[5];
  else
    gaproot := false;
  fi;
  # ensure that path is directory object
  if IsString(path) then
    path := Directory(path);
  fi;
  # ensure that .xml is stripped from name of main file
  if Length(main)>3 and main{[Length(main)-3..Length(main)]} = ".xml" then
    main := main{[1..Length(main)-4]};
  fi;
  # compose the XML document
  Info(InfoGAPDoc, 1, "#I Composing XML document . . .\n");
  str := ComposedDocument("GAPDoc", path,
                             Concatenation(main, ".xml"), files, true);
  # parse the XML document
  Info(InfoGAPDoc, 1, "#I Parsing XML document . . .\n");
  r := ParseTreeXMLString(str[1], str[2]);
  # clean the result
  Info(InfoGAPDoc, 1, "#I Checking XML structure . . .\n");
  CheckAndCleanGapDocTree(r);
  # produce text version
  Info(InfoGAPDoc, 1,
                   "#I Text version (also produces labels for hyperlinks):\n");
  t := GAPDoc2Text(r, path);
  GAPDoc2TextPrintTextFiles(t, path);
  # produce LaTeX version
  Info(InfoGAPDoc, 1, "#I Constructing LaTeX version and calling pdflatex:\n");
  r.bibpath := path;
  l := GAPDoc2LaTeX(r);
  Info(InfoGAPDoc, 1, "#I Writing LaTeX file, \c");
  Info(InfoGAPDoc, 2, Concatenation(main, ".tex"), "\n#I     ");
  FileString(Filename(path, Concatenation(main, ".tex")), l);
  # print manual.six file
  PrintSixFile(Filename(path, "manual.six"), r, bookname);
  # produce html version
  Info(InfoGAPDoc, 1, "#I Finally the HTML version . . .\n");
  # if MathJax version is also produced we include links to them
  if "MathJax"  in htmlspecial then
    r.LinkToMathJax := true;
  fi;
  h := GAPDoc2HTML(r, path, gaproot);
  GAPDoc2HTMLPrintHTMLFiles(h, path);
  Unbind(r.LinkToMathJax);
  if "Tth" in htmlspecial then
    Info(InfoGAPDoc, 1,
            "#I - also HTML version with 'tth' translated formulae . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "Tth");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;
  if "MathML" in htmlspecial then
    Info(InfoGAPDoc, 1, "#I - also HTML + MathML version with 'ttm' . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "MathML");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;
  if "MathJax" in htmlspecial then
    Info(InfoGAPDoc, 1, "#I - also HTML version for MathJax . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "MathJax");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;

  return r;
end);

InstallGlobalFunction( AutoDoc_CreatePrintOnceFunction,
  function( message )
    local x;
    
    x := true;
    return function( )
        if x then
            Print( message, "\n" );
        fi;
        x := false;
    end;
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
# feature. Its single argument <ws> should be a string, and then
# `tst/worksheets/<ws>` should be a directory containing a worksheet, and
# `tst/worksheets/<ws>.expected` a directory containing the output of
# AutoDocWorksheet for that worksheet.
#
# Then AUTODOC_TestWorkSheet will again run AutoDocWorksheet, put storing the
# output into `tst/worksheets/<ws>.actual`; it then runs diff on all files in
# order to find any differences that may have crept in. If no differences
# exist, it outputs nothing.
InstallGlobalFunction( AUTODOC_TestWorkSheet,
function(ws)
    local wsdir, sheetdir, expecteddir, actualdir, filenames, old, f, expected, actual;

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

    # create and clear the output directory
    actualdir := Filename(wsdir, Concatenation(ws, ".actual"));
    Exec(Concatenation("rm -rf \"", actualdir, "\""));
    AUTODOC_CreateDirIfMissing(actualdir);
    actualdir := Directory(actualdir);

    # Run the worksheet
    filenames := DirectoryContents(sheetdir);
    filenames := Filtered(filenames, f -> f <> "." and f <> "..");
    filenames := List(filenames, f -> Filename(sheetdir, f));

    old := InfoLevel(InfoGAPDoc);
    SetInfoLevel(InfoGAPDoc, 0);
    AutoDocWorksheet(filenames, rec(dir := actualdir, extract_examples := true));
    SetInfoLevel(InfoGAPDoc, old);

    # Check the results
    filenames := DirectoryContents(expecteddir);
    filenames := Filtered(filenames, f -> f <> "." and f <> "..");
    for f in filenames do
        expected := Filename(expecteddir, f);
        actual := Filename(actualdir, f);
        if 0 <> AUTODOC_Diff("-u", expected, actual) then
            Error("diff detected");
        fi;
    od;
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
# In each case, the year, month or day may be given as either an
# integer, or as a string representing an integer.
InstallGlobalFunction( AUTODOC_FormatDate,
function(arg)
    local date, key, val, result;
    if Length(arg) = 1 and IsRecord(arg[1]) then
        date := ShallowCopy(arg[1]);
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
    if not IsBound(date) then
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
