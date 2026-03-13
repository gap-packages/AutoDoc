.PHONY: doc html check

GAP ?= gap
GAP_ARGS = -q --quitonbreak --packagedirs .

doc:
	$(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

html:
	NOPDF=1 $(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

check:
	$(GAP) $(GAP_ARGS) tst/testall.g
