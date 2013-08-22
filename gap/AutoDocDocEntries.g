
CreateDocEntryForGlobalFunction(
    "CreateAutomaticDocumentation",
    [
# TODO: overhaul the documentation for this
        "After loading the package, run it with the name of the package",
        "you want to create a documentation of as first argument.",
        "Make sure you have included this file as source if you run your &GAPDoc; documentation creating script.",
        "The second argument is a path to the directory where it can store the &GAPDoc; XML files.",
        "It will produce several files out of the",
        "Declare*WithDoc declarations you have used in your package <A>package_name</A>, and one named AutoDocMainFile.xml,",
        "which you can simply include to your documentation.",
        "<A>section_intros</A> is optional, it must be a list containing lists of of either two or three strings. If two are given, first one must be",
        "a chapter title, with underscores instead of spaces, and the second one a string which will be displayed in the documentation at the beginning of",
        "the chapter. If three are given, first one must be a chapter, second a section, third the description.",
    ],
    "nothing",
    "package_name, path_to_xml_file, [ section_intros ]",
    [ "The_main_functions", "The_main_function" ]
);

CreateDocEntryForGlobalVariable(
    "AUTOMATIC_DOCUMENTATION",
    [
    "This global variable stores all the streams and some additional data, like chapter names.",
    ],
    [ "The_main_functions", "Global_variable" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareOperationWithDocumentation",
    [
        "This method declares an operation, like DeclareOperation( <A>name</A>, <A>list_of_filters</A> ) would do.",
        "In addition, it specifies various information documenting the declared operation.",
        "They can be used to generate &GAPDoc; documentation files by calling",
        "<Ref Func='CreateAutomaticDocumentation'/> in a suitable way.",
        "<Br/>",
        "The additional parameters have the following meaning:",
        "<List>",
        "<Mark><A>description</A></Mark><Item>",
            "This contains a descriptive text which is added to the generated documentation.",
            "It can either be a string or a list of strings. If it is a list of strings, then these",
            "strings are concatenated with a space between them.",
        "</Item>",
        "<Mark><A>return_value</A></Mark><Item>",
            "A string displayed as description of the return value.",
        "</Item>",
        "<Mark><A>arguments</A></Mark><Item>",
            "An optional string which is displayed in the documentation as arguments list of the operation.",
        "</Item>",
        "<Mark><A>chapter_and_section</A></Mark><Item>",
            "An optional argument which, if present, must be a list of two strings, naming the chapter",
            "and the section in which the generated documentation for the operation should be placed.",
            "There are no spaces allowed in this string, underscores will be converted to spaces in",
            "the header of the chapter or the section.",
        "</Item>",
        "<Mark><A>option_record</A></Mark><Item>",
            "<A>option_record</A> can be a record with some additional options.",
            "The following are currently supported:",
            "<List>",
            "<Mark><A>group</A></Mark><Item>",
                "This must be a string and is used to group functions with the same group name together",
                "in the documentation. Their description will be concatenated, chapter and section info",
                "of the first element in the group will be used.",
            "</Item>",
#             "<Mark><A>label</A></Mark><Item>",
#                 "This string is used as label of the element in the documentation. If you want to make a",
#                 "reference to a specific entry, you need to set the label manually.",
#                 "Otherwise, this is not necessary.",
#                 
#                 "Please be careful to not give two entries the same description by giving two declarations with",
#                 "the same name the same label.",
#             "</Item>",
            "<Mark><A>function_label</A></Mark><Item>",
                "This sets the label of the function to the string <A>function_label</A>.",
                "It might be useful for reference purposes, also this string is displayed as argument",
                "of this method in the manual.",
                "This really sets the label of the function, not the label of the ManItem.",
                "Please see the &GAPDoc; manual for more infos on labels and references.",
            "</Item>",
            "</List>",
        "</Item>",
        "</List>",
    ],
    "nothing",
    "name, list_of_filters, description, return_value, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareCategoryWithDocumentation",
    [
        "This method declares a category, like DeclareCategory( <A>name</A>, <A>filter</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareRepresentationWithDocumentation",
    [
        "This method declares a representation, like DeclareRepresentation( <A>name</A>, <A>filter</A>, <A>list_of_req_entries</A> )",
        "would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareAttributeWithDocumentation",
    [
        "This method declares an attribute, like DeclareAttribute( <A>name</A>, <A>filter</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclarePropertyWithDocumentation",
    [
        "This method declares a property, like DeclareProperty( <A>name</A>, <A>filter</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareGlobalFunctionWithDocumentation",
    [
        "This method declares a global function like DeclareGlobalFunction( <A>name</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "DeclareGlobalVariableWithDocumentation",
    [
        "This method declares a global variable like DeclareGlobalVariable( <A>name</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, description, [ chapter_and_section ]",
    [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction(
    "InstallMethodWithDocumentation",
    [
        "This method installs a method, like InstallMethod( <A>name</A>, <A>short_descr</A>, <A>list_of_filters</A>, <A>func</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDocumentation'/>.",
    ],
    "nothing",
    "name, short_descr, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], func",
    [ "The_main_functions", "The_install_functions" ]
);


#
# Documentation for CreateDocEntryFor* functions follows
#

CreateDocEntryForGlobalFunction(
    "CreateDocEntryForCategory",
    [
        "This works like <Ref Func='DeclareCategoryWithDocumentation'/> except that it",
        "does not call DeclareCategory.",
    ],
    "nothing",
    "name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_create_functions" ]
);

CreateDocEntryForGlobalFunction(
    "CreateDocEntryForRepresentation",
    [
        "This works like <Ref Func='DeclareRepresentationWithDocumentation'/> except that it",
        "does not call DeclareRepresentation.",
    ],
    "nothing",
    "name, filter, list_of_req_entries, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_create_functions" ]
);

CreateDocEntryForGlobalFunction(
    "CreateDocEntryForOperation",
    [
        "This works like <Ref Func='DeclareOperationWithDocumentation'/> except that it",
        "does not call DeclareOperation.",
    ],
    "nothing",
    "name, list_of_filters, description, return_value [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_create_functions" ]
);

CreateDocEntryForGlobalFunction(
    "CreateDocEntryForAttribute",
    [
        "This works like <Ref Func='DeclareAttributeWithDocumentation'/> except that it",
        "does not call DeclareAttribute.",
    ],
    "nothing",
    "name, filter, description, return_value [ argument ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_create_functions" ]
);

CreateDocEntryForGlobalFunction(
    "CreateDocEntryForProperty",
    [
        "This works like <Ref Func='DeclarePropertyWithDocumentation'/> except that it",
        "does not call DeclareProperty.",
    ],
    "nothing",
    "name, filter, description, [ arguments ], [ chapter_and_section ], [ option_record ]",
    [ "The_main_functions", "The_create_functions" ]
);

###########################################
##
## Documentation of Declare*WithDoc functions.
##
###########################################

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareOperationWithDoc" :
    description := [
        "This method declares an operation, like DeclareOperation( <A>name</A>, <A>list_of_filters</A> ) would do.",
        "In addition, it specifies various information documenting the declared operation.",
        "There can be used to generate &GAPDoc; documentation files by calling",
        "<Ref Func='CreateAutomaticDocumentation'/> in a suitable way.",
        "<Br/>",
        "The remaining parameters are all optional and are passed via GAP's",
        "<Q>function call with options</Q> syntax. For example, you might write",
        "<Listing><![CDATA[",
        "DeclareOperationWithDoc( \"SomeOp\", [IsInt] : description := \"desc\" )",
        "]]></Listing>",
        "in order to declare an operation with a certain description text.",
        "For details on the options syntax, see <Ref Subsect='Function Call With Options' BookName='ref'/>.",
       "All of them are optional, a documentation entry will be created",
       "even if you specify none of them.",
        "The additional parameters have the following meaning:",
        "<List>",
        "<Mark><A>description</A></Mark><Item>",
            "This contains a descriptive text which is added to the generated documentation.",
            "It can either be a string or a list of strings. If it is a list of strings, then these",
            "strings are concatenated with a space between them.",
        "</Item>",
        "<Mark><A>return_value</A></Mark><Item>",
            "A string displayed as description of the return value.",
        "</Item>",
        "<Mark><A>arguments</A></Mark><Item>",
            "An optional string which is displayed in the documentation as arguments list of the operation.",
        "</Item>",
        "<Mark><A>chapter_info</A></Mark><Item>",
            "An optional argument which, if present, must be a list of two strings, naming the chapter",
            "and the section in which the generated documentation for the operation should be placed.",
            "There are no spaces allowed in this string, underscores will be converted to spaces in",
            "the header of the chapter or the section.",
        "</Item>",
        "<Mark><A>group</A></Mark><Item>",
            "This must be a string and is used to group functions with the same group name together",
            "in the documentation. Their description will be concatenated, chapter and section info",
            "of the first element in the group will be used.",
        "</Item>",
        ## Deprecated
#         "<Mark><A>label</A></Mark><Item>",
#             "This string is used as label of the element in the documentation. If you want to make a",
#             "reference to a specific entry, you need to set the label manually.",
#             "Otherwise, this is not necessary.",
#             
#             "Please be careful to not give two entries the same description by giving two declarations with",
#             "the same name the same label.",
#         "</Item>",
        "<Mark><A>function_label</A></Mark><Item>",
            "This sets the label of the function to the string <A>function_label</A>.",
            "It might be useful for reference purposes, also this string is displayed as argument",
            "of this method in the manual.",
            "This really sets the label of the function, not the label of the ManItem.",
            "Please see the &GAPDoc; manual for more infos on labels and references.",
        "</Item>",
        "</List>",
    ],
    return_value := "nothing",
    arguments := "name, list_of_filters : description, return_value, arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareCategoryWithDoc" :
    description := [
        "This method declares a category, like DeclareCategory( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining options behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareRepresentationWithDoc" :
    description := [
        "This method declares a representation, like DeclareRepresentation( <A>arg</A> )",
        "would do.",
        "<Br/>",
        "<Br/>",
        "The remaining options behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareAttributeWithDoc" :
    description := [
        "This method declares an attribute, like DeclareAttribute( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining options behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, return_value, argument, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclarePropertyWithDoc" :
    description := [
        "This method declares a property, like DeclareProperty( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareGlobalFunctionWithDoc" :
    description := [
        "This method declares a global function like DeclareGlobalFunction( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, return_value arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "DeclareGlobalVariableWithDoc" :
    description := [
        "This method declares a global variable like DeclareGlobalVariable( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_declare_functions" ]
);

for i in [ "Category",
           "Representation",
           "Property",
           "Attribute",
           "Operation",
           "GlobalFunction" ] do
           
  CreateDocEntryForGlobalFunction_WithOptions(
      Concatenation( "CreateDocEntryFor", i, "_WithOptions" ) :
      return_value := "nothing",
      arguments := "arg : description, chapter_info, label, function_label, group",
      chapter_info := [ "The_main_functions", "The_create_functions" ],
      group := "WithDocGroup"
  );

od;

CreateDocEntryForGlobalFunction_WithOptions( "CreateDocEntryForGlobalVariable_WithDoc" :
      description := [
          "Does the same as Declare*WithDoc",
          "but without declaring anything."
      ],
      arguments := "arg : description, chapter_info, label, function_label, group",
      chapter_info := [ "The_main_functions", "The_create_functions" ],
      group := "WithDocGroup"
  );

CreateDocEntryForGlobalFunction_WithOptions(
    "InstallMethodWithDoc" :
    description := [
        "This method installs a method, like InstallMethod( <A>arg</A> ) would do.",
        "<Br/>",
        "<Br/>",
        "The remaining parameters behave as described for <Ref Func='DeclareOperationWithDoc'/>.",
    ],
    return_value := "nothing",
    arguments := "arg : description, return_value, arguments, chapter_info, label, function_label, group",
    chapter_info := [ "The_main_functions", "The_install_functions" ]
);

CreateDocEntryForGlobalFunction_WithOptions(
    "SetCurrentAutoDocChapter" :
    description := [
    "These functions set or reset a current chapter or section, which will be applied to",
    "entries without a <A>chapter_info</A> instead of the default one. Note that setting a section",
    "without a chapter does nothing, and reseting the chapter also resets the section." ],
    arguments := "name",
    chapter_info := [ "The_main_functions", "Additional_functions" ],
    group := "SetCurrent" );

CreateDocEntryForGlobalFunction_WithOptions(
    "ResetCurrentAutoDocChapter" :
    description := [ ],
    arguments := " ",
    chapter_info := [ "The_main_functions", "Additional_functions" ],
    group := "SetCurrent" );

CreateDocEntryForGlobalFunction_WithOptions(
    "SetCurrentAutoDocSection" :
    description := [ ],
    arguments := "name",
    chapter_info := [ "The_main_functions", "Additional_functions" ],
    group := "SetCurrent" );

CreateDocEntryForGlobalFunction_WithOptions(
    "ResetCurrentAutoDocSection" :
    description := [ ],
    arguments := " ",
    chapter_info := [ "The_main_functions", "Additional_functions" ],
    group := "SetCurrent" );

CreateDocEntryForGlobalFunction_WithOptions(
  "InsertStringIntoDoc" :
  description := [
  "Writes a string or a list of strings given as argument <A>description</A> into doc.",
  "<A>chapter_info</A> is optional, but without a current chapter set, this would cause an error.",
  "Also it is possible here to only give the chapter, not the section. It will be written in the chapter at the current point,",
  "i.e. after the last written section." ],
  arguments := "description : chapter_info",
  chapter_info := [ "The_main_functions", "Additional_functions" ] );

### TODO: Document _WithOptions commands