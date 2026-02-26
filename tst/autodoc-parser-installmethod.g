#! @Chapter Parser
#! @Section InstallMethod
InstallMethod( "MyOp",
               [ IsInt,
                 IsString ],
function(
    x,
    y )
  return x;
end );
