program GraxaimBanca;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, untMain, untNA, indylaz,
  tachartlazaruspkg, datetimectrls;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Graxaim Gestão de Banca';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TformPrincipal, formPrincipal);
  Application.CreateForm(TformNovaAposta, formNovaAposta);
  Application.Run;
end.
