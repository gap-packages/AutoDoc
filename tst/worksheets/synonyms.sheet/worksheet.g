#! @Title Synonym Declarations Test
#! @Date 2026-03-12
#! @Chapter Synonyms Chapter
#! @Section Synonyms Section
#! Worksheet regression for issue #174.

#! @Description
#! A synonym documented as a function by default.
DeclareSynonym( "SomeFunctionAlias", SomeFunction );

#! @Description
#! @ItemType Filt
#! A synonym documented as a filter.
DeclareSynonym( "IsSomeFilterAlias", IsObject );

#! @Description
#! A synonym attribute.
DeclareSynonymAttr( "SomeAttributeAlias", SomeAttribute );
