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

DeclareFilter( "IsEmptyNode" );

DeclareAttribute( "Name",
                  IsTreeForDocumentationNode );

DeclareAttribute( "ChapterInfo",
                  IsTreeForDocumentationNode );

DeclareAttribute( "DummyName",
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

DeclareOperation( "DocumentationSubsection",
                  [ IsString ] );

## MetaOperation for the ones below.
DeclareOperation( "DocumentationNode",
                  [ IsRecord ] );

DeclareOperation( "DocumentationText",
                  [ IsList, IsList ] );

DeclareOperation( "DocumentationItem",
                  [ IsRecord ] );

DeclareOperation( "DocumentationDummy",
                  [ IsString, IsList ] );

DeclareOperation( "DocumentationExample",
                  [ IsList, IsList, IsBool ] );

######################################
##
## Build methods
##
######################################

DeclareOperation( "ChapterInTree",
                  [ IsTreeForDocumentation, IsString ] );

DeclareOperation( "SectionInTree",
                  [ IsTreeForDocumentation, IsString, IsString ] );

DeclareOperation( "SubsectionInTree",
                  [ IsTreeForDocumentation, IsString, IsString, IsString ] );

DeclareOperation( "EntryNode",
                  [ IsTreeForDocumentation, IsList ] );

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
                  [ IsTreeForDocumentationNode, IsStream, IsString, IsString ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream, IsDirectory ] );
