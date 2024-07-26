{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DBGridController;

{$warn 5023 off : no warning about unused units}
interface

uses
   dxDBGridController, JsonTools, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('dxDBGridController', @dxDBGridController.Register);
end;

initialization
  RegisterPackage('DBGridController', @Register);
end.
