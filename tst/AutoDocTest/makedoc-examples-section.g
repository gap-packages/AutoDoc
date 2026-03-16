LoadPackage("AutoDoc");

AutoDoc(rec(
  autodoc := false,
  gapdoc := rec(
    files := [ ],
  ),
  scaffold := rec(
    includes := [ "extract-examples.xml" ],
  ),
  extract_examples := rec(
    units := "Section",
  ),
));
