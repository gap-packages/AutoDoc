#
# test miscellaneous stuff
#
gap> START_TEST( "misc.tst" );

# AUTODOC_SetIfMissing
gap> r:=rec();
rec(  )
gap> AUTODOC_SetIfMissing(r, "foo", 1);
gap> r;
rec( foo := 1 )
gap> AUTODOC_SetIfMissing(r, "foo", 2);
gap> r;
rec( foo := 1 )

#
# AUTODOC_FormatDate
#

#
gap> AUTODOC_FormatDate(2019);
"2019"
gap> AUTODOC_FormatDate(2019, 3);
"March 2019"
gap> AUTODOC_FormatDate(2019, 3, 1);
"1 March 2019"
gap> AUTODOC_FormatDate("2019", "3", "1");
"1 March 2019"
gap> AUTODOC_FormatDate(rec(year:=2019));
"2019"
gap> AUTODOC_FormatDate(rec(year:=2019, month:=3));
"March 2019"
gap> AUTODOC_FormatDate(rec(year:=2019, month:=3, day:=1));
"1 March 2019"
gap> AUTODOC_FormatDate(rec(year:="2019", month:="3", day:="1"));
"1 March 2019"

# error handling
gap> AUTODOC_FormatDate();
Error, Invalid arguments
gap> AUTODOC_FormatDate(2019, 3, 40);
Error, <day> must be an integer in the range [1..31], or a string representing\
 such an integer
gap> AUTODOC_FormatDate(2019, 13, 1);
Error, <month> must be an integer in the range [1..12], or a string representi\
ng such an integer
gap> AUTODOC_FormatDate(fail, 3, 1);
Error, <year> must be an integer >= 2000, or a string representing such an int\
eger

#
gap> STOP_TEST( "misc.tst" );
