# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later


DeclareGlobalVariable( "AUTODOC_XML_HEADER" );
DeclareGlobalFunction( "AUTODOC_SetIfMissing" );
DeclareGlobalFunction( "AUTODOC_APPEND_STRING_ITERATIVE" );
DeclareGlobalFunction( "AUTODOC_MergeRecords" );
DeclareGlobalFunction( "AUTODOC_PROCESS_INTRO_STRINGS" );
DeclareGlobalFunction( "AutoDocScanFiles" );

## Global option record
DeclareGlobalVariable( "_AUTODOC_GLOBAL_OPTION_RECORD" );

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

DeclareGlobalFunction( "CreateMakeTest" );



#! @Chapter AutoDoc worksheets
#! @Section Worksheets

#! @Description
#!  The intention of these function is to create stand-alone pdf and html files
#!  using AutoDoc without having them associated to a package.
#!  It uses the same optional records as the &AutoDoc; command itself, but instead of
#!  a package name there should be a filename or a list of filenames containing AutoDoc
#!  text from which the documents are created. Please see the &AutoDoc; command for more
#!  information about this and have a look at <Ref Label="Tut:AutoDocWorksheet"/> for a simple worksheet example.
#! @Arguments list_of_filenames : options
DeclareGlobalFunction( "AutoDocWorksheet" );
