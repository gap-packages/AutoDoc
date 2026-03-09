# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

##
BindGlobal( "AUTODOC_IdentifierLetters",
            "+-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz" );

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
DeclareRepresentation( "IsTreeForDocumentationChunkNodeRep",
                       IsTreeForDocumentationNodeRep,
                       [ ] );

BindGlobal( "TheTypeOfDocumentationTreeChunkNodes",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationChunkNodeRep ) );

## DeclareRepresentation
DeclareRepresentation( "IsTreeForDocumentationVerbatimNodeRep",
                       IsTreeForDocumentationNodeRep,
                       [ ] );

BindGlobal( "TheTypeOfDocumentationTreeVerbatimNodes",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationVerbatimNodeRep ) );



###################################
##
## Tools
##
###################################

##
InstallGlobalFunction( AUTODOC_TREE_NODE_NAME_ITERATOR,
  function( tree )
    local curr_val;

    curr_val := tree!.node_name_iterator;
    tree!.node_name_iterator := curr_val + 1;
    return curr_val;
end );

##
InstallGlobalFunction( AUTODOC_LABEL_OF_CONTEXT,
  function( context )
    local label;
    if not IsList( context ) then
        Error( "wrong type of context" );
    fi;
    if IsString( context ) then
        label := context;
    elif Length( context ) = 1 then
        label := Concatenation( "Chapter_", context[ 1 ] );
    elif Length( context ) = 2 then
        label := Concatenation( "Chapter_", context[ 1 ], "_Section_", context[ 2 ] );
    elif Length( context ) = 3 then
        label := Concatenation( "Chapter_", context[ 1 ], "_Section_", context[ 2 ], "_Subsection_", context[ 3 ] );
    else
        Error( "wrong type of context" );
    fi;
    label := Filtered(label, x -> x in AUTODOC_IdentifierLetters);
    return label;
end );

###################################
##
## Constructors
##
###################################

##
InstallMethod( DocumentationTree, [ ],
  function( )
    local tree;

    tree := rec(
                  content := [ ],   # a list of nodes
                  nodes_by_label := rec( ),
                  node_name_iterator := 0,
                  TitlePage := rec( ),
                  chunks := rec( ),
            );
    ObjectifyWithAttributes( tree, TheTypeOfDocumentationTrees );
    return tree;
end );

## create a chapter, section or subsection
InstallMethod( StructurePartInTree, [ IsTreeForDocumentation, IsList ],
  function( tree, context )
    local label, parent, new_node, type;
    
    if IsEmpty( context ) then
        return tree;
    fi;

    # if the part already exist, use that
    label := AUTODOC_LABEL_OF_CONTEXT( context );
    if IsBound( tree!.nodes_by_label.( label ) ) then
        return tree!.nodes_by_label.( label );
    fi;

    parent := StructurePartInTree( tree, context{[1..Length(context)-1]} );

    new_node := rec( content := [ ],
                     name := context[ Length( context ) ],
                     chapter_info := context );
    if Length( context ) = 1 then
        type := TheTypeOfDocumentationTreeNodesForChapter;
    elif Length( context ) = 2 then
        type := TheTypeOfDocumentationTreeNodesForSection;
    elif Length( context ) = 3 then
        type := TheTypeOfDocumentationTreeNodesForSubsection;
    fi;
    ObjectifyWithAttributes( new_node, type, Label, label );

    tree!.nodes_by_label.( label ) := new_node;
    Add( parent!.content, new_node );
    return new_node;
end );

##
InstallMethod( DocumentationExample, [ IsTreeForDocumentation ],
  function( tree )
    return DocumentationExample( tree, "Example" );
end );

##
InstallMethod( DocumentationExample, [ IsTreeForDocumentation, IsString ],
  function( tree, element_name )
    local node;
    node := DocumentationVerbatim( tree, element_name, rec( ), [ ] );
    node!.closing_separator := "\n\n";
    return node;
end );

