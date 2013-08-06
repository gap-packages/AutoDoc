LoadPackage("AutoDoc");

AutoDoc(
    "LessGenerators",
    rec(
        #scaffold := false,  # TODO: Reconsider this?
        scaffold := rec(
            includes := [
                "intro.xml",
                "install.xml",
                "AutoDocMainFile.xml",
                "examples.xml",
            ],
        ),
        autodoc := rec(
            section_intros := 
                [
                  [ "Quillen-Suslin",
                    [ "Intro for the chapter",
                      "..." ] ],
                  [ "Quillen-Suslin", "Core_procedures",
                    [ "Intro for the section",
                      "..." ] ]
                ],
        ),
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDocTestPackage" )[1].Version );

QUIT;
