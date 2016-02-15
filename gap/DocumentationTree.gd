#############################################################################
##
##  AutoDoc package
##
##  Copyright 2012-2016
##    Sebastian Gutsche, University of Kaiserslautern
##    Max Horn, Justus-Liebig-Universität Gießen
##
## Licensed under the GPL 2 or later.
##
#############################################################################

######################################
##
## Tools
##
######################################

DeclareGlobalFunction( "AUTODOC_TREE_NODE_NAME_ITERATOR" );
DeclareGlobalFunction( "AUTODOC_LABEL_OF_CONTEXT" );
DeclareGlobalFunction( "AUTODOC_INSTALL_TREE_SETTERS" );

######################################
##
## Categories
##
######################################

DeclareCategory( "IsTreeForDocumentation", IsObject );
DeclareCategory( "IsTreeForDocumentationNode", IsObject );

######################################
##
## Attributes
##
######################################

DeclareOperation( "IsEmptyNode", [ IsTreeForDocumentationNode ] );
DeclareOperation( "IsEmptyNode", [ IsString ] );
DeclareAttribute( "Label", IsTreeForDocumentationNode );
DeclareAttribute( "ChapterInfo", IsTreeForDocumentationNode );
DeclareAttribute( "DummyName", IsTreeForDocumentationNode );
DeclareAttribute( "GroupName", IsTreeForDocumentationNode );

######################################
##
## Constructors
##
######################################

DeclareOperation( "DocumentationTree", [ ] );
DeclareOperation( "StructurePartInTree", [ IsTreeForDocumentation, IsList ] );
DeclareOperation( "ChapterInTree", [ IsTreeForDocumentation, IsString ] );
DeclareOperation( "SectionInTree", [ IsTreeForDocumentation, IsString, IsString ] );
DeclareOperation( "SubsectionInTree", [ IsTreeForDocumentation, IsString, IsString, IsString ] );
DeclareOperation( "DocumentationExample", [ IsTreeForDocumentation, IsList ] );
DeclareOperation( "DocumentationExample", [ IsTreeForDocumentation ] );
DeclareOperation( "DocumentationDummy", [ IsTreeForDocumentation, IsString, IsList ] );
DeclareOperation( "DocumentationDummy", [ IsTreeForDocumentation, IsString ] );
DeclareOperation( "DocumentationManItem", [ IsTreeForDocumentation ] );
DeclareOperation( "SetManItemToDescription", [ IsTreeForDocumentationNode ] );
DeclareOperation( "SetManItemToReturnValue", [ IsTreeForDocumentationNode ] );
DeclareOperation( "DocumentationGroup", [ IsTreeForDocumentation, IsString ] );
DeclareOperation( "DocumentationGroup", [ IsTreeForDocumentation, IsString, IsList ] );
DeclareOperation( "Add", [ IsTreeForDocumentation, IsTreeForDocumentationNode ] );
DeclareOperation( "Add", [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ] );
DeclareOperation( "Add", [ IsTreeForDocumentation, IsTreeForDocumentationNode, IsList ] );
DeclareOperation( "Add", [ IsTreeForDocumentation, IsTreeForDocumentationNode, IsString ] );
DeclareOperation( "Add", [ IsTreeForDocumentationNode, IsString ] );
DeclareOperation( "MergeGroupEntries", [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ] );
DeclareOperation( "Add", [ IsTreeForDocumentation, IsString ] );

#######################################
##
## Write methods
##
#######################################

DeclareOperation( "WriteDocumentation", [ IsTreeForDocumentation, IsDirectory ] );
DeclareOperation( "WriteDocumentation", [ IsTreeForDocumentationNode, IsStream ] );
DeclareOperation( "WriteDocumentation", [ IsList, IsStream ] );
DeclareOperation( "WriteDocumentation", [ IsTreeForDocumentationNode, IsStream, IsDirectory ] );
