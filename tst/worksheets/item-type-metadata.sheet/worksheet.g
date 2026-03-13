#! @Title Item Type Metadata Test
#! @Date 2026-03-12
#! @Chapter Item Types Chapter
#! @Section Type Overrides
#! Worksheet regression for item-type metadata and issue #174.

#! @Description
#! A synonym documented as a function by default.
DeclareSynonym( "SomeFunctionAlias", SomeFunction );

#! @Description
#! @ItemType Filt
#! A synonym documented as a filter.
DeclareSynonym( "IsSomeFilterAlias", IsObject );

#! @Description
#! @ItemType Cat
#! A synonym documented as a category.
DeclareSynonym( "IsSomeCategoryAlias", IsObject );

#! @Description
#! @ItemType Coll
#! A synonym documented as a collection.
DeclareSynonym( "IsSomeCollectionAlias", IsObject );

#! @Description
#! @ItemType Repr
#! A synonym documented as a representation.
DeclareSynonym( "IsSomeRepresentationAlias", IsComponentObjectRep );

#! @Description
#! A family-like global name.
#! @ItemType Fam
DeclareGlobalName( "SomeFamilyAlias" );

#! @Description
#! An info class-like global name.
#! @ItemType InfoClass
DeclareGlobalName( "SomeInfoClassAlias" );

#! @Description
#! A method documented as a method by default.
InstallMethod( "SomeInstalledMethod",
               [ IsObject, IsInt ],
               function( obj, n )
                   return obj;
               end );

#! @Description
#! @ItemType Constr
#! A method documented as a constructor.
InstallMethod( "SomeInstalledConstructor",
               [ IsObject ],
               function( obj )
                   return obj;
               end );

#! @Description
#! @ItemType Meth
#! An explicit method override.
InstallMethod( "SomeExplicitMethod",
               [ IsObject ],
               function( obj )
                   return obj;
               end );

#! @Description
#! A synonym attribute.
DeclareSynonymAttr( "SomeAttributeAlias", SomeAttribute );
