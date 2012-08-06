all: doc

doc: doc/manual.six

doc/manual.six: makedoc.g ListOfDocFiles.g \
		PackageInfo.g \
		doc/AutoDoc.bib doc/*.xml doc/*.css \
		gap/*.gd gap/*.gi
	        gap makedoc.g

clean:
	(cd doc ; ./clean)

archive: doc
	(mkdir -p ../tar; cd ..; tar czvf tar/AutoDoc.tar.gz --exclude ".DS_Store" --exclude "*~" AutoDoc/doc/*.* AutoDoc/doc/clean AutoDoc/gap/*.{gi,gd} AutoDoc/{CHANGES,PackageInfo.g,README,VERSION,init.g,read.g,makedoc.g,makefile,ListOfDocFiles.g})

WEBPOS=public_html
WEBPOS_FINAL=~/public_html/gap_packages/AutoDoc

towww: archive
	echo '<?xml version="1.0" encoding="UTF-8"?>' >${WEBPOS}.version
	echo '<mixer>' >>${WEBPOS}.version
	cat VERSION >>${WEBPOS}.version
	echo '</mixer>' >>${WEBPOS}.version
	cp PackageInfo.g ${WEBPOS}
	cp README ${WEBPOS}/README.AutoDoc
	cp doc/manual.pdf ${WEBPOS}/AutoDoc.pdf
	cp doc/*.{css,html} ${WEBPOS}
	rm -f ${WEBPOS}/*.tar.gz
	mv ../tar/AutoDoc.tar.gz ${WEBPOS}/AutoDoc-`cat VERSION`.tar.gz
	rm -f ${WEBPOS_FINAL}/*.tar.gz
	cp ${WEBPOS}/* ${WEBPOS_FINAL}
	ln -s AutoDoc-`cat VERSION`.tar.gz ${WEBPOS_FINAL}/AutoDoc.tar.gz
