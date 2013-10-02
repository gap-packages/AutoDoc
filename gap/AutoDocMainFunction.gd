#############################################################################
##
##  AutoDoc package
##
##  Copyright 2007-2013,   Sebastian Gutsche, University of Kaiserslautern
##                         Max Horn, Justus-Liebig-Universität Gießen
##
##  
##
#############################################################################



# Documentation for this global variable can be found in gap/AutoDocDocEntries.g
# respectively in the manual.

DeclareGlobalVariable( "AUTOMATIC_DOCUMENTATION" );

DeclareGlobalVariable( "AUTODOC_XML_HEADER" );


# Documentation for this global function can be found in gap/AutoDocDocEntries.g
# respectively in the manual.
DeclareGlobalFunction( "CreateAutomaticDocumentation" );


# The following functions are currently undocumented and for internal use only.

##
## This function creates a title file. It must be called with the package name and the path to doc files.
DeclareGlobalFunction( "CreateTitlePage" );

##
## This function creates the main page. Do not call it out of context.
DeclareGlobalFunction( "CreateMainPage" );

##
## This function is for internal use only.
## It creates names for the default chapters and sections.
DeclareGlobalFunction( "CreateDefaultChapterData" );

DeclareGlobalFunction( "SetCurrentAutoDocChapter" );
DeclareGlobalFunction( "ResetCurrentAutoDocChapter" );


DeclareGlobalFunction( "SetCurrentAutoDocSection" );
DeclareGlobalFunction( "ResetCurrentAutoDocSection" );

DeclareGlobalFunction( "WriteStringIntoDoc" );

#! @Chapter AutoDoc worksheets
#! @Section Worksheets

#! @Description
#!  This function takes a filename and returns a complete GAPDoc document created
#!  out of the file. All AutoDoc commands can be used to create such a file. Also
#!  there are some special tags, which have only effect in files if the files are parsed with
#!  this command. Those commands are:
#!  <List>
#!  <Mark>Title <A>title</A></Mark>
#!  <Item>
#!    This adds a title to the document
#!  </Item>
#!  <Mark>Author <A>author</A></Mark>
#!  <Item>
#!    This adds an author to the document.
#!  </Item>
#!  </List>
#!  Note that some commands have no effect, i.e. the level command.
#! The options are as follows.
#! <List>
#! <Mark>BookName</Mark>
#! <Item>
#! The option BookName is an optional string, specifying the name of the manual book.
#! If there is no BookName, the title is used. If there is no title, the filename of
#! the first file is used.
#! </Item>
#! <Mark>TestFile</Mark>
#! <Item>
#! If TestFile is set to false, no testfile is produced. If TestFile is a string,
#! then it is used as name of the testfile. If nothing is given, the testfile will be
#! maketest.g
#! </Item>
#! <Mark>OutputFolder</Mark>
#! <Item>
#! All files will be stored in OutputFolder. If OutputFolder is not given, the folder of the first file will be used.
#! </Item>
#! <Mark>TestFileCommands</Mark>
#! <Item>
#! String or list of strings to be added at beginning of testfile.
#! </Item>
#! <Mark>Bibliography</Mark>
#! <Item>
#! Path to a bibliography file.
#! </Item>
#! </List>
#! @Arguments list_of_filenames : BookName, TestFile, OutputFolder, TestFileCommands, Bibliography
DeclareGlobalFunction( "AutoDocWorksheet" );
