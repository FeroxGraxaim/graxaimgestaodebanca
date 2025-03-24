unit FncGerais;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Variants;

function CamposNaoNulos(const Campos: array of Variant): Boolean;

implementation

function CamposNaoNulos(const Campos: array of Variant): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := Low(Campos) to High(Campos) do
  if VarIsNull(Campos[i]) or VarIsEmpty(Campos[i]) then
  Exit(False);
end;

end.

