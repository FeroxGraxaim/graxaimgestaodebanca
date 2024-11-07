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
  Forms, tachartlazaruspkg, lazdbexport, untMain, untApostas, untDatabase,
  untNA, untPainel, untSobre, untSplash, untUpdate, untControleMetodos,
  untControleTimes, untPaises, untContrComp, untEditSimples, untEditMult,
  untSalvarDados, untBoasVindas;

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
  Application.CreateForm(TformEditSimples, formEditSimples);
  Application.CreateForm(TformEditMult, formEditMult);
  Application.CreateForm(TformSalvarDados, formSalvarDados);
  Application.CreateForm(TformBoasVindas, formBoasVindas);
  Application.Run;
end.

