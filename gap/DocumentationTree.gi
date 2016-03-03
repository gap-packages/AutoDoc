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

DeclareRepresentation( "IsTreeForDocumentationCodeNodeRep",
                       IsTreeForDocumentationNodeRep,
                       [ ] );

BindGlobal( "TheTypeOfDocumentationTreeCodeNodes",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeForDocumentationCodeNodeRep ) );

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
                  current_level := 0,
                  TitlePage := rec( )
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
                     level := tree!.current_level,
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
InstallMethod( DocumentationExample, [ IsTreeForDocumentation, IsList ],
  function( tree, context )
    local node;

    node := DocumentationExample( tree );
    Add( tree, node, context );
    return node;
end );

##
InstallMethod( DocumentationExample, [ IsTreeForDocumentation ],
  function( tree )
    local node, label;

    node := rec( content := [ ],
                 level := tree!.current_level );
    label := Concatenation( "Example_", String( AUTODOC_TREE_NODE_NAME_ITERATOR( tree ) ) );
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeExampleNodes,
                             Label, label );
    tree!.nodes_by_label.( label ) := node;
    return node;
end );

##
InstallMethod( DocumentationDummy, [ IsTreeForDocumentation, IsString, IsList ],
  function( tree, name, context )
    local node;

    node := DocumentationDummy( tree, name );
    Add( tree, node, context );
    return node;
end );

##
InstallMethod( DocumentationDummy, [ IsTreeForDocumentation, IsString ],
  function( tree, name )
    local node;

    name := Concatenation( "System_", name );
    if IsBound( tree!.nodes_by_label.( name ) ) then
        return tree!.nodes_by_label.( name );
    fi;
    node := rec( content := [ ],
                 level := tree!.current_level );
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeDummyNodes,
                              Label, name );
    tree!.nodes_by_label.( name ) := node;
    return node;
end );

##
InstallMethod( DocumentationCode, [ IsTreeForDocumentation, IsString, IsList ],
  function( tree, name, context )
    local node;
    
    node := DocumentationGroup( tree, name );
    Add( tree, node, context );
    return node;
end );

##
InstallMethod( DocumentationCode, [ IsTreeForDocumentation, IsString ],
  function( tree, name )
    local node;
    
    name := Concatenation( "System_", name );
    if IsBound( tree!.nodes_by_label.( name ) ) then
        return tree!.nodes_by_label.( name );
    fi;
    node := rec( content := [ ],
                 level := tree!.current_level );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeCodeNodes,
                             Label, name );
    tree!.nodes_by_label.( name ) := node;
    return node;
end );

##
InstallMethod( DocumentationManItem, [ IsTreeForDocumentation ],
  function( tree )
    local node, name;

    node := rec( description := [ ],
                 return_value := [ ],
                 level := tree!.current_level );
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
    group := rec( content := [ ],
                  level := tree!.current_level
    );
    ObjectifyWithAttributes( group, TheTypeOfDocumentationTreeNodesForGroup,
                             Label, name );
    tree!.nodes_by_label.( name ) := group;
    group!.is_added := false;
    return group;
end );

##
InstallMethod( DocumentationGroup, [ IsTreeForDocumentation, IsString, IsList ],
  function( tree, group_name, context )
    local name, group;

    name := Concatenation( "GROUP_", group_name );
    if IsBound( tree!.nodes_by_label.( name ) ) then
        return tree!.nodes_by_label.( name );
    fi;
    context := AUTODOC_LABEL_OF_CONTEXT( context );
    group := DocumentationGroup( tree, group_name );
    Add( tree!.nodes_by_label.( context ), group );
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
    local label, context_node;
    label := AUTODOC_LABEL_OF_CONTEXT( context );
    context_node := tree!.nodes_by_label.(label);
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
    # Workaround for issue #65
    if IsEmpty( tree!.content ) then
        AppendTo( stream, "&nbsp;\n" );
    fi;
    CloseStream( stream );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForChapterRep, IsStream, IsDirectory ],
  function( node, stream, path_to_xmlfiles )
    local filename, chapter_stream, label, replaced_name;

    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    if ForAll( node!.content, IsEmptyNode ) then
        return;
    fi;
    label := Label( node );

    # Remove any characters outside of A-Za-z0-9 and -, +, _ from the filename.
    # See issues #77 and #78
    filename := Filtered(label, x -> x in AUTODOC_IdentifierLetters);
    filename := Concatenation( "_", filename, ".xml" );

    chapter_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    AppendTo( stream, "<#Include SYSTEM \"", filename, "\">\n" );
    AppendTo( chapter_stream, AUTODOC_XML_HEADER );
    AppendTo( chapter_stream, "<Chapter Label=\"", label,"\">\n" );
    replaced_name := ReplacedString( node!.name, "_", " " );
    AppendTo( chapter_stream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    WriteDocumentation( node!.content, chapter_stream );
    AppendTo( chapter_stream, "</Chapter>\n\n" );
    CloseStream( chapter_stream );
end );

