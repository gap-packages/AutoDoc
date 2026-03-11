#! @Title Consecutive Declarations Test
#! @Date 2026-03-12
#! @Chapter Consecutive Chapter
#! @Section Consecutive Section
#! Worksheet regression for issue #169.

#! @Description
#! First declaration stays documented.
DeclareGlobalFunction( "FirstConsecutiveFunction" );
DeclareGlobalFunction( "SecondConsecutiveFunction" );

#! @Description
#! Third declaration has its own comment block.
DeclareGlobalFunction( "ThirdConsecutiveFunction" );
