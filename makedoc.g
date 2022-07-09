# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

LoadPackage("AutoDoc");

AutoDoc( rec( 
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
