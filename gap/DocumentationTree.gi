#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareRepresentation( "IsTreeForDocumentationRep",
        IsAttributeStoringRep and IsTreeForDocumentation,
        [ ] );

BindGlobal( "TheFamilyOfDocumentationTrees",
        NewFamily( "TheFamilyOfDocumentationTrees" ) );

BindGlobal( "TheTypeOfDocumentationTrees",
        NewType( TheFamilyOfDocumentationTrees,
                IsTreeForDocumentationRep ) );

## Metatype, specify later
DeclareRepresentation( "IsTreeForDocumentationNodeRep",
        IsAttributeStoringRep and IsTreeForDocumentationNode,
        [ ] );

BindGlobal( "TheFamilyOfDocumentationTreeNodes",
        NewFamily( "TheFamilyOfDocumentationTreeNodes" ) );

BindGlobal( "TheTypeOfDocumentationTreeNodes",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeRep ) );

## Chapter node
DeclareRepresentation( "IsTreeForDocumentationNodeForChapterRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForChapter",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForChapterRep ) );

## Section node
DeclareRepresentation( "IsTreeForDocumentationNodeForSectionRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForSection",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForSectionRep ) );

## Subsection node
DeclareRepresentation( "IsTreeForDocumentationNodeForSubsectionRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForSubsection",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForSubsectionRep ) );

## Text node
DeclareRepresentation( "IsTreeForDocumentationNodeForTextRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForText",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForTextRep ) );

## ManItem node
DeclareRepresentation( "IsTreeForDocumentationNodeForManItemRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForManItem",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForManItemRep ) );

## Group Node
DeclareRepresentation( "IsTreeForDocumentationNodeForGroupRep",
        IsTreeForDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForGroup",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationNodeForGroupRep ) );

## DeclareRepresentation
DeclareRepresentation( "IsTreeForDocumentationDummyNodeRep",
                       IsTreeForDocumentationNodeRep,
                       [ ] );

BindGlobal( "TheTypeOfDocumentationTreeDummyNodes", 
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationDummyNodeRep ) );

## DeclareRepresentation
DeclareRepresentation( "IsTreeForDocumentationExampleNodeRep",
                       IsTreeForDocumentationNodeRep,
                       [ ] );

BindGlobal( "TheTypeOfDocumentationTreeExampleNodes", 
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationExampleNodeRep ) );

###################################
##
## Constructors
##
###################################

##
InstallMethod( DocumentationTree,
               [ ],
               
  function( )
    local tree;
    
    tree := rec(
                  nodes := [ ],
                  nodes_by_name := rec( ),
                  groups := rec( ),
                  dummies := rec( ),
                  contents_for_dummies := rec( ),
                  chunks := rec( )
            );
    
    ObjectifyWithAttributes( tree,
                             TheTypeOfDocumentationTrees );
    
    return tree;
    
end );

##
InstallMethod( DocumentationChapter,
               [ IsString ],
               
  function( name )
    local level, chapter;
    
    level := ValueOption( "level_value" );
    
    if level = fail then
        
        level := 0;
        
    fi;
    
    chapter := rec(
                    nodes := [ ],
                    nodes_by_name := rec( ),
                    level := level
               );
    
    ObjectifyWithAttributes( chapter,
                             TheTypeOfDocumentationTreeNodesForChapter,
                             Name, name,
                             IsEmptyNode, true
                             );
    
    return chapter;
    
end );

##
InstallMethod( DocumentationSection,
               [ IsString ],
               
  function( name )
    local level, section;
    
    level := ValueOption( "level_value" );
    
    if level = fail then
        
        level := 0;
        
    fi;
    
    section := rec( 
                    nodes := [ ],
                    nodes_by_name := rec( ),
                    level := level
               );
    
    ObjectifyWithAttributes( section,
                             TheTypeOfDocumentationTreeNodesForSection,
                             Name, name,
                             IsEmptyNode, true
                             );
    
    return section;
    
end );

##
InstallMethod( DocumentationSubsection,
               [ IsString ],
               
  function( name )
    local level, subsection;
    
    level := ValueOption( "level_value" );
    
    if level = fail then
        
        level := 0;
        
    fi;
    
    subsection := rec( nodes := [ ],
                       nodes_by_name := rec( ),
                       level := level );
    
    ObjectifyWithAttributes( subsection,
                             TheTypeOfDocumentationTreeNodesForSubsection,
                             Name, name,
                             IsEmptyNode, true
                            );
    
    return subsection;
    
end );

