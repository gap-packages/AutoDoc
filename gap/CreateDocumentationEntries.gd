#############################################################################
##
##  CreateDocumentationEntry.gd                      AutoDoc package
##
##  Copyright 2007-2013,   Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, University of Kaiserslautern
##
##  A new way to create Methods.
##
#############################################################################


##
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForCategory"/>
DeclareGlobalFunction( "CreateDocEntryForCategory" );

##
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForRepresentation"/>
DeclareGlobalFunction( "CreateDocEntryForRepresentation" );

##
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForOperation"/>
DeclareGlobalFunction( "CreateDocEntryForOperation" );

##
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForAttribute"/>
DeclareGlobalFunction( "CreateDocEntryForAttribute" );

##
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForProperty"/>
DeclareGlobalFunction( "CreateDocEntryForProperty" );

DeclareGlobalFunction( "CreateDocEntryForGlobalFunction" );

DeclareGlobalFunction( "CreateDocEntryForGlobalVariable" );

DeclareGlobalFunction( "CreateDocEntryForInstallMethod" );

