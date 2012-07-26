##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##  
##  Call this with GAP.
##

LoadPackage( "GAPDoc" );

SetGapDocLaTeXOptions( "utf8" );

bib := ParseBibFiles( "doc/AutomaticDocumentation.bib" );
WriteBibXMLextFile( "doc/AutomaticDocumentationBib.xml", bib );

Read( "ListOfDocFiles.g" );

PrintTo( "VERSION", PackageInfo( "AutomaticDocumentaion" )[1].Version );

MakeGAPDocDoc( "doc", "AutomaticDocumentation", list, "AutomaticDocumentation" );

GAPDocManualLab( "AutomaticDocumentation" );

quit;
