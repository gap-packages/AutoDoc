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

##  <#GAPDoc Label="AUTOMATIC_DOCUMENTATION">
##  <ManSection>
##    <Var Name="AUTOMATIC_DOCUMENTATION"/>
##    <Description>
##      This global variable stores all the streams and some additional data,
##      like chapter names.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalVariable( "AUTOMATIC_DOCUMENTATION" );


##  <#GAPDoc Label="CreateAutoDoc">
##  <ManSection>
##    <Func Arg="package_name, documentation_file, path_to_xml_file,create_full_docu[,section_intros]" Name="CreateAutoDoc"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This is the main method of the package. After loading the package, run it with the name of the pacckage
##      you want to create a documentation of as first argument, with an (empty) filepath (everything will be overwritten) as second argument.
##      Make sure you have included this file as source if you run your GAPDoc documentation creating script.
##      The third argument is a path to the directory where it can store the GAPDoc XML files. The path MUST end with a slash. 
##      It will produce several files out of the
##      Declare*WithDocumentation declarations you have used in your package <A>package_name</A>, and one named AutoDocMainFile.xml,
##      which you can simply include to your documentation.
##      <A>create_full_docu</A> can either be true or false. If true, a full documentation with title file is created. The only thing left
##      for you to do is run GAPDoc and provide a bibliography.
##      <A>section_intros</A> is optional, it must be a list containing lists of of either two or three strings. If two are given, first one must be
##      a chapter title, with underscores instead of spaces, and the second one a string which will be displayed in the documentation at the beginning of
##      the chapter. If three are given, first one must be a chapter, second a section, third the description.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CreateAutomaticDocumentation" );

##
## This function creates a title file. It must be called with the package name and the path to doc files.
DeclareGlobalFunction( "CreateTitlePage" );

##
## This function creates the main page. Do not call it out of context.
DeclareGlobalFunction( "CreateMainPage" );

##
## This function is for internal use only.
## It creates names for the default chapters and sections.
DeclareGlobalFunction( "CreateDefaultChapterData" );

##
## This function is for internal use only.
## It creates streams for new chapters and prepares the xml file.
DeclareGlobalFunction( "CreateNewChapterXMLFile" );

##
## This function is for internal use only.
## It creates streams for new sections and prepares the xml file.
DeclareGlobalFunction( "CreateNewSectionXMLFile" );

##  <#GAPDoc Label="DeclareCategoryWithDocumentation">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ]" Name="DeclareCategoryWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a category, like DeclareCategory( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
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
DeclareGlobalFunction( "DeclareCategoryWithDocumentation" );

##  <#GAPDoc Label="DeclareOperationWithDocumentation">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ]" Name="DeclareOperationWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a operation, like DeclareOperation( <A>name</A>, <A>list_of_filters</A> ) would do. The description string is added to the documentation
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
DeclareGlobalFunction( "DeclareOperationWithDocumentation" );

##  <#GAPDoc Label="DeclareAttributeWithDocumentation">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ]" Name="DeclareAttributeWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares an attribute, like DeclareAttribute( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
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
DeclareGlobalFunction( "DeclareAttributeWithDocumentation" );

##  <#GAPDoc Label="DeclarePropertyWithDocumentation">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ]" Name="DeclarePropertyWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a property, like DeclareProperty( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
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
DeclareGlobalFunction( "DeclarePropertyWithDocumentation" );

##  <#GAPDoc Label="DeclareGlobalFunctionWithDocumentation">
##  <ManSection>
##    <Func Arg="name, description, return_value [ arguments ], [ chapter_and_section ]" Name="DeclareGlobalFunctionWithDocumentation"/>
##    <Returns><C>true</C></Returns>
##    <Description>
##      This method declares a global function like DeclareGlobalFunction( <A>name</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. 
##      Lists will be concatenated with a space between them.<A>return_value</A> is a string displayed as the return value of the function. It is not optional.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attributes of the operation.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this function
##      should be displayed in the automatic generated documentation. There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
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
