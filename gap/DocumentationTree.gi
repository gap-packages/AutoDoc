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
                  groups := rec( )
            );
    
    ObjectifyWithAttributes( tree,
                             TheTypeOfDocumentationTrees );
    
    return tree;
    
end );

##
InstallMethod( DocumentationChapter,
               [ IsString ],
               
  function( name )
    local chapter;
    
    chapter := rec( 
                    nodes := [ ],
                    nodes_by_name := rec( )
               );
    
    ObjectifyWithAttributes( chapter,
                             TheTypeOfDocumentationTreeNodesForChapter,
                             Name, name
                             );
    
    return chapter;
    
end );

##
InstallMethod( DocumentationSection,
               [ IsString ],
               
  function( name )
    local section;
    
    section := rec( 
                    nodes := [ ],
                    nodes_by_name := rec( )
               );
    
    ObjectifyWithAttributes( section,
                             TheTypeOfDocumentationTreeNodesForSection,
                             Name, name
                             );
    
    return section;
    
end );

##
InstallMethod( DocumentationText,
               [ IsList, IsList ],
               
  function( text, chapter_info )
    local textnode;
    
    textnode := rec( content := text );
    
    ObjectifyWithAttributes( textnode,
                             TheTypeOfDocumentationTreeNodesForText,
                             ChapterInfo, chapter_info );
    
    return textnode;
    
end );

##
InstallMethod( DocumentationItem,
               [ IsRecord ],
               
  function( entry_rec )
    local item, group;
    
    item := rec( content := entry_rec );
    
    if IsBound( entry_rec.group ) then
        
        item := rec( content_list := [ entry_rec ] );
        
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
InstallMethod( Add,
               "for text nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForTextRep ],
               
  function( tree, node )
    local chapter_info, entry_node;
    
    chapter_info := ChapterInfo( node );
    
    if Length( chapter_info ) = 1 then
        
        entry_node := ChapterInTree( tree, chapter_info[ 1 ] );
        
    else
        
        entry_node := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
        
    fi;
    
    Add( entry_node!.nodes, node );
    
end );

##
InstallMethod( Add,
               "for manitem nodes",
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep ],
               
  function( tree, node )
    local chapter_info, entry_node;
    
    chapter_info := ChapterInfo( node );
    
    if Length( chapter_info ) < 2 then
        
        Error( "chapter info of ManItem must contain section" );
        
    fi;
    
    entry_node := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
    
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
    
    ## FIXME: This might be irrelevant.
    entry_node!.nodes_by_name.( name ) := node;
    
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
    
    name := Name( node );
    
    filename := Concatenation( "Chapter_", name, ".xml" );
    
    chapter_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    
    AppendTo( stream, Concatenation( "<#Include SYSTEM \"", filename, "\">\n" ) );
    
    AppendTo( chapter_stream, AUTODOC_XML_HEADER );
    
    AppendTo( chapter_stream, Concatenation( [ "<Chapter Label=\"Chapter_", name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
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
    local text, i;
    
    text := node!.content;
    
    if IsString( text ) then
        
        text := [ text ];
        
    fi;
    
    for i in text do
        
        AppendTo( filestream, " ", i, "\n" );
        
    od;
    
    AppendTo( filestream, "\n" );
    
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
    
    AppendTo( filestream, Concatenation( [ "<Section Label=\"Chapter_", chapter_name, "_Section_", name, "_automatically_generated_documentation_parts\">\n" ] ) );
    
    replaced_name := ReplacedString( name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    for i in node!.nodes do
        
        WriteDocumentation( i, filestream );
        
    od;
    
    AppendTo( filestream, "</Section>\n\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForManItemRep, IsStream ],
               
  function( node, filestream )
    local entry_record;
    
    entry_record := node!.content;
    
    AutoDoc_WriteDocEntry( filestream, [ entry_record ] );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForGroupRep, IsStream ],
               
  function( node, filestream )
    local entry_list;
    
    entry_list := node!.content_list;
    
    AutoDoc_WriteDocEntry( filestream, entry_list );
    
end );
