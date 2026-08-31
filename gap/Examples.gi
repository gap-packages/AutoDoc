# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

# Environment variable equivalent of the AutoDocExtractOnly global option. It
# exists so that a makedoc.g ending in QUIT can still be driven, by running it
# as a separate GAP process.
BindGlobal( "AUTODOC_EXTRACT_ONLY_ENVVAR", "AUTODOC_EXTRACT_ONLY" );

BindGlobal( "AUTODOC_DEFAULT_MAKEDOC_FILE", "makedoc.g" );

# The scratch directory to work in, or fail if AutoDoc should build the manual
# normally. Both spellings carry the directory; passing just `true` or `1`
# asks for extract-only mode without naming one.
InstallGlobalFunction( "AUTODOC_ExtractOnlyDirectory",
function()
    local value;

    value := ValueOption( "AutoDocExtractOnly" );
    if value = fail and
       IsBound( GAPInfo.SystemEnvironment.( AUTODOC_EXTRACT_ONLY_ENVVAR ) ) then
        value := GAPInfo.SystemEnvironment.( AUTODOC_EXTRACT_ONLY_ENVVAR );
    fi;

    if value = fail or value = false then
        return fail;
    fi;

    if IsDirectory( value ) then
        return value;
    fi;

    if value = true or value = "" or value = "1" then
        return DirectoryTemporary();
    fi;

    if not IsString( value ) then
        Error( "AutoDocExtractOnly must be true, a path, or a directory object" );
    fi;

    AUTODOC_CreateDirIfMissing( value );
    return Directory( value );
end );

##
InstallGlobalFunction( "AutoDocExtractExamples",
function( pkg, makedoc... )
    local pkgdir, script, scratch, olddir, chdir;

    if Length( makedoc ) > 0 then
        script := makedoc[ 1 ];
    else
        script := AUTODOC_DEFAULT_MAKEDOC_FILE;
    fi;

    if IsDirectory( pkg ) then
        pkgdir := pkg;
    elif IsString( pkg ) then
        pkgdir := DirectoriesPackageLibrary( pkg, "" );
        if pkgdir = [ ] then
            Error( "could not locate package ", pkg );
        fi;
        pkgdir := pkgdir[ 1 ];
    else
        Error( "pkg must be a package name or a directory object" );
    fi;

    script := Filename( pkgdir, script );
    if script = fail or not IsReadableFile( script ) then
        Error( "could not read ", script );
    fi;

    scratch := DirectoryTemporary();

    # AutoDoc() with no arguments picks up PackageInfo.g from the working
    # directory, and makedoc.g scripts name their inputs relative to the
    # package, so run the script from there.
    #
    # ChangeDirectoryCurrent needs GAP >= 4.13, or the io package on older
    # versions; look it up by name so that reading this file does not warn
    # about an unbound global where it is missing. Passing <script> as an
    # absolute path still lets AutoDoc locate the package without it.
    chdir := fail;
    if IsBoundGlobal( "ChangeDirectoryCurrent" ) then
        chdir := ValueGlobal( "ChangeDirectoryCurrent" );
    fi;

    if chdir = fail then
        Info( InfoAutoDoc, 1,
              "cannot change the working directory: if ", script,
              " reads further files by relative path, those reads will fail; ",
              "load the io package, or use GAP 4.13 or newer" );
        Read( script : AutoDocExtractOnly := scratch, nopdf );
    else
        olddir := AUTODOC_CurrentDirectory();
        chdir( Filename( pkgdir, "" ) );
        Read( script : AutoDocExtractOnly := scratch, nopdf );
        chdir( olddir );
    fi;

    return Directory( Filename( scratch, "tst" ) );
end );
