#############################################################################
##
##  InstallMethodWithDocumentation.gd         AutoDoc package
##
##  Copyright 2007-2012, Mohamed Barakat, University of Kaiserslautern
##                       Sebastian Gutsche, RWTH-Aachen University
##                  Markus Lange-Hegermann, RWTH-Aachen University
##
##  A new way to create Methods.
##
#############################################################################

##
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareCategoryWithDocumentation"/>
DeclareGlobalFunction( "DeclareCategoryWithDocumentation" );

##
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareOperationWithDocumentation"/>
DeclareGlobalFunction( "DeclareOperationWithDocumentation" );

##
##    <Func Arg="name, short_descr, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], func" Name="InstallMethodWithDocumentation"/>
DeclareGlobalFunction( "InstallMethodWithDocumentation" );

##
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareRepresentationWithDocumentation"/>
DeclareGlobalFunction( "DeclareRepresentationWithDocumentation" );

##
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="DeclareAttributeWithDocumentation"/>
DeclareGlobalFunction( "DeclareAttributeWithDocumentation" );

##
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclarePropertyWithDocumentation"/>
DeclareGlobalFunction( "DeclarePropertyWithDocumentation" );

##
##    <Func Arg="name, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareGlobalFunctionWithDocumentation"/>
DeclareGlobalFunction( "DeclareGlobalFunctionWithDocumentation" );

##
##    <Func Arg="name, description, [ chapter_and_section ]" Name="DeclareGlobalVariableWithDocumentation"/>
DeclareGlobalFunction( "DeclareGlobalVariableWithDocumentation" );