##
InstallMethod( DocumentationVerbatim, [ IsTreeForDocumentation, IsString, IsRecord, IsList ],
  function( tree, element_name, attributes, content )
    local node;

    node := rec( element_name := element_name,
                 attributes := StructuralCopy( attributes ),
                 content := ShallowCopy( content ) );
    node!.closing_separator := "\n";
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeVerbatimNodes );
    return node;
end );

##
InstallMethod( DocumentationVerbatim, [ IsString, IsRecord, IsList ],
  function( element_name, attributes, content )
    local node;

    node := rec( element_name := element_name,
                 attributes := StructuralCopy( attributes ),
                 content := ShallowCopy( content ) );
    node!.closing_separator := "\n";
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeVerbatimNodes );
    return node;
end );

##
InstallMethod( DocumentationChunk, [ IsTreeForDocumentation, IsString ],
  function( tree, name )
    local node;

    if IsBound( tree!.chunks.( name ) ) then
        return tree!.chunks.( name );
    fi;
    node := rec( content := [ ] );
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeChunkNodes,
                              Label, name );
    node!.is_defined := false;
    node!.is_inserted := false;
    tree!.chunks.( name ) := node;
    return node;
end );

##
InstallMethod( DocumentationManItem, [ IsTreeForDocumentation ],
  function( tree )
    local node, name;

    node := rec( description := [ ],
                 return_value := [ ] );
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeNodesForManItem );
    name := Concatenation( "ManItem_", String( AUTODOC_TREE_NODE_NAME_ITERATOR( tree ) ) );
    tree!.nodes_by_label.( name ) := node;
    node!.content := node!.description;
    return node;
end );

##
InstallMethod( SetManItemToDescription, [ IsTreeForDocumentationNodeForManItemRep ],
  function( node )
    node!.content := node!.description;
end );

##
InstallMethod( SetManItemToReturnValue, [ IsTreeForDocumentationNodeForManItemRep ],
  function( node )
    node!.content := node!.return_value;
end );

##
InstallMethod( DocumentationGroup, [ IsTreeForDocumentation, IsString ],
  function( tree, group_name )
    local group, name;

    name := Concatenation( "GROUP_", group_name );
    if IsBound( tree!.nodes_by_label.( name ) ) then
        return tree!.nodes_by_label.( name );
    fi;
    group := rec( content := [ ] );
    ObjectifyWithAttributes( group, TheTypeOfDocumentationTreeNodesForGroup,
                             Label, name );
    tree!.nodes_by_label.( name ) := group;
    group!.is_added := false;
    return group;
end );

##
InstallMethod( DocumentationGroup, [ IsTreeForDocumentation, IsString, IsList ],
  function( tree, group_name, context )
    local name, group, context_node;

    name := Concatenation( "GROUP_", group_name );
    if IsBound( tree!.nodes_by_label.( name ) ) then
        return tree!.nodes_by_label.( name );
    fi;
    context_node := StructurePartInTree( tree, context );
    group := DocumentationGroup( tree, group_name );
    Add( context_node, group );
    group!.is_added := true;
    return group;
end );

##
InstallMethod( Add, [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ],
  function( parent_node, node )
    Add( parent_node!.content, node );
end );

##
InstallMethod( Add, [ IsTreeForDocumentationNode, IsString ],
  function( parent_node, string )
    Add( parent_node!.content, string );
end );

##
InstallMethod( Add, [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasChapterInfo ],
  function( tree, node )
    local chapter_info, section;
    chapter_info := ChapterInfo( node );
    section := SectionInTree( tree, chapter_info[ 1 ], chapter_info[ 2 ] );
    Add( section, node );
end );

##
InstallMethod( Add, [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasGroupName ],
  function( tree, node )
    local group;
    group := DocumentationGroup( tree, GroupName( node ) );
    Add( group, node );
end );

##
InstallMethod( Add, [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasGroupName and HasChapterInfo ],
  function( tree, node )
    local chapter_info, group;
    chapter_info := ChapterInfo( node );
    group := DocumentationGroup( tree, GroupName( node ), chapter_info );
    Add( group, node );
end );

