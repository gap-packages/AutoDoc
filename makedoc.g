LoadPackage("AutoDoc");

AutoDoc(
    "AutoDoc",
    rec(
        scaffold := rec(
            includes := [
                "intro.xml",
                "Tutorials.xml",
                "AutoDocMainFile.xml",
                ],
            entities := [
                "SomePackage",
            ],
        ),
        autodoc := true,
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDoc" )[1].Version );

QUIT;
