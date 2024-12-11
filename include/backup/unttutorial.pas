unit untTutorial;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, fgl, Math, LazarusResources;

procedure IniciarTutorial;

implementation

procedure IniciarTutorial;
begin
  if MessageDlg('Iniciar Tutorial', 'Parece que é a primeira vez utilizando o ' +
    'programa, deseja iniciar um tutorial de como usá-lo?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
    with formPrincipal do
    begin
      btnTutorVolta.Glyph.LoadFromLazarusResource('arrow_left');
      btnTutorAvanca.Glyph.LoadFromLazarusResource('arrow_right');
      pnTutorial.Show;
    end
  else
    MessageDlg('Informação', 'O tutorial pode ser iniciado a qualquer ' +
      'momento em Ajuda > Como Usar o Programa.', mtInformation, [mbOK], 0);
end;

initialization
{$I arrow_left.png}
{$I arrow_right.png}
end.