##
InstallMethod( DocumentationNode,
               [ IsRecord ],
               
  function( content )
    local node, type;
    
    if not IsBound( content.node_type ) then
        
        Error( "node type must be set to create node" );
        
    fi;
    
    type := content.node_type;
    
    if type = "TEXT" then
        
        node := DocumentationText( content.text, content.chapter_info );
        
    elif type = "ITEM" then
        
        node := DocumentationItem( content );
        
    elif type = "EXAMPLE" then
        
        node := DocumentationExample( content.text, content.chapter_info );
        
    elif type = "DUMMY" then
        
        node := DocumentationDummy( content.name, content.chapter_info );
        
    else
        
        Error( "unrecognised type" );
        
    fi;
    
    node!.level := content.level;
    
    return node;
    
end );

##
InstallMethod( DocumentationText,
               [ IsList, IsList ],
               
  function( text, chapter_info )
    local level, textnode;
    
    textnode := rec( content := text,
                     level := 0 );
    
    ObjectifyWithAttributes( textnode,
                             TheTypeOfDocumentationTreeNodesForText,
                             ChapterInfo, chapter_info
                           );
    
    return textnode;
    
end );

##
InstallMethod( DocumentationItem,
               [ IsRecord ],
               
  function( entry_rec )
    local level, item, group;
    
    item := rec( content := entry_rec,
                 level := 0 );
    
    if IsBound( entry_rec.group ) then
        
        item := rec( content_list := [ entry_rec ],
                     level := 0 );
        
        ObjectifyWithAttributes( item,
                                 TheTypeOfDocumentationTreeNodesForGroup,
                                 Name, entry_rec.group,
                                 ChapterInfo, entry_rec.chapter_info );
        
    else
        
        ObjectifyWithAttributes( item,
                                 TheTypeOfDocumentationTreeNodesForManItem,
                                 ChapterInfo, entry_rec.chapter_info );
        
    fi;
    
    return item;
    
end );

##
InstallMethod( DocumentationExample,
               [ IsList, IsList ],
               
  function( string_list, chapter_info )
    local level, node;
    
    node := rec( content := string_list,
                 level := 0 );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeExampleNodes,
                             ChapterInfo, chapter_info );
    
    return node;
    
end );

## This method is going to have side effects on its first argument.
## So no readding would be necessary. This should only be used internally.
## The side effects are also the reason why this is not called Concatenation.
##
InstallMethod( MergeGroupEntries,
               [ IsTreeForDocumentationNodeForGroupRep, IsTreeForDocumentationNodeForGroupRep ],
               
  function( group1, group2 )
    local entry_rec;
    
    if Name( group1 ) <> Name( group2 ) then
        
        Error( "groups of different name cannot be merged." );
        
    fi;
    
    group1!.content_list := Concatenation( group1!.content_list, group2!.content_list );
    
end );

InstallMethod( DocumentationDummy,
               [ IsString, IsList ],
               
  function( name, chapter_info )
    local node;
    
    node := rec( chapter_info := chapter_info,
                 level := 0 );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeDummyNodes,
                             Name, name );
    
    return node;
    
end );

####################################
##
## Add functions
##
####################################

InstallMethod( ChapterInTree,
               [ IsTreeForDocumentation, IsString ],
               
  function( tree, name )
    local chapter;
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    chapter := DocumentationChapter( name );
    
    Add( tree!.nodes, chapter );
    
    tree!.nodes_by_name.( name ) := chapter;
    
    return chapter;
    
end );

##
InstallMethod( SectionInTree,
               [ IsTreeForDocumentation, IsString, IsString ],
               
  function( tree, chapter_name, section_name )
    local chapter, section;
    
    chapter := ChapterInTree( tree, chapter_name );
    
    if IsBound( chapter!.nodes_by_name.( section_name ) ) then
        
        return chapter!.nodes_by_name.( section_name );
        
    fi;
    
    section := DocumentationSection( section_name );
    
    Add( chapter!.nodes, section );
    
    chapter!.nodes_by_name.( section_name ) := section;
    
    return section;
    
end );

