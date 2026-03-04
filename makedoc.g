# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

LoadPackage("AutoDoc");

AutoDoc( rec( 
    autodoc := rec(
        files := [ "doc/Overview.autodoc",
                   "doc/Tutorials.autodoc",
                   "doc/Comments.autodoc" ],
    ),
    gapdoc := rec(
        LaTeXOptions := rec( EarlyExtraPreamble := """
            \usepackage{a4wide}
            \newcommand{\bbZ}{\mathbb{Z}}
        """ )
    ),
    scaffold := rec(
        bib := "bib.xml", 
    )
));