##
InstallMethod( Add, [ IsTreeForDocumentation, IsTreeForDocumentationNode, IsList ],
  function( tree, node, context )
    local context_node;
    context_node := StructurePartInTree( tree, context );
    Add( context_node, node );
end );

##
InstallMethod( IsEmptyNode, [ IsTreeForDocumentationNode ],
  function( node )
    if IsBound( node!.content ) then
        return ForAll( node!.content, IsEmptyNode );
    fi;
    return false;
end );

##
InstallMethod( IsEmptyNode, [ IsString ],
  function( node )
    return node = "";
end );

##
InstallMethod( IsEmptyNode, [ IsTreeForDocumentationNodeForManItemRep ],
  function( node )
    return false;
end );

####################################
##
## Add functions
##
####################################

## 
InstallMethod( ChapterInTree, [ IsTreeForDocumentation, IsString ],
  function( tree, name )
    return StructurePartInTree( tree, [ name ] );
end );

##
InstallMethod( SectionInTree, [ IsTreeForDocumentation, IsString, IsString ],
  function( tree, chapter_name, section_name )
    return StructurePartInTree( tree, [ chapter_name, section_name ] );
end );

##
InstallMethod( SubsectionInTree, [ IsTreeForDocumentation, IsString, IsString, IsString ],
  function( tree, chapter_name, section_name, subsection_name )
    return StructurePartInTree( tree, [ chapter_name, section_name, subsection_name ] );
end );

#############################################
##
## Write functions
##
#############################################

BindGlobal( "AUTODOC_WriteStructuralNode",
  function( node, element_name, stream )
    local heading;

    if ForAll( node!.content, IsEmptyNode ) then
        return false;
    fi;

    if IsBound( node!.title_string ) then
        heading := NormalizedWhitespace( node!.title_string );
    else
        heading := ReplacedString( node!.name, "_", " " );
    fi;

    AppendTo( stream, "<", element_name, " Label=\"", Label( node ), "\">\n" );
    AppendTo( stream, "<Heading>", heading, "</Heading>\n\n" );
    WriteDocumentation( node!.content, stream );
    AppendTo( stream, "</", element_name, ">\n\n" );
    return true;
end );

BindGlobal( "AUTODOC_ChapterFilename",
  function( node )
    local filename;

    # Remove any characters outside of A-Za-z0-9 and -, +, _ from the filename.
    # See issues #77 and #78
    filename := Filtered( Label( node ), x -> x in AUTODOC_IdentifierLetters );
    return Concatenation( "_", filename, ".xml" );
end );

BindGlobal( "WriteChunks",
  function( tree, path_to_xmlfiles )
    local chunks_stream, filename, chunk_names, current_chunk_name,
          current_chunk;

    filename := "_Chunks.xml";

    chunks_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    chunk_names := RecNames( tree!.chunks );

    for current_chunk_name in chunk_names do
        current_chunk := tree!.chunks.( current_chunk_name );
        if current_chunk!.is_defined = true and current_chunk!.is_inserted = false then
            Info(
                InfoAutoDoc,
                1,
                "WARNING: chunk ",
                current_chunk_name,
                " was defined but never inserted"
            );
        elif current_chunk!.is_defined = false and current_chunk!.is_inserted = true then
            Info(
                InfoAutoDoc,
                1,
                "WARNING: chunk ",
                current_chunk_name,
                " was inserted but never defined"
            );
        fi;
        AppendTo( chunks_stream, "<#GAPDoc Label=\"", current_chunk_name, "\">\n" );
        if IsBound( current_chunk!.content ) then
            WriteDocumentation( current_chunk!.content, chunks_stream );
        fi;
        AppendTo( chunks_stream, "\n<#/GAPDoc>\n" );
    od;

    CloseStream( chunks_stream );

end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentation, IsDirectory ],
  function( tree, path_to_xmlfiles )
    local stream, i;

    stream := AUTODOC_OutputTextFile( path_to_xmlfiles, _AUTODOC_GLOBAL_OPTION_RECORD.AutoDocMainFile );
    AppendTo( stream, AUTODOC_XML_HEADER );
    for i in tree!.content do
        if not IsTreeForDocumentationNodeForChapterRep( i ) then
            Error( "this should never happen" );
        fi;
        ## FIXME: If there is anything else than a chapter, this will break!
        WriteDocumentation( i, stream, path_to_xmlfiles );
    od;

    WriteChunks( tree, path_to_xmlfiles );

    # Workaround for issue #65
    if IsEmpty( tree!.content ) then
        AppendTo( stream, "&nbsp;\n" );
    fi;
    CloseStream( stream );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForChapterRep, IsStream, IsDirectory ],
  function( node, stream, path_to_xmlfiles )
    local filename, chapter_stream;

    if ForAll( node!.content, IsEmptyNode ) then
        return;
    fi;

    filename := AUTODOC_ChapterFilename( node );
    chapter_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    AppendTo( stream, "<#Include SYSTEM \"", filename, "\">\n" );
    AppendTo( chapter_stream, AUTODOC_XML_HEADER );
    AUTODOC_WriteStructuralNode( node, "Chapter", chapter_stream );
    CloseStream( chapter_stream );
