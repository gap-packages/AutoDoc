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

