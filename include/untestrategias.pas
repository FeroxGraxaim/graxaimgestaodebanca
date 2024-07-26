unit untEstrategias;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls,
EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
DateUtils, Grids, untMain;

type
TEventosEstrategias = class(TformPrincipal)
public

  procedure tsEstrategiasShow(Sender: TObject);
  procedure grdEstrategiasCellClick(Column: TColumn);
  procedure grdEstrategiasColEnter(Sender: TObject);
  procedure grdEstrategiasColExit(Sender: TObject);
  procedure btnNovaEstrategiaClick(Sender: TObject);
  procedure btnRemoverEstrategiaClick(Sender: TObject);
end;

implementation


procedure TEventosEstrategias.grdEstrategiasCellClick(Column: TColumn);
begin
  with formPrincipal do
    begin
    writeln('verificando se o query está aberto...');
    if not qrEstrategias.Active then
      begin
      writeln('Abrindo o query...');
      qrEstrategias.Open;
      end;

    if not (qrEstrategias.State in [dsEdit, dsInsert]) then
      qrEstrategias.Edit;

    if Column.Field is TBooleanField then
      begin
        try
        qrEstrategias.Post;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          qrEstrategias.Cancel;
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao selecionar estratégia, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosEstrategias.grdEstrategiasColEnter(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not qrEstrategias.Active then
      qrEstrategias.Open;

    if not (qrEstrategias.State in [dsEdit, dsInsert]) then
      qrEstrategias.Edit;

    if (Sender is TDBGrid) and (TDBGrid(Sender).SelectedField is TBooleanField) then
      begin
        try
        qrEstrategias.Post;
        grdEstrategias.Invalidate;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          qrEstrategias.Cancel;
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao selecionar estratégia. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosEstrategias.grdEstrategiasColExit(Sender: TObject);
begin
  with formPrincipal do
    begin
      try
      if qrEstrategias.State in [dsEdit, dsInsert] then
        qrEstrategias.Post;
      qrEstrategias.Close;
      qrEstrategias.Open;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        qrEstrategias.Cancel;
        end;
      end;
    end;
end;

procedure TEventosEstrategias.tsEstrategiasShow(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not qrEstrategias.Active then
      qrEstrategias.Open;
    qrEstrategias.EnableControls;
    end;
end;

procedure TEventosEstrategias.btnNovaEstrategiaClick(Sender: TObject);
begin
  with FormPrincipal do
    begin
    qrEstrategias.Append;
    qrEstrategias.Insert;
    qrEstrategias.Edit;
    end;
end;

procedure TEventosEstrategias.btnRemoverEstrategiaClick(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not qrEstrategias.Active then
      qrEstrategias.Open;

    if dsEstrategias.DataSet.IsEmpty then
      begin
      ShowMessage('Não há estratégias para remover.');
      Exit;
      end;
      try
      qrEstrategias.Delete;
      qrEstrategias.ApplyUpdates;
      transactionBancoDados.CommitRetaining;
      ShowMessage('Estratégia(s) removida(s)!');
      except
      ShowMessage('Selecione uma estratégia para remover!');
      end;
    qrEstrategias.Open;
    MudarCorLucro;
    end;
end;


end.
