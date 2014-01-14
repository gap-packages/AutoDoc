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
InstallGlobalFunction( AUTODOC_TRANSLATE_CONTEXT,
                       
  function( context )
    
    if not IsList( context ) then
        
        Error( "wrong type of context" );
        
    fi;
    
    if IsString( context ) then
        
        return context;
        
    fi;
    
    if Length( context ) = 1 then
        
        return Concatenation( "Chapter_", context[ 1 ] );
        
    elif Length( context ) = 2 then
        
        return Concatenation( "Chapter_", context[ 1 ], "_Section_", context[ 2 ] );
        
    elif Length( context ) = 3 then
        
        return Concatenation( "Chapter_", context[ 1 ], "_Section_", context[ 2 ], "_Subsection_", context[ 3 ] );
        
    else
        
        Error( "wrong type of context" );
        
    fi;
    
end );

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
                  contents_for_dummies := rec( ),
                  node_name_iterator := 0,
                  current_level := 0,
                  TitlePage := rec( )
            );
    
    ObjectifyWithAttributes( tree,
                             TheTypeOfDocumentationTrees );
    
    return tree;
    
end );

InstallMethod( DocumentationStructurePart,
               [ IsTreeForDocumentation, IsList ],
               
  function( tree, chapter_info )
    
    return DocumentationStructurePart( tree, rec( chapter_info := chapter_info ) );
    
end );

##
## This method creates chapters, sections, subsections.
InstallMethod( DocumentationStructurePart,
               [ IsTreeForDocumentation, IsRecord ],
               
  function( tree, record )
    local chapter_info, structure_obj, name, obj_name, type;
    
    if not IsBound( record.chapter_info ) or not IsList( record.chapter_info ) or Length( record.chapter_info ) < 1 then
        
        Error( "name of chapter must be given" );
        
    fi;
    
    structure_obj := record;
    
    structure_obj.level := tree!.current_level;
    
    chapter_info := structure_obj.chapter_info;
    
    if not ForAll( chapter_info, IsString ) then
        
        Error( "chapter info must be list of strings" );
        
    fi;
    
    if Length( chapter_info ) = 1 then
        
        type := TheTypeOfDocumentationTreeNodesForChapter;
        
    elif Length( chapter_info ) = 2 then
        
        type := TheTypeOfDocumentationTreeNodesForSection;
        
    elif Length( chapter_info ) = 3 then
        
        type := TheTypeOfDocumentationTreeNodesForSubsection;
        
    fi;
    
    obj_name := AUTODOC_TRANSLATE_CONTEXT( chapter_info );
    
    name := chapter_info[ Length( chapter_info ) ];
    
    structure_obj.name := name;
    
    structure_obj.content := [ ];
    
    ObjectifyWithAttributes( structure_obj, type,
                             Name, obj_name,
                             IsEmptyNode, true
                           );
    
    tree!.nodes_by_name.( Name( structure_obj ) ) := structure_obj;
    
    return structure_obj;
    
end );

##
InstallMethod( DocumentationExample,
               [ IsTreeForDocumentation, IsList ],
               
  function( tree, context )
    local node;
    
    node := DocumentationExample( tree );
    
    Add( tree, node, context );
    
    return node;
    
end );

##
InstallMethod( DocumentationExample,
               [ IsTreeForDocumentation ],
               
  function( tree )
    local node;
    
    node := rec( content := [ ],
                 level := tree!.current_level );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeExampleNodes,
                             Name, Concatenation( "Example_", String( AUTODOC_TREE_NODE_NAME_ITERATOR( tree ) ) ) );
    
    tree!.nodes_by_name.( Name( node ) ) := node;
    
    return node;
    
end );

##
InstallMethod( DocumentationDummy,
               [ IsTreeForDocumentation, IsString, IsList ],
               
  function( tree, name, context )
    local node;
    
    node := DocumentationDummy( tree, name );
    
    Add( tree, node, context );
    
    return node;
    
end );

##
InstallMethod( DocumentationDummy,
               [ IsTreeForDocumentation, IsString ],
               
  function( tree, name )
    local node;
    
    name := Concatenation( "System_", name );
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    node := rec( content := [ ],
                  level := tree!.current_level );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeDummyNodes,
                              Name, name );
    
    tree!.nodes_by_name.( name ) := node;
    
    return node;
    
end );

##
InstallMethod( DocumentationManItem,
               [ IsTreeForDocumentation ],
               
  function( tree )
    local node, name;
    
    node := rec( description := [ ],
                 return_value := [ ],
                 level := tree!.current_level );
    
    ObjectifyWithAttributes( node, TheTypeOfDocumentationTreeNodesForManItem );
    
    name := Concatenation( "ManItem_", String( AUTODOC_TREE_NODE_NAME_ITERATOR( tree ) ) );
    
    tree!.nodes_by_name.( name ) := node;
    
    node!.content := node!.description;
    
    return node;
    
end );

