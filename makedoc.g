LoadPackage("AutoDoc");

AutoDoc(
    "AutoDoc" : 
    autodoc := true,
    scaffold := rec(
        includes := [
            "Tutorials.xml",
            "Comments.xml",
            "AutoDocMainFile.xml",
            ],
        entities := [
            "SomePackage",
        ],
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDoc" )[1].Version );

QUIT;
