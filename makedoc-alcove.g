LoadPackage("AutoDoc");

AutoDoc(
    "alcove",
    rec(
        #dir := "doc",     # default
        #scaffold := true,  # implied by existence of PackageInfo.AutoDoc
        autodoc := rec(
            section_intros := 
                [
                    [ "Matroids", "Construction", Concatenation( [ "This section describes the basic constructions to create matroids using alcove.",
                                                    " It covers constructors to obtain new matroids as well as the creation of duals, minors and sums." ] ) ],
                    [ "Matroids", "Accessing_attributes", "This section list methods enabling safe access of stored attributes." ],
                    [ "Matroids", "Bases,_circuits_and_their_companions", Concatenation( [ "In this section, methods to compute data such as bases, circuits,",
                                                                                           " certain flats or invariants like the Tutte polynomial are listed." ] ) ]
                ],
            entities := [],
        ),
        gapdoc := rec(
            scan_dirs := [ "gap" ],
        ),
        
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "alcove" )[1].Version );

QUIT;
