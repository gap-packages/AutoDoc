##  <#GAPDoc Label="CreateAutomaticDocum7FF7CB7879E3103D">
##  <ManSection>
##    <Func Arg="package_name, documentation_file, path_to_xml_file, create_full_docu, [ section_intros ]" Name="CreateAutomaticDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This is the main method of the package. After loading the package, run it with the name of the package
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
##      This global variable stores all the streams and some additional data, like chapter names.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareOperationWith7F05AD3D87726034">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareOperationWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares an operation, like DeclareOperation( <A>name</A>, <A>list_of_filters</A> ) would do.
##      In addition, it specifies various information documenting the declared operation.
##      There can be used to generate &GAPDoc; documentation files by calling
##      <Ref Func='CreateAutomaticDocumentation'/> in a suitable way.
##      <Br/>
##      The additional parameters have the following meaning:
##      <List>
##      <Mark><A>description</A></Mark><Item>
##      This contains a descriptive text which is added to the generated documentation.
##      It can either be a string or a list of strings. If it is a list of strings, then these
##      strings are concatenated with a space between them.
##      </Item>
##      <Mark><A>return_value</A></Mark><Item>
##      A string displayed as description of the return value.
##      </Item>
##      <Mark><A>arguments</A></Mark><Item>
##      An optional string which is displayed in the documentation as arguments list of the operation.
##      </Item>
##      <Mark><A>chapter_and_section</A></Mark><Item>
##      An optional argument which, if present, must be a list of two strings, naming the chapter
##      and the section in which the generated documentation for the operation should be placed.
##      There are no spaces allowed in this string, underscores will be converted to spaces in
##      the header of the chapter or the section.
##      </Item>
##      <Mark><A>option_record</A></Mark><Item>
##      <A>option_record</A> can be a record with some additional options.
##      The following are currently supported:
##      <List>
##      <Mark><A>group</A></Mark><Item>
##      This must be a string and is used to group functions with the same group name together
##      in the documentation. Their description will be concatenated, chapter and section info
##      of the first element in the group will be used.
##      </Item>
##      <Mark><A>label</A></Mark><Item>
##      This string is used as label of the element in the documentation. If you want to make a
##      reference to a specific entry, you need to set the label manually.
##      Otherwise, this is not necessary.
##      Please be careful.
##      </Item>
##      <Mark><A>function_label</A></Mark><Item>
##      This allows to set the label of the function manually. Normally, they would be the
##      name of the testers of that attribute, for example for IsInt,IsList.
##      This manual setting can be done for reference purposes.
##      </Item>
##      </List>
##      </Item>
##      </List>
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareCategoryWithD856B7A3A82E9480E">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareCategoryWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a category, like DeclareCategory( <A>name</A>, <A>filter</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareRepresentatio7FB1C438813DBD1E">
##  <ManSection>
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareRepresentationWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a representation, like DeclareRepresentation( <A>name</A>, <A>filter</A>, <A>list_of_req_entries</A> )
##      would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareAttributeWith7F6F06A17DF430FF">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="DeclareAttributeWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares an attribute, like DeclareAttribute( <A>name</A>, <A>filter</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclarePropertyWithD7DC223AE7F5C7789">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclarePropertyWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a property, like DeclareProperty( <A>name</A>, <A>filter</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareGlobalFunctio7F7402AB8383D0AC">
##  <ManSection>
##    <Func Arg="name, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="DeclareGlobalFunctionWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a global function like DeclareGlobalFunction( <A>name</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="DeclareGlobalVariabl8193C81283CDA95A">
##  <ManSection>
##    <Func Arg="name, description, [ chapter_and_section ]" Name="DeclareGlobalVariableWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method declares a global variable like DeclareGlobalVariable( <A>name</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="InstallMethodWithDoc876BF65C8663577E">
##  <ManSection>
##    <Func Arg="name, short_descr, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], func" Name="InstallMethodWithDocumentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This method installs a method, like InstallMethod( <A>name</A>, <A>short_descr</A>, <A>list_of_filters</A>, <A>func</A> ) would do.
##      <Br/>
##      <Br/>
##      The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="CreateDocEntryForCat85DE17917C282F46">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForCategory"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This works like <Ref Func='DeclareCategoryWithDocumentation'/> except that it
##      does not call DeclareCategory.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="CreateDocEntryForRep7B4216B3819043CE">
##  <ManSection>
##    <Func Arg="name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForRepresentation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This works like <Ref Func='DeclareRepresentationWithDocumentation'/> except that it
##      does not call DeclareRepresentation.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="CreateDocEntryForOpe7AB5CCA081EAC274">
##  <ManSection>
##    <Func Arg="name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForOperation"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This works like <Ref Func='DeclareOperationWithDocumentation'/> except that it
##      does not call DeclareOperation.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="CreateDocEntryForAtt81D2368F81855963">
##  <ManSection>
##    <Func Arg="name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForAttribute"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This works like <Ref Func='DeclareAttributeWithDocumentation'/> except that it
##      does not call DeclareAttribute.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

##  <#GAPDoc Label="CreateDocEntryForPro7E7BCCAA7C708139">
##  <ManSection>
##    <Func Arg="name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]" Name="CreateDocEntryForProperty"/>
##    <Returns><C>true</C> or <C>false</C></Returns>
##    <Description>
##      This works like <Ref Func='DeclarePropertyWithDocumentation'/> except that it
##      does not call DeclareProperty.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##