##
InstallMethod( SubsectionInTree,
               [ IsTreeForDocumentation, IsString, IsString, IsString ],
               
  function( tree, chapter_name, section_name, subsection_name )
    local section, subsection;
    
    section := SectionInTree( tree, chapter_name, section_name );
    
    if IsBound( section!.nodes_by_name.( subsection_name ) ) then
        
        return section!.nodes_by_name.( subsection_name );
        
    fi;
    
    subsection := DocumentationSubsection( subsection_name );
    
    Add( section!.nodes, subsection );
    
    section!.nodes_by_name.( subsection_name ) := subsection;
    
    return subsection;
    
end );

##
InstallMethod( EntryNode,
               [ IsTreeForDocumentation, IsList ],
               
  function( tree, chapter_info )
    local length, arg_array;
    
    length := Length( chapter_info );
    
    arg_array := Concatenation( [ tree ], chapter_info );
    
    if length = 1 then
        
        return CallFuncList( ChapterInTree, arg_array );
        
    elif length = 2 then
        
        return CallFuncList( SectionInTree, arg_array );
        
    elif length = 3 then
        
        return CallFuncList( SubsectionInTree, arg_array );
        
    else
        
        Error( "bad chapter_info type" );
        
    fi;
    
end );

##
InstallMethod( Add,
               "for dummy fillers",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeRep and HasDummyName ],
               
  function( tree, node )
    local name;
    
    name := Name( node );
    
    if IsBound( tree!.dummies.(name) ) then
        
        tree!.dummies!.(name).content := node;
        
    else
        
        tree!.contents_for_dummies.(name) := node;
        
    fi;
    
end );

##
InstallMethod( Add,
               "for text nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForTextRep ],
               
  function( tree, node )
    local chapter_info, entry_node;
    
    if node!.content = [ ] then
        
        return;
        
    fi;
    
    chapter_info := ChapterInfo( node );
    
    entry_node := EntryNode( tree, chapter_info );
    
    ResetFilterObj( entry_node, IsEmptyNode );
    
    Add( entry_node!.nodes, node );
    
end );

##
InstallMethod( Add,
               "for example nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationExampleNodeRep ],
               
  function( tree, node )
    local chapter_info, entry_node;
    
    chapter_info := ChapterInfo( node );
    
    entry_node := EntryNode( tree, chapter_info );
    
    ResetFilterObj( entry_node, IsEmptyNode );
    
    Add( entry_node!.nodes, node );
    
end );

##
InstallMethod( Add,
               "for manitem nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep ],
               
  function( tree, node )
    local chapter_info, entry_node;
    
    chapter_info := ChapterInfo( node );
    
    if Length( chapter_info ) <> 2 then
        
        Error( "ManItem must be contained in section" );
        
    fi;
    
    entry_node := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
    
    ResetFilterObj( entry_node, IsEmptyNode );
    
    Add( entry_node!.nodes, node );
    
end );

##
InstallMethod( Add,
               "for group nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForGroupRep ],
               
  function( tree, node )
    local name, chapter_info, entry_node;
    
    name := Name( node );
    
    if IsBound( tree!.groups.( name ) ) then
        
        MergeGroupEntries( tree!.groups.( name ), node );
        
        return;
        
    fi;
    
    chapter_info := ChapterInfo( node );
    
    entry_node := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
    
    tree!.groups.( name ) := node;
    
    Add( entry_node!.nodes, node );
    
    ResetFilterObj( entry_node, IsEmptyNode );
    
    ## FIXME: This might be irrelevant.
    entry_node!.nodes_by_name.( name ) := node;
    
end );

##
InstallMethod( Add,
               "for dummy nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationDummyNodeRep ],
               
  function( tree, node )
    local name, entry_node, chapter_info;
    
    chapter_info := node!.chapter_info;
    
    name := Name( node );
    
    if IsBound( tree!.contents_for_dummies.(name) ) then
        
        node!.content := tree!.contents_for_dummies.(name);
        
    fi;
    
    entry_node := EntryNode( tree, chapter_info );
    
    Add( entry_node!.nodes, node );
    
    entry_node!.nodes_by_name.(name) := node;
    
    ResetFilterObj( entry_node, IsEmptyNode );
    
    tree!.dummies.(name) := node;
    
end );