##
InstallMethod( SetManItemToDescription,
               [ IsTreeForDocumentationNodeForManItemRep ],
               
  function( node )
    
    node!.content := node!.description;
    
end );

##
InstallMethod( SetManItemToReturnValue,
               [ IsTreeForDocumentationNodeForManItemRep ],
               
  function( node )
    
    node!.content := node!.return_value;
    
end );

##
InstallMethod( DocumentationGroup,
               [ IsTreeForDocumentation, IsString ],
               
  function( tree, group_name )
    local group, name;
    
    name := Concatenation( "GROUP_", group_name );
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    group := rec( content := [ ],
                  level := tree!.current_level
    );
    
    ObjectifyWithAttributes( group, TheTypeOfDocumentationTreeNodesForGroup,
                             Name, name );
    
    tree!.nodes_by_name.( name ) := group;
    
    group!.is_added := false;
    
    return group;
    
end );

##
InstallMethod( DocumentationGroup,
               [ IsTreeForDocumentation, IsString, IsList ],
               
  function( tree, group_name, context )
    local name, group;
    
    name := Concatenation( "GROUP_", group_name );
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    context := AUTODOC_TRANSLATE_CONTEXT( context );
    
    group := DocumentationGroup( tree, group_name );
    
    Add( tree!.nodes_by_name.( context ), group );
    
    group!.is_added := true;
    
    return group;
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ],
               
  function( insert_node, node )
    
    Add( insert_node!.content, node );
    
    ResetFilterObj( insert_node, IsEmptyNode );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentationNode, IsString ],
               
  function( insert_node, string )
    
    Add( insert_node!.content, string );
    
    ResetFilterObj( insert_node, IsEmptyNode );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasChapterInfo ],
               
  function( tree, node )
    local section;
    
    section := SectionInTree( tree, ChapterInfo( node )[ 1 ], ChapterInfo( node )[ 2 ] );
    
    Add( section, node );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasGroupName ],
               
  function( tree, node )
    local group;
    
    group := DocumentationGroup( tree, GroupName( node ) );
    
    Add( group, node );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentation, IsTreeForDocumentationNodeForManItemRep and HasGroupName and HasChapterInfo ],
               
  function( tree, node )
    local chapter_info, group;
    
    chapter_info := ChapterInfo( node );
    
    group := DocumentationGroup( tree, GroupName( node ), chapter_info );
    
    Add( group, node );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentation, IsTreeForDocumentationNode, IsList ],
               
  function( tree, node, context )
    local insert_node;
    
    insert_node := AUTODOC_TRANSLATE_CONTEXT( context );
    
    insert_node := tree!.nodes_by_name.(insert_node);
    
    Add( insert_node, node );
    
end );

##
InstallMethod( Add,
               [ IsTreeForDocumentation, IsString ],
               
  function( tree, string )
    
    Add( tree!.content, string );
    
end );

InstallGlobalFunction( AUTODOC_INSTALL_TREE_SETTERS,
                       
  function( )
    local method_installer, current_string, string_list;
    
    string_list := [ "Title", "Subtitle", "Version", "TitleComment", "Author", 
                     "Date", "Address", "Abstract", "Copyright", "Acknowledgements", "Colophon" ];
    
    
    method_installer := function( current_string )
        local method_name_part, method_name;
        
        method_name_part := "SetTreeTo";
        
        method_name := Concatenation( method_name_part, current_string );
        
        DeclareOperation( method_name,
                          [ IsTreeForDocumentation ] );
        
        method_name := ValueGlobal( method_name );
        
        InstallMethod( method_name,
                       [ IsTreeForDocumentation ],
                       
          function( tree )
            
            if not IsBound( tree!.TitlePage.( current_string ) ) then
                
                tree!.TitlePage.( current_string ) := [ ];
                
            fi;
            
            tree!.content := tree!.TitlePage.( current_string );
            
        end );
        
    end;
    
    for current_string in string_list do
        
        method_installer( current_string );
        
    od;
    
end );

AUTODOC_INSTALL_TREE_SETTERS();

####################################
##
## Add functions
##
####################################

InstallMethod( ChapterInTree,
               [ IsTreeForDocumentation, IsString ],
               
  function( tree, name )
    local chapter;
    
    if IsBound( tree!.nodes_by_name.( Concatenation( "Chapter_", name ) ) ) then
        
        return tree!.nodes_by_name.( Concatenation( "Chapter_", name ) );
        
    fi;
    
    chapter := DocumentationStructurePart( tree, [ name ] );
    
    Add( tree!.nodes, chapter );
    
    return chapter;
    
end );

