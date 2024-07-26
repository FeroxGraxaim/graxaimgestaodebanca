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
  Forms, indylaz, tachartlazaruspkg, untMain, untApostas,
  untDatabase, untMultipla, untNA, untPainel, untSobre,
  untSplash, untUpdate
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='Graxaim Gestão de Banca';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TformPrincipal, formPrincipal);
  Application.CreateForm(TformNovaAposta, formNovaAposta);
  Application.CreateForm(TformSobre, formSobre);
  Application.CreateForm(TformSplash, formSplash);
  Application.Run;
end.

