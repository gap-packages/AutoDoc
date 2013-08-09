LoadPackage("AutoDoc");

AutoDoc(
    "AutoDocTestPackage",
    rec(
        #dir := "doc",     # default
        #scaffold := true,  # implied by existence of PackageInfo.AutoDoc
        autodoc := rec(
            output := "gap/documentation_file.d",
            section_intros := 
                [
                  [ "Intro", "This is a test docu" ],
                  [ "With_chapter_info", "This is a user set chapter" ],
                  [ "With_chapter_info", "Category_section", [ "This section", "is for categories" ] ]
                ],
        ),
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "AutoDocTestPackage" )[1].Version );

QUIT;
