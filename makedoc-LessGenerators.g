LoadPackage("AutoDoc");

GenerateDocumentation(
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
        gapdoc := rec(
            bib := true,   # default:  "<docdir>/<pkgname>.bib", aber ein String geht auch:  bib := "doc/LessGenerators.bib",
        ),
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDocTestPackage" )[1].Version );
