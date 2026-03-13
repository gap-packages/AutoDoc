LoadPackage("AutoDoc");

AutoDoc(rec(
  autodoc := rec(
    files := [ "doc/chapter2.autodoc" ],
  ),
  gapdoc := rec(
    files := [ "gap/AutoDocTest.gd", "gap/AutoDocTest.gi" ],
  ),
  scaffold := rec(
    includes := [ "chapter1.xml" ],
    bib := "AutoDocTest.bib",
    TitlePage := rec(),
    MainPage := true,
  ),
));
