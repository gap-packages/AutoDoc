#! @Chapter Parser
#! @Section InstallMethod
#! @ItemType Func
InstallMethod( "MyOp",
               [ IsInt,
                 IsString ],
function(
    x,
    y )
  return x;
end );
