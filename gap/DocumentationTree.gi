#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareRepresentation( "IsTreeforDocumentationRep",
        IsAttributeStoringRep,
        [ ] );

BindGlobal( "TheFamilyOfDocumentationTrees",
        NewFamily( "TheFamilyOfDocumentationTrees" ) );

BindGlobal( "TheTypeOfDocumentationTrees",
        NewType( TheFamilyOfDocumentationTrees,
                IsTreeforDocumentationRep ) );

## Metatype, specify later
DeclareRepresentation( "IsTreeforDocumentationNodeRep",
        IsAttributeStoringRep,
        [ ] );

BindGlobal( "TheFamilyOfDocumentationTreeNodes",
        NewFamily( "TheFamilyOfDocumentationTreeNodes" ) );

BindGlobal( "TheTypeOfDocumentationTreeNodes",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeRep ) );

## Chapter node
DeclareRepresentation( "IsTreeforDocumentationNodeForChapterRep",
        IsTreeforDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForChapter",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeForChapterRep ) );

## Section node
DeclareRepresentation( "IsTreeforDocumentationNodeForSectionRep",
        IsTreeforDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForSection",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeForSectionRep ) );

## Text node
DeclareRepresentation( "IsTreeforDocumentationNodeForTextRep",
        IsTreeforDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForText",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeForTextRep ) );

## ManItem node
DeclareRepresentation( "IsTreeforDocumentationNodeForManItemRep",
        IsTreeforDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForManItem",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeForManItemRep ) );

## Group Node
DeclareRepresentation( "IsTreeforDocumentationNodeForGroupRep",
        IsTreeforDocumentationNodeRep,
        [ ] );

BindGlobal( "TheTypeOfDocumentationTreeNodesForGroup",
        NewType( TheFamilyOfDocumentationTreeNodes,
                IsTreeforDocumentationNodeForGroupRep ) );


InstallGlobalFunction( CreateTree@,
                       
  function( arg )
    local main_rec;
    
    if IsBound( AUTOMATIC_DOCUMENTATION.doc_tree ) then
        
        return AUTOMATIC_DOCUMENTATION.doc_tree;
        
    fi;
    
    main_rec := rec( entry_list := [ ] );
    
    AUTOMATIC_DOCUMENTATION.doc_tree := main_rec;
    
    return main_rec;
    
end );

InstallGlobalFunction( CreateChapter@,
                       
  function( chapter_name )
    local tree_rec, chapter_rec;
    
    tree_rec := CreateTree@( );
    
    if IsBound( tree_rec.(chapter_name) ) then
        
        return AUTOMATIC_DOCUMENTATION.doc_tree;
        
    fi;
    
    
    