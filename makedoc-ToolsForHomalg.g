LoadPackage("AutoDoc");

AutoDoc(
    "ToolsForHomalg",
    rec(
        #scaffold := false,  # TODO: Reconsider this?
        scaffold := rec(
            includes := [
                "intro.xml",
                "install.xml",
                "AutoDocMainFile.xml",
            ],
            # TODO: Move TitlePage into PackageInfo.AutoDoc record
            TitlePage := rec(
                TitleComment := Concatenation(
                    "(<E>this manual is still under construction</E>)\n",
                    "    <Br/><Br/>\n",
                    "    \n",
                    "    This manual is best viewed as an <B>HTML</B> document. The latest\n",
                    "    version is available <B>online</B> at: <Br/><Br/>\n",
                    "    \n",
                    "    <URL>http://wwwb.math.rwth-aachen.de/~gutsche/gap_packages/ToolsForHomalg/chap0.html</URL>\n",
                    "    <Br/><Br/>\n",
                    "    \n",
                    "    An <B>offline</B> version should be included in the documentation\n",
                    "    subfolder of the package.\n",
                    "    \n",
                    "    This package is part of the &homalg;-project:\n",
                    "    <Br/><Br/>\n",
                    "    \n",
                    "    <URL>http://homalg.math.rwth-aachen.de/index.php/core-packages/toolsforhomalg</URL>\n"
                ),
                Copyright := Concatenation(
                    "  &copyright; 2007-2012 by Mohamed Barakat, Sebastian Gutsche, and Markus Lange-Hegermann<P/>\n",
                    "\n",
                    "    This package may be distributed under the terms and conditions of the\n",
                    "    GNU Public License Version 2.\n"
                ),
            ),
        ),
        autodoc := rec(
            section_intros := 
                [
                  [ "ToDo-list",
                    "Proof_tracking",
                    [ "This is a way to trakc proofs from ToDoLists.",
                      "Not only for debugging, but also for knowing how things work together."
                    ]
                  ],
                  [ "Trees",
                    [ "The trees are used in ToDoLists.",
                       "They are a technical feature, and fairly general, so they also can be used somewhere else."
                    ]
                  ]
                ],
        ),
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDocTestPackage" )[1].Version );

QUIT;
