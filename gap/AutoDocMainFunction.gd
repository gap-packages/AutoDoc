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



##
DeclareGlobalVariable( "AUTOMATIC_DOCUMENTATION" );



##    <Func Arg="package_name, documentation_file, path_to_xml_file,create_full_docu[,section_intros]" Name="CreateAutomaticDocumentation"/>
##
DeclareGlobalFunction( "CreateAutomaticDocumentation" );

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

##
## This function is for internal use only.
## It creates streams for new chapters and prepares the xml file.
DeclareGlobalFunction( "CreateNewChapterXMLFile" );

##
## This function is for internal use only.
## It creates streams for new sections and prepares the xml file.
DeclareGlobalFunction( "CreateNewSectionXMLFile" );
