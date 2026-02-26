# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later


BindGlobal( "AUTODOC_XML_HEADER",
    Concatenation(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\n",
    "<!-- This is an automatically generated file. -->\n"
    )
);

DeclareGlobalFunction( "AUTODOC_SetIfMissing" );
DeclareGlobalFunction( "AUTODOC_APPEND_STRING_ITERATIVE" );
DeclareGlobalFunction( "AUTODOC_MergeRecords" );
DeclareGlobalFunction( "AUTODOC_PROCESS_INTRO_STRINGS" );
DeclareGlobalFunction( "AutoDocScanFiles" );

## Global option record
BindGlobal( "_AUTODOC_GLOBAL_OPTION_RECORD",
              rec( AutoDocMainFile := "_AutoDocMainFile.xml" ) );

##
## This function creates a title file. It must be called with the package name and the path to doc files.
DeclareGlobalFunction( "CreateTitlePage" );

##
## This function creates _entities.xml, which is included by the default main page
DeclareGlobalFunction( "CreateEntitiesPage" );

##
## This function creates the main page. Do not call it out of context.
DeclareGlobalFunction( "CreateMainPage" );

##
## This function is for internal use only.
## It creates names for the default chapters and sections.
DeclareGlobalFunction( "CreateDefaultChapterData" );

DeclareGlobalFunction( "ExtractTitleInfoFromPackageInfo" );



#! @Chapter Reference
#! @Section AutoDoc worksheets
#! @SectionLabel AutoDocWorksheet

#! @Description
#!  The purpose of this function is to create stand-alone PDF and HTML files
#!  using &AutoDoc; without associating them with a package.
#!  <P/>
#!  It uses the same optional record entries as <Ref Func="AutoDoc"/>, but
#!  instead of a package name, you pass one filename or a list of filenames
#!  containing &AutoDoc; text from which the document is created.
#!  <P/>
#!  A simple worksheet file can define title-page information and chapter
#!  content directly in the source file, including example blocks.
#!  If this is stored in <F>worksheet.g</F>, you can generate documentation via
#!  @BeginLogSession
#!  AutoDocWorksheet( "worksheet.g" );
#!  @EndLogSession
#!  This creates documentation in a <F>doc</F> subdirectory of the current directory.
#!  <P/>
#!  Since worksheets do not have a <F>PackageInfo.g</F>, title-page fields are
#!  specified directly in the worksheet file.
#! @Arguments list_of_filenames : options
DeclareGlobalFunction( "AutoDocWorksheet" );
