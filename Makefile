.PHONY: doc html clean check regen

GAP ?= gap
GAP_ARGS = -q --quitonbreak --packagedirs .

doc:
	$(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

html:
	NOPDF=1 $(GAP) $(GAP_ARGS) makedoc.g -c 'QUIT;'

clean:
	cd doc && ./clean

check:
	$(GAP) $(GAP_ARGS) tst/testall.g

regen:
	$(GAP) $(GAP_ARGS) regen_tests.g
