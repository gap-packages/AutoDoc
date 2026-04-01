LoadPackage("AutoDoc");

AutoDoc(rec(
  gapdoc := rec(
    files := [ "gap/AutoDocTest.gd", "gap/AutoDocTest.gi" ],
  ),
  scaffold := rec(
    includes := [ "chapter1.xml" ],
    appendix := [ "appendix1.xml" ],
    bib := "AutoDocTest.bib",
    bibstyle := "alphaurl",
  ),
));
