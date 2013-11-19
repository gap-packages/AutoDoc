#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareCategory( "IsContextObjectForDocumentation",
                 IsObject );

#########################################
##
## Operations
##
#########################################

DeclareOperation( "ContextObject",
                  [ ] );  

DeclareOperation( "GetCurrentContext",
                  [ IsContextObjectForDocumentation ] );

DeclareOperation( "SetNewContext",
                  [ IsContextObjectForDocumentation, IsList ] );

DeclareOperation( "LastContext",
                  [ IsContextObjectForDocumentation ] );

DeclareOperation( "SetChapter",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetSection",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetSubsection",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetManItem",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetManItemPart",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetGroup",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetChunk",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetSystem",
                  [ IsContextObjectForDocumentation, IsString ] );

DeclareOperation( "SetExample",
                  [ IsContextObjectForDocumentation, IsString ] );
