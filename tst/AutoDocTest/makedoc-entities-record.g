LoadPackage("AutoDoc");

AutoDoc(rec(
  autodoc := rec(
    files := [ "doc/chapter2.autodoc", "doc/appendix.autodoc" ],
  ),
  gapdoc := rec(
    files := [ "gap/AutoDocTest.gd", "gap/AutoDocTest.gi" ],
  ),
  scaffold := rec(
    includes := [ "chapter1.xml" ],
    appendix := [ "appendix1.xml" ],
    bib := "AutoDocTest.bib",
    bibstyle := "alphaurl",
    entities := rec(
      AutoDocTestTag := "<Package>RecordEntity</Package>",
      RECORDNOTE := "record entity",
    ),
  ),
));
