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
  Forms,
  untMain,
  untNA,
  untUpdate,
  tachartlazaruspkg,
  datetimectrls,
  untDatabase,
  untApostas,
  untEstrategias,
  untCampeonatos,
  untTimes,
  untPainel,
  untMultipla,
  untSobre,
  SysUtils,
  Dialogs;

  {$R *.res}
  procedure ExcecaoNaoTratada(Sender: TObject; E: Exception);
  begin
    if not DebugHook = 0 then
      writeln('Ocorreu uma exceção não tratada: ' + E.Message)
    else
      Application.ShowException(E);
  end;

begin
  RequireDerivedFormResource := True;
  Application.Title := 'Graxaim Gestão de Banca';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TformPrincipal, formPrincipal);
  Application.CreateForm(TformNovaAposta, formNovaAposta);
  Application.CreateForm(TformSobre, formSobre);
  Application.Run;
end.
