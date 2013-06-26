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


##  <#GAPDoc Label="CreateDocEntryForCategory">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ]" Name="CreateDocEntryForCategory"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CreateDocEntryForCategory" );

##  <#GAPDoc Label="CreateDocEntryForRepresentation">
##  <ManSection>
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], function" Name="CreateDocEntryForRepresentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateDocEntryForRepresentation" );

##  <#GAPDoc Label="CreateDocEntryForOperation">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ]" Name="CreateDocEntryForOperation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the method. It is not optional.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attributes of the operation.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this method
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateDocEntryForOperation" );

##  <#GAPDoc Label="CreateDocEntryForAttribute">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ]" Name="CreateDocEntryForAttribute"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the attribute. It is not optional.
##      <A>argument</A> is an optional string which is displayed in the documentation as attribute of the attribute.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this attribute
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateDocEntryForAttribute" );

##  <#GAPDoc Label="CreateDocEntryForProperty">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ]" Name="CreateDocEntryForProperty"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this property
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateDocEntryForProperty" );

