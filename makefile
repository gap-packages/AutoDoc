all: doc

doc: doc/manual.six

doc/manual.six: makedoc.g PackageInfo.g doc/*.xml gap/*.gd gap/*.gi
	gap makedoc.g

clean:
	(cd doc ; ./clean)

.PHONY: all doc clean
