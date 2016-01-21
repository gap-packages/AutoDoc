LoadPackage("AutoDoc");

AutoDoc(rec( 
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
));

# Create VERSION file for "make towww"
PrintTo( "VERSION", GAPInfo.PackageInfoCurrent.Version );

QUIT;