end );

##
InstallMethod( WriteDocumentation, [ IsList, IsStream ],
  function( node_list, filestream )
    local current_string_list, i, FlushConvertedStrings;

    FlushConvertedStrings := function()
        local converted_string_list, in_cdata, item;
        if current_string_list = [ ] then
            return;
        fi;
        converted_string_list := AUTODOC_ConvertMarkdownToGAPDocXML( current_string_list );
        in_cdata := false;
        for item in converted_string_list do
            if not IsString( item ) then
                WriteDocumentation( item, filestream );
                continue;
            fi;
            if AUTODOC_LineStartsCDATA( item ) then
                in_cdata := true;
            fi;
            if in_cdata = true then
                AppendTo( filestream, Chomp( item ), "\n" );
            else
                WriteDocumentation( item, filestream );
            fi;
            if AUTODOC_LineEndsCDATA( item ) then
                in_cdata := false;
            fi;
        od;
        current_string_list := [ ];
    end;

    i := 1;
    current_string_list := [ ];
    for i in [ 1 .. Length( node_list ) ] do
        if IsString( node_list[ i ] ) then
            Add( current_string_list, ShallowCopy( node_list[ i ] ) );
        else
            FlushConvertedStrings();
            WriteDocumentation( node_list[ i ], filestream );
        fi;
    od;
    FlushConvertedStrings();
end );

##
InstallMethod( WriteDocumentation, [ IsString, IsStream ],
  function( text, filestream )
    ## In case the list is empty, do nothing.
    ## Once the empty string = empty list bug is fixed,
    ## this could be removed.
    text := Chomp( text );
    if NormalizedWhitespace( text ) = "" then
        return;
    fi;
    AppendTo( filestream, text, "\n" );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForSectionRep, IsStream ],
  function( node, filestream )
    AUTODOC_WriteStructuralNode( node, "Section", filestream );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForSubsectionRep, IsStream ],
  function( node, filestream )
    AUTODOC_WriteStructuralNode( node, "Subsection", filestream );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForManItemRep, IsStream ],
  function( node, filestream )
    AutoDoc_WriteDocEntry( filestream, [ node ], fail );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForGroupRep, IsStream ],
  function( node, filestream )
    local heading;
    heading := fail;
    if IsBound( node!.title_string ) then
        heading := node!.title_string;
    fi;
    AutoDoc_WriteDocEntry( filestream, node!.content, heading );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationChunkNodeRep, IsStream ],
  function( node, filestream )
    node!.is_inserted := true;
    WriteDocumentation( Concatenation( "<#Include Label=\"", Label( node ), "\">" ), filestream );
end );

InstallMethod( WriteDocumentation, [ IsTreeForDocumentationVerbatimNodeRep, IsStream ],
  function( node, filestream )
    AUTODOC_WriteCDATASection(
        filestream,
        node!.element_name,
        node!.content,
        node!.attributes,
        node!.closing_separator
    );
end );
