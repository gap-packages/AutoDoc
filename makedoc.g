# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

LoadPackage("AutoDoc");

res:= AutoDoc( rec(
    autodoc := true,
    gapdoc := rec(
        LaTeXOptions := rec( EarlyExtraPreamble := """
            \usepackage{a4wide}
            \newcommand{\bbZ}{\mathbb{Z}}
        """ )
    ),
    scaffold := rec(
        includes := [ "Tutorials.xml", 
                      "Comments.xml" ],
        bib := "bib.xml", 
    )
));

errors:= Filtered(SplitString( res.GAPDoc_Info, "\n"),
            x -> StartsWith(x, "#W ") and x <> "#W There are overfull boxes:");
if Length( errors ) = 0 then
  QuitGap( true );
else
  Print( errors, "\n" );
  QuitGap( false );
fi;
QUIT;
