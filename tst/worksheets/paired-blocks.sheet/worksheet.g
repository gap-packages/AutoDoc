#! @Title Paired Blocks Test
#! @Date 2026-03-07
#! @Chapter Blocks Chapter
#! @Section Primary Blocks Section
#! Intro text for the block-oriented worksheet.

#! @BeginGroup block-group
#! @GroupTitle Block Group Title

#! @Description
#! First grouped operation description.
#! @Returns an object
#! @Arguments obj[, flag]: eager := true
#! @Label grouped-operation-label
DeclareOperation( "GroupedBlockOperation", [ IsObject ] );

#! @Description
#! Second grouped declaration stays in the implicit group.
DeclareAttribute( "GroupedBlockAttribute", IsObject );

#! @EndGroup

#! @Description
#! This property joins the earlier group explicitly.
#! @Returns true or false
#! @Arguments obj
#! @Group block-group
DeclareProperty( "LateJoinedBlockProperty", IsObject );

#! @Section Injected Section
#! This section exists so @ChapterInfo has a concrete destination.

#! @Section Utility Blocks Section
#! @Description
#! This attribute is redirected into the injected section.
#! @Returns a record
#! @Arguments source
#! @ChapterInfo Blocks Chapter, Injected Section
DeclareAttribute( "RedirectedBlockAttribute", IsObject );

#! @BeginChunk StoredChunk
#! Chunk line one.
#! Chunk line two with `inline code`.
#! @EndChunk

#! Text before inserting the stored chunk.
#! @InsertChunk StoredChunk

#! @BeginCode StoredCode
block_value := 11;

if block_value > 10 then
  Print("block code reached\n");
fi;
#! @EndCode

#! Text before inserting the stored code.
#! @InsertCode StoredCode

#! @LatexOnly \textbf{Latex-only inline text.}
#! @BeginLatexOnly
#! \emph{Latex-only block text.}
#! @EndLatexOnly

#! @NotLatex HTML-and-text inline output.
#! @BeginNotLatex
#! HTML-and-text block output.
#! @EndNotLatex

#! @Subsection Stop Here
#! This text should appear before the parser stops.
#! @DoNotReadRestOfFile
#! This trailing text should never reach the expected XML.
