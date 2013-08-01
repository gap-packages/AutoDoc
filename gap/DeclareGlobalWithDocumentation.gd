#############################################################################
##
##  AutoDoc package
##
##  Copyright 2007-2013,   Sebastian Gutsche, University of Kaiserslautern
##                         Max Horn, Justus-Liebig-Universität Gießen
##
##  
##
#############################################################################

##  <#GAPDoc Label="DeclareGlobalFunctionWithDocumentation">
##  <ManSection>
##    <Func Arg="name, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareGlobalFunctionWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a global function like DeclareGlobalFunction( <A>name</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. 
##      Lists will be concatenated with a space between them. <A>return_value</A> is a string displayed as the return value of the function. It is not optional.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attributes of the operation.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this function
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section. <A>option_record</A> can be a record with some options. The entry <A>group</A> must be a
##      string and will group functions with the same name together in the documentation. Their description will be concatenated, chapter and section info
##      of the first element in the group will be used. <A>label</A> will be the label of the element in the documentation. If you want to make a
##      reference to a specific entry, you need to set the label manually. Otherwise, this is not necessary. Please be careful. <A>function_label</A> allows
##      to set the label of the function manually. Normally, they would be the name of the testers of that attribute, for example for IsInt,IsList. This
##      manual setting can be done for reference purposes.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DeclareGlobalFunctionWithDocumentation" );

##  <#GAPDoc Label="DeclareGlobalVariableWithDocumentation">
##  <ManSection>
##    <Func Arg="name, description, [ chapter_and_section ]" Name="DeclareGlobalVariableWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a global variable like DeclareGlobalVariable( <A>name</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this variable
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DeclareGlobalVariableWithDocumentation" );