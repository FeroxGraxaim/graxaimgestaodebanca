unit untTimes;

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
TEventosTimes = class(TformPrincipal)

public
  procedure tsTimesShow(Sender: TObject);
  procedure grdTodosTimesCellClick(Column: TColumn);
  procedure grdTodosTimesColEnter(Sender: TObject);
  procedure grdTodosTimesColExit(Sender: TObject);
  procedure btnNovoTimeClick(Sender: TObject);
  procedure btnRemoverTimeClick(Sender: TObject);
  procedure grdTodosTimesExit(Sender: TObject);
end;

implementation

procedure TEventosTimes.tsTimesShow(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not qrTodosTimes.Active then
      qrTodosTimes.Open;
    if not qrTimesMaisLucrativos.Active then
      qrTimesMaisLucrativos.Open;
    if not qrTimesMenosLucrativos.Active then
      qrTimesMenosLucrativos.Open;
    end;
end;

procedure TEventosTimes.grdTodosTimesCellClick(Column: TColumn);
begin
  with formPrincipal do
    begin
      try
      qrTodosTImes.Edit;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        qrEstrategias.Cancel;
        end;
      end;
    if Column.Field is TBooleanField then
      begin
      qrTodosTimes.Edit;
      qrTodosTimes.Post;
      qrTodosTimes.ApplyUpdates;
      transactionBancoDados.CommitRetaining;
      grdTodosTimes.Invalidate;
      end;
    end;
end;

procedure TEventosTimes.grdTodosTimesColEnter(Sender: TObject);
begin
  with formPrincipal do
    begin
      try
      qrEstrategias.Edit;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        ;
        qrEstrategias.Cancel;
        end;
      end;
    end;
end;

procedure TEventosTimes.grdTodosTimesColExit(Sender: TObject);
begin
  with formPrincipal do
    begin
      try
      qrTodosTimes.Edit;
      qrTodosTimes.Post;
      qrTodosTimes.ApplyUpdates;
      transactionBancoDAdos.Commit;
      qrTodosTimes.Edit;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        qrTodosTimes.Cancel;
        end;
      end;
    end;
end;

procedure TEventosTimes.btnNovoTimeClick(Sender: TObject);
begin
  with formPrincipal do
    begin
    qrTodosTimes.Append;
    qrTodosTimes.Edit;
    end;
end;

procedure TEventosTimes.btnRemoverTimeClick(Sender: TObject);
begin
  with formPrincipal do
    begin
    if qrTodosTimes.IsEmpty then
      begin
      ShowMessage('Não há times para remover.');
      Exit;
      end;
    if MessageDlg('Tem certeza que deseja excluir o(s) time(s) selecionado(s)?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        try
        qrTodosTimes.Delete;
        transactionBancoDados.CommitRetaining;
        qrTodosTimes.ApplyUpdates;
        ShowMessage('Time(s) Removido(s)!');
        except
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao remover time(s). Se o problema persistir favor informar ' +
            'no Github com a seguinte mensagem: ' + E.Message,
            mtError, [mbOK], 0);
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    qrApostas.Open;
    end;
end;

procedure TEventosTimes.grdTodosTimesExit(Sender: TObject);
begin
  with formPrincipal do
    begin
      try
      writeln('Colocando query em estado de edição...');
      qrTodosTimes.Edit;
      writeln('Postando alterações...');
      qrTodosTimes.Post;
      writeln('Aplicando alterações...');
      qrTodosTimes.ApplyUpdates;
      writeln('Salvando alterações no banco de dados...');
      transactionBancoDAdos.Commit;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Cancelando as mudanças...');
        qrTodosTimes.Cancel;
        end;
      end;
    writeln('Reabrindo o query...');
    qrTodosTimes.Open;
    end;
end;

end.
