##  <#GAPDoc Label="CreateAutomaticDocum7FF7CB7879E3103D">
##  <ManSection>
##    <Meth Arg="package_name, documentation_file, path_to_xml_file,create_full_docu[,section_intros]" Name="CreateAutomaticDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This is the main method of the package. After loading the package, run it with the name of the pacckage
##      you want to create a documentation of as first argument, with an (empty) filepath (everything will be overwritten) as second argument.
##      Make sure you have included this file as source if you run your GAPDoc documentation creating script.
##      The third argument is a path to the directory where it can store the GAPDoc XML files.
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

##  <#GAPDoc Label="AUTOMATIC_DOCUMENTAT83CB7952785A91C4">
##  <ManSection>
##    <Var Name="AUTOMATIC_DOCUMENTATION"/>
##    <Description>
##      This global variable stores all the streams and some additional data,
##      like chapter names.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareCategoryWithD7C8D33607AE49723">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareCategoryWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a category, like DeclareCategory( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
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

##  <#GAPDoc Label="InstallMethodWithDoc8134EA0F84DB234E">
##  <ManSection>
##    <Func Arg="name, short_descr, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], func" Name="InstallMethodWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method installs a method, like InstallMethod( <A>name</A>, <A>short_descr</A>, <A>list_of_filters</A>, <A>func</A> ) would do.
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

##  <#GAPDoc Label="DeclareOperationWith8193976E7AC2BE5F">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareOperationWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares an operation, like DeclareOperation( <A>name</A>, <A>list_of_filters</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the method. It is not optional.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attributes of the operation.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this method
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

##  <#GAPDoc Label="DeclareRepresentatio862151237C040CD1">
##  <ManSection>
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareRepresentationWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a representation, like DeclareRepresentation( <A>name</A>, <A>filter</A>, <A>list_of_req_entries</A> )
##      would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
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

##  <#GAPDoc Label="DeclareAttributeWith781F75A87FBC15EC">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="DeclareAttributeWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares an attribute, like DeclareAttribute( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the attribute. It is not optional.
##      <A>argument</A> is an optional string which is displayed in the documentation as attribute of the attribute.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this attribute
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

##  <#GAPDoc Label="DeclarePropertyWithD84C9D277819FF0B9">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclarePropertyWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a property, like DeclareProperty( <A>name</A>, <A>filter</A> ) would do. The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this property
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

##  <#GAPDoc Label="DeclareGlobalFunctio780471A2876B4016">
##  <ManSection>
##    <Func Arg="name, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareGlobalFunctionWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
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

##  <#GAPDoc Label="DeclareGlobalVariabl83C1403D793BAA65">
##  <ManSection>
##    <Func Arg="name, description, [ chapter_and_section ]" Name="DeclareGlobalVariableWithDocumentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
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

##  <#GAPDoc Label="CreateDocEntryForCat85DE17917C282F46">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForCategory" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
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

##  <#GAPDoc Label="CreateDocEntryForRep7B4216B3819043CE">
##  <ManSection>
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForRepresentation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this category
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

##  <#GAPDoc Label="CreateDocEntryForOpe7AB5CCA081EAC274">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForOperation" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the method. It is not optional.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attributes of the operation.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this method
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

##  <#GAPDoc Label="CreateDocEntryForAtt81D2368F81855963">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForAttribute" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>return_value</A> is a string displayed as the return value of the attribute. It is not optional.
##      <A>argument</A> is an optional string which is displayed in the documentation as attribute of the attribute.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this attribute
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

##  <#GAPDoc Label="CreateDocEntryForPro7E7BCCAA7C708139">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForProperty" Label=""/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      The description string is added to the documentation
##      if CreateAutoDoc is called. It
##      can either be a string or a list of strings. Lists will be concatenated with a space between them.
##      <A>arguments</A> is an optional string which is displayed in the documentation as attribute of the tester.
##      <A>chapter_and_section</A> is an optional arguments which must be a list with two strings, naming the chapter and the section in which this property
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

