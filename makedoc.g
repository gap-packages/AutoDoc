##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
##  Call this with GAP.
##

LoadPackage( "GAPDoc" );

SetGapDocLaTeXOptions( "utf8" );

bib := ParseBibFiles( "doc/AutoDoc.bib" );
WriteBibXMLextFile( "doc/AutoDocBib.xml", bib );

Read( "ListOfDocFiles.g" );

PrintTo( "VERSION", PackageInfo( "AutoDoc" )[1].Version );

MakeGAPDocDoc( "doc", "AutoDoc", list, "AutoDoc" );

GAPDocManualLab( "AutoDoc" );

QUIT;
