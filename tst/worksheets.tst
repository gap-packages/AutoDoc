#
# test worksheets
#
gap> START_TEST( "worksheets.tst" );

#
gap> AUTODOC_TestWorkSheet("general");
#I Composing XML document . . .
#I Parsing XML document . . .
#I Checking XML structure . . .
#I Text version (also produces labels for hyperlinks):
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .
#I Producing simplified search strings and labels for hyperlinks . . .
#I Constructing LaTeX version and calling pdflatex:
#I Writing LaTeX file, 4 x pdflatex with bibtex and makeindex, 
#I Writing manual.six file ... 
#I Finally the HTML version . . .
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .
#I - also HTML version for MathJax . . .
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .

#
gap> AUTODOC_TestWorkSheet("autoplain");
#I Composing XML document . . .
#I Parsing XML document . . .
#I Checking XML structure . . .
#I Text version (also produces labels for hyperlinks):
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .
#I Producing simplified search strings and labels for hyperlinks . . .
#I Constructing LaTeX version and calling pdflatex:
#I Writing LaTeX file, 4 x pdflatex with bibtex and makeindex, 
#I Writing manual.six file ... 
#I Finally the HTML version . . .
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .
#I - also HTML version for MathJax . . .
#I First run, collecting cross references, index, toc, bib and so on . . .
#I Table of contents complete.
#I Producing the index . . .
#I Second run through document . . .

#
#
gap> STOP_TEST( "worksheets.tst" );
