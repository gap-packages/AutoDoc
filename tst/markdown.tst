#
# test markdown-related functionality
#
gap> START_TEST( "markdown.tst" );

# fenced code blocks and inline code in Markdown-like text
#
gap> AUTODOC_FencedMarkdownElement("@example");
"Example"
gap> AUTODOC_FencedMarkdownElement("@log");
"Log"
gap> AUTODOC_FencedMarkdownElement("gap");
"Listing"
gap> AUTODOC_LineStartsCDATA("<Example><![CDATA[");
true
gap> AUTODOC_LineStartsCDATA("plain text");
false
gap> AUTODOC_LineEndsCDATA("]]></Example>");
true
gap> AUTODOC_LineEndsCDATA("plain text");
false
gap> AUTODOC_EscapeCDATAContent("a]]>b");
"a]]]]><![CDATA[>b"
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "```@example",
>   "gap> 1 + 1;",
>   "2",
>   "```"
> ]);;
gap> Length(markdown_verbatim);
1
gap> IsTreeForDocumentationNode(markdown_verbatim[1]);
true
gap> markdown_verbatim[1]!.element_name;
"Example"
gap> markdown_verbatim[1]!.content;
[ "gap> 1 + 1;", "2" ]
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "Before",
>   "```gap",
>   "if x = 2 then",
>   "  Print(\"ok\\n\");",
>   "fi;",
>   "```",
>   "After"
> ]);;
gap> markdown_verbatim[1];
"Before"
gap> IsTreeForDocumentationNode(markdown_verbatim[2]);
true
gap> markdown_verbatim[2]!.element_name;
"Listing"
gap> markdown_verbatim[2]!.content;
[ "if x = 2 then", "  Print(\"ok\\n\");", "fi;" ]
gap> markdown_verbatim[3];
"After"
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "~~~",
>   "gap> [[2]]>[[1]];",
>   "~~~"
> ]);;
gap> markdown_verbatim[1]!.content;
[ "gap> [[2]]>[[1]];" ]
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "```@example",
>   "gap> 1 + 1;",
>   "2",
>   "```"
> ]);;
gap> markdown_verbatim[1]!.element_name;
"Example"
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "```@log",
>   "#I  some log message",
>   "```"
> ]);;
gap> markdown_verbatim[1]!.element_name;
"Log"
gap> markdown_verbatim := AUTODOC_ConvertMarkdownToGAPDocXML([
>   "```@listing",
>   "#! @BeginCode Increment",
>   "i := i + 1;",
>   "#! @EndCode",
>   "",
>   "#! @InsertCode Increment",
>   "## Code is inserted here.",
>   "```"
> ]);;
gap> markdown_verbatim[1]!.content;
[ "#! @BeginCode Increment", "i := i + 1;", "#! @EndCode", "", 
  "#! @InsertCode Increment", "## Code is inserted here." ]
gap> AUTODOC_ConvertMarkdownToGAPDocXML([
>   "`<Log attr=\"x\"> & more`"
> ]) = [
>   "<Code>&lt;Log attr=&quot;x&quot;&gt; &amp; more</Code>"
> ];
true
gap> tree_cdata := DocumentationTree();;
gap> verbatim_node := DocumentationVerbatim(
>   tree_cdata,
>   "Listing",
>   rec( Type := "Code" ),
>   [ "gap> Print(\"]]>\");" ]
> );;
gap> rendered := "";;
gap> stream := OutputTextString(rendered, true);;
gap> SetPrintFormattingStatus(stream, false);
gap> WriteDocumentation(verbatim_node, stream);
gap> CloseStream(stream);
gap> rendered = Concatenation(
>   "<Listing Type=\"Code\"><![CDATA[\n",
>   "gap> Print(\"]]]]><![CDATA[>\");\n",
>   "]]></Listing>\n"
> );
true
gap> example_node := DocumentationExample( tree_cdata, "Example" );;
gap> Add( example_node!.content, "gap> Print(\"]]>\");" );;
gap> rendered := "";;
gap> stream := OutputTextString(rendered, true);;
gap> SetPrintFormattingStatus(stream, false);
gap> WriteDocumentation(example_node, stream);
gap> CloseStream(stream);
gap> rendered = Concatenation(
>   "<Example><![CDATA[\n",
>   "gap> Print(\"]]]]><![CDATA[>\");\n",
>   "]]></Example>\n\n"
> );
true
gap> rendered := "";;
gap> stream := OutputTextString(rendered, true);;
gap> SetPrintFormattingStatus(stream, false);
gap> WriteDocumentation([
>   "```@listing",
>   "#! @BeginCode Increment",
>   "i := i + 1;",
>   "#! @EndCode",
>   "",
>   "#! @InsertCode Increment",
>   "## Code is inserted here.",
>   "```"
> ], stream);
gap> CloseStream(stream);
gap> rendered = Concatenation(
>   "<Listing><![CDATA[\n",
>   "#! @BeginCode Increment\n",
>   "i := i + 1;\n",
>   "#! @EndCode\n",
>   "\n",
>   "#! @InsertCode Increment\n",
>   "## Code is inserted here.\n",
>   "]]></Listing>\n"
> );
true

#
gap> STOP_TEST( "markdown.tst" );