##
InstallMethod( WriteDocumentation, [ IsList, IsStream ],
  function( node_list, filestream )
    local current_string_list, i, last_position;

    i := 1;
    current_string_list := [ ];
    for i in [ 1 .. Length( node_list ) ] do
        if IsString( node_list[ i ] ) then
            Add( current_string_list, node_list[ i ] );
        else
            if current_string_list <> [ ] then
                current_string_list := CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML( current_string_list );
                Perform( current_string_list, function( i ) WriteDocumentation( i, filestream ); end );
                current_string_list := [ ];
            fi;
            WriteDocumentation( node_list[ i ], filestream );
            AppendTo( filestream, "\n" );
        fi;
    od;
    if current_string_list <> [ ] then
        current_string_list := CONVERT_LIST_OF_STRINGS_IN_MARKDOWN_TO_GAPDOC_XML( current_string_list );
        Perform( current_string_list, function( i ) WriteDocumentation( i, filestream ); end );
    fi;
end );

##
InstallMethod( WriteDocumentation, [ IsString, IsStream ],
  function( text, filestream )
    ## In case the list is empty, do nothing.
    ## Once the empty string = empty list bug is fixed,
    ## this could be removed.
    NormalizeWhitespace( text );
    if text = "" then
        return;
    fi;
    AppendTo( filestream, text, "\n" );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForSectionRep, IsStream ],
  function( node, filestream )
    local replaced_name;

    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    if ForAll( node!.content, IsEmptyNode ) then
        return;
    fi;
    AppendTo( filestream, "<Section Label=\"", Label( node ), "\">\n" );
    replaced_name := ReplacedString( node!.name, "_", " " );
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    WriteDocumentation( node!.content, filestream );
    AppendTo( filestream, "</Section>\n\n" );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForSubsectionRep, IsStream ],
  function( node, filestream )
    local replaced_name;

    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    if ForAll( node!.content, IsEmptyNode ) then
        return;
    fi;
    AppendTo( filestream, "<Subsection Label=\"", Label( node ), "\">\n" );
    replaced_name := ReplacedString( node!.name, "_", " " );
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    WriteDocumentation( node!.content, filestream );
    AppendTo( filestream, "</Subsection>\n\n" );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForManItemRep, IsStream ],
  function( node, filestream )
    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    AutoDoc_WriteDocEntry( filestream, [ node ] );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationNodeForGroupRep, IsStream ],
  function( node, filestream )
    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    AutoDoc_WriteDocEntry( filestream, node!.content );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationDummyNodeRep, IsStream ],
  function( node, filestream )
    if IsBound( node!.content ) then
        WriteDocumentation( node!.content, filestream );
    fi;
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationExampleNodeRep, IsStream ],
  function( node, filestream )
    local contents, i, tested, inserted_string;

    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    contents := node!.content;
    tested := node!.is_tested_example;
    if tested = true then
        inserted_string := "Example";
    elif tested = false then
        inserted_string := "Log";
    else
        Error( "This should not happen!" );
    fi;
    AppendTo( filestream, "<", inserted_string, "><![CDATA[\n" );
    for i in contents do
        AppendTo( filestream, i, "\n" );
    od;
    AppendTo( filestream, "]]></", inserted_string, ">\n\n" );
end );

##
InstallMethod( WriteDocumentation, [ IsTreeForDocumentationCodeNodeRep, IsStream ],
  function( node, filestream )
    local content, i;
    
    if node!.level > ValueOption( "level_value" ) then
        return;
    fi;
    
    content := node!.content;
    
    if content = [ ] then
        return;
    fi;
    
    AppendTo( filestream, "<Listing Type=\"Code\"><![CDATA[\n" );
    for i in content do
        AppendTo( filestream, i, "\n" );
    od;
    AppendTo( filestream, "]]></Listing>\n" );
end );