##
InstallMethod( SectionInTree,
               [ IsTreeForDocumentation, IsString, IsString ],
               
  function( tree, chapter_name, section_name )
    local name, chapter, section;
    
    name := Concatenation( "Chapter_", chapter_name, "_Section_", section_name );
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    chapter := ChapterInTree( tree, chapter_name );
    
    section := DocumentationStructurePart( tree, [ chapter_name, section_name ] );
    
    Add( chapter!.content, section );
    
    return section;
    
end );

##
InstallMethod( SubsectionInTree,
               [ IsTreeForDocumentation, IsString, IsString, IsString ],
               
  function( tree, chapter_name, section_name, subsection_name )
    local name, section, subsection;
    
    name := Concatenation( "Chapter_", chapter_name, "_Section_", section_name, "_Subsection_", subsection_name );
    
    if IsBound( tree!.nodes_by_name.( name ) ) then
        
        return tree!.nodes_by_name.( name );
        
    fi;
    
    section := SectionInTree( tree, chapter_name, section_name );
    
    subsection := DocumentationStructurePart( tree, [ chapter_name, section_name, subsection_name ] );
    
    Add( section!.content, subsection );
    
    return subsection;
    
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
    
    if ForAll( node!.content, IsEmptyNode ) then
        
        return;
        
    fi;
    
    filename := Concatenation( name, ".xml" );
    
    chapter_stream := AUTODOC_OutputTextFile( path_to_xmlfiles, filename );
    
    AppendTo( stream, "<#Include SYSTEM \"", filename, "\">\n" );
    
    AppendTo( chapter_stream, AUTODOC_XML_HEADER );
    
    AppendTo( chapter_stream, "<Chapter Label=\"", name,"\">\n" );
    
    replaced_name := ReplacedString( node!.name, "_", " " );
    
    AppendTo( chapter_stream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    WriteDocumentation( node!.content, chapter_stream );
    
    AppendTo( chapter_stream, "</Chapter>\n\n" );
    
    CloseStream( chapter_stream );
    
end );

InstallMethod( WriteDocumentation,
               [ IsList, IsStream ],
               
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
InstallMethod( WriteDocumentation,
               [ IsString, IsStream ],
               
  function( text, filestream )
    
    ## In case the list is empty, do nothing.
    ## Once the empty string = empty list bug is fixed,
    ## this could be removed.
    
    NormalizeWhitespace( text );
    
    if text = "" then
        
        return;
        
    fi;
    
    AppendTo( filestream, " ", text, "\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForSectionRep, IsStream ],
               
  function( node, filestream )
    local name, replaced_name, i;
    
    name := Name( node );
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    if ForAll( node!.content, IsEmptyNode ) then
        
        return;
        
    fi;
    
    AppendTo( filestream, "<Section Label=\"", Name( node ), "\">\n" );
    
    replaced_name := ReplacedString( node!.name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    WriteDocumentation( node!.content, filestream );
    
    AppendTo( filestream, "</Section>\n\n" );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForSubsectionRep, IsStream ],
               
  function( node, filestream )
    local i, name, replaced_name;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    if ForAll( node!.content, IsEmptyNode ) then
        
        return;
        
    fi;
    
    AppendTo( filestream, "<Subsection Label=\"", Name( node ), "\">\n" );
    
    replaced_name := ReplacedString( node!.name, "_", " " );
    
    AppendTo( filestream, Concatenation( [ "<Heading>", replaced_name, "</Heading>\n\n" ] ) );
    
    WriteDocumentation( node!.content, filestream );
    
    AppendTo( filestream, "</Subsection>\n\n" );
    
end );

#
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForManItemRep, IsStream ],
               
  function( node, filestream )
    local entry_record;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    AutoDoc_WriteDocEntry( filestream, [ node ] );
    
end );

#
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationNodeForGroupRep, IsStream ],
               
  function( node, filestream )
    local entry_list;
    
    if node!.level > ValueOption( "level_value" ) then
        
        return;
        
    fi;
    
    AutoDoc_WriteDocEntry( filestream, node!.content );
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationDummyNodeRep, IsStream ],
               
  function( node, filestream )
    local i;
    
    if IsBound( node!.content ) then
        
        WriteDocumentation( node!.content, filestream );
        
    fi;
    
end );

##
InstallMethod( WriteDocumentation,
               [ IsTreeForDocumentationExampleNodeRep, IsStream ],
               
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