unit untMultipla;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  DateUtils, Math, Grids, ValEdit, TAChartAxisUtils, untMain;

type

  { TEventosMultiplas }

  TEventosMultiplas = class(TformPrincipal)
  public
    procedure SalvaContadorNovaMultipla;
    procedure CarregaContadorNovaMultipla;
    procedure tsMultiplaShow(Sender: TObject);
    procedure btnExcMultClick(Sender: TObject);
  end;

implementation

{ TEventosMultiplas }

procedure TEventosMultiplas.tsMultiplaShow(Sender: TObject);
begin
end;

procedure TEventosMultiplas.SalvaContadorNovaMultipla;
begin

end;

procedure TEventosMultiplas.CarregaContadorNovaMultipla;
var
  qrContMult: TSQLQuery;
begin
  with formPrincipal do
  begin
    try
      qrContMult := TSQLQuery.Create(nil);
      qrContMult.DataBase := conectBancoDados;
      qrContMult.SQL.Text := 'SELECT COUNT(*) AS TotalLinhas FROM "Apostas"';
      qrContMult.Open;
      contMult := qrContMult.FieldByName('TotalLinhas').AsInteger;
    except
      on E: Exception do
      begin
        writeln('Erro ao carregar dados do Query: ' + E.Message);
        qrContMult.Cancel;
      end;
    end;
    qrContMult.Free;
  end;
end;

procedure TEventosMultiplas.btnExcMultClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  {if MessageDlg('Confirmação',
    'Tem certeza que quer excluir a(s) aposta(s) selecionada(s)?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    with formPrincipal do
    begin
      query := TSQLQuery.Create(nil);
      query.Database := conectBancoDados;
      query.SQL.Text := 'DELETE FROM Jogos ' + 'WHERE Cod_Mult IN ( ' +
        'SELECT Cod_Mult ' + 'FROM "Apostas Múltiplas" ' +
        'WHERE "Selec." = 1 ';
      query.ExecSQL;
      query.ApplyUpdates;
      transactionBancoDados.Commit;
      query.SQL.Text := 'DELETE FROM "Apostas Múltiplas" ' +
        'WHERE "Selec." = 1 AND Cod_Mult IN (SELECT Cod_Mult FROM Jogos);';
      query.ApplyUpdates;
      transactionBancoDados.Commit;
      query.Free;
      cloneMultipla.Free;
      cloneInfoMult.Free;
      CarregaContadorNovaMultipla;
      CriaMultipla(contMult)
    end;
  end; }
end;

end.
