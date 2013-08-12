#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareCategory( "IsTreeForDocumentation",
                 IsObject );

DeclareCategory( "IsTreeForDocumentationNode",
                 IsObject );

######################################
##
## Attributes
##
######################################

DeclareAttribute( "Name",
                  IsTreeForDocumentationNode );

DeclareAttribute( "ChapterInfo",
                  IsTreeForDocumentationNode );

######################################
##
## Constructors
##
######################################

DeclareOperation( "DocumentationTree",
                  [ ] );

DeclareOperation( "DocumentationChapter",
                  [ IsString ] );

DeclareOperation( "DocumentationSection",
                  [ IsString ] );

DeclareOperation( "DocumentationText",
                  [ IsList, IsList ] );

DeclareOperation( "DocumentationItem",
                  [ IsRecord ] );

######################################
##
## Build methods
##
######################################

DeclareOperation( "ChapterInTree",
                  [ IsTreeForDocumentation, IsString ] );

DeclareOperation( "SectionInTree",
                  [ IsTreeForDocumentation, IsString, IsString ] );

DeclareOperation( "GroupInTree",
                  [ IsTreeForDocumentation, IsString ] );

DeclareOperation( "Add",
                  [ IsTreeForDocumentation, IsTreeForDocumentationNode ] );

DeclareOperation( "MergeGroupEntries",
                  [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ] );

#######################################
##
## Write methods
##
#######################################

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentation, IsDirectory ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream, IsString ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream, IsDirectory ] );
