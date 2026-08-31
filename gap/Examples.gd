# AutoDoc: Generate documentation from GAP source code
#
# Copyright of AutoDoc belongs to its developers.
# Please refer to the COPYRIGHT file for details.
#
# SPDX-License-Identifier: GPL-2.0-or-later

#! @Chapter Reference
#! @Section Extracting manual examples

#! @Description
#!  Extracts the examples from the manual of the package <A>pkg</A> and
#!  returns the directory holding the resulting <F>.tst</F> files.
#!
#!  <A>pkg</A> is either the name of a package or a directory object pointing
#!  at one. The optional argument <A>makedoc</A> names the script to read,
#!  and defaults to <F>makedoc.g</F>.
#!
#!  The package's own <F>makedoc.g</F> is used as-is, so the settings which
#!  describe the manual — its source files, scaffolding and
#!  <A>extract_examples</A> options — are not duplicated. Only the parts of
#!  the manual needed to collect the examples are built, no HTML or PDF is
#!  produced, and everything is written to a temporary directory, so this
#!  works even when the package directory is read-only.
#!
#!  This is meant to be used from a package's <F>tst/testall.g</F>, so that
#!  extracted tests need not be committed to the repository:
#!  <Listing><![CDATA[
#!  LoadPackage( "mypkg" );
#!  dirs := DirectoriesPackageLibrary( "mypkg", "tst" );
#!  Add( dirs, AutoDocExtractExamples( "mypkg" ) );
#!  TestDirectory( dirs, rec( exitGAP := true ) );]]></Listing>
#!
#!  Note that <F>makedoc.g</F> is read in the usual way, so any other work it
#!  performs still happens; and a script ending in <C>QUIT</C> cannot be used
#!  this way.
#! @Returns a directory
#! @Arguments pkg[, makedoc]
DeclareGlobalFunction( "AutoDocExtractExamples" );

DeclareGlobalFunction( "AUTODOC_ExtractOnlyDirectory" );
