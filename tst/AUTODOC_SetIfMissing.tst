gap> r:=rec();
rec(  )
gap> AUTODOC_SetIfMissing(r, "foo", 1);
gap> r;
rec( foo := 1 )
gap> AUTODOC_SetIfMissing(r, "foo", 2);
gap> r;
rec( foo := 1 )
