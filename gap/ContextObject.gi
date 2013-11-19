#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareRepresentation( "IsContextObjectForDocumentationRep",
        IsAttributeStoringRep and IsContextObjectForDocumentation,
        [ ] );

BindGlobal( "TheFamilyOfContextObjectsForDocumentation",
        NewFamily( "TheFamilyOfContextObjectsForDocumentation" ) );

BindGlobal( "TheTypeOfContextObjects",
        NewType( TheFamilyOfContextObjectsForDocumentation,
                IsContextObjectForDocumentationRep ) );

#############################
##
## Operations
##
#############################

##
InstallMethod( ContextObject,
               [ ],
               
  function( )
    local context_obj;
    
    context_obj := rec( current := [ ],
                        stack := [ ] );
    
    ObjectifyWithAttributes( context_obj, TheTypeOfContextObjects );
    
    return context_obj;
    
end );

##
InstallMethod( GetCurrentContext,
               [ IsContextObjectForDocumentation ],
               
  function( context )
    
    return context!.current;
    
end );

##
InstallMethod( SetNewContext,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, new_context )
    local old_context;
    
    old_context := context!.current;
    
    Add( context!.stack, old_context );
    
    context!.current := new_context;
    
end );

##
InstallMethod( LastContext,
               [ IsContextObjectForDocumentation ],
               
  function( context )
    local old_current;
    
    old_current := context!.current;
    
    context!.current := Remove( context!.stack );
    
    return old_current;
    
end );

##
InstallMethod( SetChapter,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, chapter )
    local chap_list;
    
    chap_list := [ [ "CHAPTER", chapter ] ];
    
    Add( context!.stack, context!.current );
    
    context!.current := chap_list;
    
end );

##
InstallMethod( SetSection,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, section )
    local sec_list;
    
    if Length( context!.current ) >= 1 and IsList( context!.current[ 1 ] ) and Length( context!.current[ 1 ] ) = 2 and context!.current[ 1 ][ 1 ] = "CHAPTER" then
        
        sec_list := [ ShallowCopy( context!.current[ 1 ] ), [ "SECTION", section ] ];
        
    else
        
        ##FIXME: Make this more modular.
        Error( "Chapter must be set for section" );
        
    fi;
    
    Add( context!.stack, context!.current );
    
    context!.current := sec_list;
    
end );

##
InstallMethod( SetSubsection,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, subsection )
    local sec_list;
    
    if Length( context!.current ) >= 2 and IsList( context!.current[ 2 ] ) and Length( context!.current[ 2 ] ) = 2 and context!.current[ 2 ][ 1 ] = "SECTION" then
        
        sec_list := [ ShallowCopy( context!.current[ 1 ] ), ShallowCopy( context!.current[ 2 ] ), [ "SUBSECTION", subsection ] ];
        
    else
        
        ##FIXME: Make this more modular.
        Error( "Section must be set for subsection" );
        
    fi;
    
    Add( context!.stack, context!.current );
    
    context!.current := sec_list;
    
end );

##
InstallMethod( SetManItem,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, manitem )
    local sec_list;
    
    if Length( context!.current ) >= 2 and IsList( context!.current[ 2 ] ) and Length( context!.current[ 2 ] ) = 2 and context!.current[ 2 ][ 1 ] = "SECTION" then
        
        sec_list := [ ShallowCopy( context!.current[ 1 ] ), ShallowCopy( context!.current[ 2 ] ), [ "MANITEM", manitem ] ];
        
    else
        
        ##FIXME: Make this more modular.
        Error( "Section must be set for ManItem" );
        
    fi;
    
    Add( context!.stack, context!.current );
    
    context!.current := sec_list;
    
end );

##
InstallMethod( SetManItemPart,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, manitem_part )
    local sec_list;
    
    if Length( context!.current ) >= 3 and IsList( context!.current[ 3 ] ) and Length( context!.current[ 3 ] ) = 2 and context!.current[ 3 ][ 1 ] = "MANITEM" then
        
        sec_list := [ ShallowCopy( context!.current[ 1 ] ), ShallowCopy( context!.current[ 2 ] ), ShallowCopy( context!.current[ 3 ] ), [ manitem_part ] ];
        
    else
        
        ##FIXME: Make this more modular.
        Error( "ManItem must be set for ManItemPart" );
        
    fi;
    
    Add( context!.stack, context!.current );
    
    context!.current := sec_list;
    
end );

##
InstallMethod( SetGroup,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, group )
    
    Add( context!.stack, context!.current );
    
    context!.current := [ [ "GROUP", group ] ];
    
end );

##
InstallMethod( SetChunk,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, chunk )
    
    Add( context!.stack, context!.current );
    
    context!.current := [ [ "CHUNK", chunk ] ];
    
end );

##
InstallMethod( SetSystem,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, system )
    
    Add( context!.stack, context!.current );
    
    context!.current := [ [ "SYSTEM", system ] ];
    
end );

##
InstallMethod( SetExample,
               [ IsContextObjectForDocumentation, IsString ],
               
  function( context, example )
    
    Add( context!.stack, context!.current );
    
    context!.current := [ [ "EXAMPLE", example ] ];
    
end );

########################################
##
## Display & View
##
########################################

##
InstallMethod( ViewObj,
               [ IsContextObjectForDocumentation ],
               
  function( context )
  
  Print( "<", context!.current, ">\n" );
  
end );

##
InstallMethod( Display,
               [ IsContextObjectForDocumentation ],
               
  function( context )
    local i;
    
    for i in context!.stack do
        
        Print( i, "\n" );
        
    od;
    
    Print( context!.current, "\n" );
    
end );