#############################################
##
## Write functions
##
#############################################

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentation, IsDirectory ],
               
  function( tree, path_to_xmlfiles )
    local stream, i;
    
    stream := AUTODOC_OutputTextFile( path_to_xmlfiles, "AutoDocMainFile.xml" );
    
    AppendTo( stream, AUTODOC_XML_HEADER );
    
    for i in tree!.nodes do
        
        if not IsTreeForDocumentationNodeForChapterRep( i ) then
            
            Error( "this should never happen" );
            
        fi;
        
        ## FIXME: If there is anything else than a chapter, this will break!
        WriteDocumentation( i, stream, path_to_xmlfiles );
        
    od;
    
    CloseStream( stream );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForChapterRep, IsStream, IsDirectory ],
               
  function( node, stream, path_to_xmlfiles )
    local filename, chapter_stream, name, replaced_name, i;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    name := Name( node );
    
    if ForAll( node!.nodes, IsEmptyNode ) then
        
        return;
        
    fi;
    
    filename := Concatenation( "Chapter_", name, ".xml" );
    
    chapter_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    
    AppendTo( stream, "<#Include SYSTEM \"", filename, "\">\n" );
    
    AppendTo( chapter_stream, AUTODOC_XML_HEADER );
    
    AppendTo( chapter_stream, "<Chapter Label=\"Chapter_", name, "_automatically_generated_documentation_parts\">\n" );
    
    replaced_name := ReplacedString( name, "_", " " );
    
    AppendTo( chapter_stream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    for i in node!.nodes do
        
        WriteDocumentation( i, chapter_stream, name );
        
    od;
    
    AppendTo( chapter_stream, "</Chapter>\n\n" );
    
    CloseStream( chapter_stream );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForTextRep, IsStream ],
               
  function( node, filestream )
    local text, i, level;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    text := node!.content;
    
    ## In case the list is empty, do nothing.
    ## Once the empty string = empty list bug is fixed,
    ## this could be removed.
    if text = "" then
        
        return;
        
    fi;
    
    if IsString( text ) then
        
        text := [ text ];
        
    fi;
    
    for i in text do
        
        AppendTo( filestream, " ", i, "\n" );
        
    od;
    
    AppendTo( filestream, "\n\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForTextRep, IsStream, IsString ],
               
  ##Please note that chapter_name is for sections only. It will be discarded.
  function( node, filestream, chapter_name )
    
    WriteDocumentation( node, filestream );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForSectionRep, IsStream, IsString ],
               
  function( node, filestream, chapter_name )
    local name, replaced_name, i;
    
    name := Name( node );
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    if ForAll( node!.nodes, IsEmptyNode ) then
        
        return;
        
    fi;
    
    AppendTo( filestream, Concatenation( [ "<Section Label=\"Chapter_", chapter_name, "_Section_", name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    replaced_name := ReplacedString( name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    for i in node!.nodes do
        
        if IsTreeForDocumentationNodeForSubsectionRep( i ) then
            
            WriteDocumentation( i, filestream, chapter_name, name );
            
        else
            
            WriteDocumentation( i, filestream );
            
        fi;
        
    od;
    
    AppendTo( filestream, "</Section>\n\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForSubsectionRep, IsStream, IsString, IsString ],
               
  function( node, filestream, chapter_name, section_name )
    local i, name, replaced_name;

    name := Name( node );
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    if ForAll( node!.nodes, IsEmptyNode ) then
        
        return;
        
    fi;
    
    AppendTo( filestream, Concatenation( [ "<Subsection Label=\"Chapter_", chapter_name, "_Section_", section_name, "_Subsection_", name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    replaced_name := ReplacedString( name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    for i in node!.nodes do
        
        WriteDocumentation( i, filestream );
        
    od;
    
    AppendTo( filestream, "</Subsection>\n\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForManItemRep, IsStream ],
               
  function( node, filestream )
    local entry_record;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    entry_record := node!.content;
    
    AutoDoc_WriteDocEntry( filestream, [ entry_record ] );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForGroupRep, IsStream ],
               
  function( node, filestream )
    local entry_list;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    entry_list := node!.content_list;
    
    AutoDoc_WriteDocEntry( filestream, entry_list );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationDummyNodeRep, IsStream ],
               
  function( node, filestream )
    
    if IsBound( node!.content ) then
        
        WriteDocumentation( node!.content, filestream );
        
    fi;
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationExampleNodeRep, IsStream ],
               
  function( node, filestream )
    local contents, i;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    contents := node!.content;
    
    AppendTo( filestream, "<Example><![CDATA[\n" );
    
    for i in contents do
        
        AppendTo( filestream, i, "\n" );
        
    od;
    
    AppendTo( filestream, "]]></Example>\n\n" );
    
end );