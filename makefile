all: doc

doc: doc/manual.six

doc/manual.six: makedoc.g ListOfDocFiles.g \
		PackageInfo.g \
		doc/AutomaticDocumentation.bib doc/*.xml doc/*.css \
		gap/*.gd gap/*.gi
	        gap makedoc.g

clean:
	(cd doc ; ./clean)

archive: doc
	(mkdir -p ../tar; cd ..; tar czvf tar/AutomaticDocumentation.tar.gz --exclude ".DS_Store" --exclude "*~" AutomaticDocumentation/doc/*.* AutomaticDocumentation/doc/clean AutomaticDocumentation/gap/*.{gi,gd} AutomaticDocumentation/{CHANGES,PackageInfo.g,README,VERSION,init.g,read.g,makedoc.g,makefile,ListOfDocFiles.g})

WEBPOS=public_html
WEBPOS_FINAL=~/public_html/gap_packages/AutomaticDocumentation

towww: archive
	echo '<?xml version="1.0" encoding="UTF-8"?>' >${WEBPOS}.version
	echo '<mixer>' >>${WEBPOS}.version
	cat VERSION >>${WEBPOS}.version
	echo '</mixer>' >>${WEBPOS}.version
	cp PackageInfo.g ${WEBPOS}
	cp README ${WEBPOS}/README.AutomaticDocumentation
	cp doc/manual.pdf ${WEBPOS}/AutomaticDocumentation.pdf
	cp doc/*.{css,html} ${WEBPOS}
	rm -f ${WEBPOS}/*.tar.gz
	mv ../tar/AutomaticDocumentation.tar.gz ${WEBPOS}/AutomaticDocumentation-`cat VERSION`.tar.gz
	rm -f ${WEBPOS_FINAL}/*.tar.gz
	cp ${WEBPOS}/* ${WEBPOS_FINAL}
	ln -s AutomaticDocumentation-`cat VERSION`.tar.gz ${WEBPOS_FINAL}/AutomaticDocumentation.tar.gz
