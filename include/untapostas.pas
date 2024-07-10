unit untApostas;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
Iphttpbroker, DateUtils, Math, Grids, untMain;

type
{ TEventosApostas }

TEventosApostas = class(TformPrincipal)
public

  procedure tsApostasShow(Sender: TObject);
  procedure grdApostasColEnter(Sender: TObject);
  procedure grdApostasColExit(Sender: TObject);
  procedure grdApostasExit(Sender: TObject);
  procedure grdApostasCellClick(Column: TColumn);
  procedure btnRemoverApostaClick(Sender: TObject);
  procedure btnNovaApostaClick(Sender: TObject);
  procedure MudarCoresDasCelulas(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
end;

implementation

uses untNA;

procedure TEventosApostas.tsApostasShow(Sender: TObject);
var
  Estrategias: TStringList;
  Situacao: TStringList;
  Competicao: TStringList;
  Time: TStringList;
  Unidade: TStringList;
  i: integer;
begin
  with formPrincipal do
    begin
    qrApostas.EnableControls;

    writeln('Exibida aba Apostas!');
    if not qrApostas.Active then
      begin
      writeln('Abrindo o query...');
      qrApostas.Open;
      end;
    if qrApostas.IsEmpty then
      begin
      writeln('Grid está vazio, desabilitando...');
      grdApostas.Enabled := False;
      end
    else
      begin
      writeln('Habilitando o grid...');
      grdApostas.Enabled := True;
      end;

    //Criando as StringLists
    Estrategias := TStringList.Create;
    Situacao := TStringList.Create;
    Competicao := TStringList.Create;
    Time    := TStringList.Create;
    Unidade := TStringList.Create;

    //Criando lista de estratégias da coluna "Estratégias"
    while not qrEstrategias.EOF do
      begin
      Estrategias.Add(qrEstrategias.FieldByName('Estratégia').AsString);
      qrEstrategias.Next;
      end;
    //Criando lista de times das colunas "Mandante" e "Visitante"
    while not qrTodosTimes.EOF do
      begin
      Time.Add(qrTodosTimes.FieldByName('Time').AsString);
      qrTodosTimes.Next;
      end;
    //Criando lista de situações da coluna "Situação"
    while not qrSituacao.EOF do
      begin
      Situacao.Add(qrSituacao.FieldByName('Status').AsString);
      qrSituacao.Next;
      end;
    //Criando lista de competições da coluna "Competição"
    while not qrCompeticoes.EOF do
      begin
      Competicao.Add(qrCompeticoes.FieldByName('Competição').AsString);
      qrCompeticoes.Next;
      end;
    //Criando lista de unidades da coluna "unidade"
    while not qrUnidades.EOF do
      begin
      Unidade.Add(qrUnidades.FieldByName('Unidade').AsString);
      qrUnidades.Next;
      end;

    //Listando opções nas colunas
    for i := 0 to grdApostas.Columns.Count - 1 do
      begin
      case grdApostas.Columns[i].FieldName of
        'Estratégia_Escolhida':
          grdApostas.Columns[i].PickList.Assign(Estrategias);
        'Status':
          grdApostas.Columns[i].PickList.Assign(Situacao);
        'Mandante', 'Visitante':
          grdApostas.Columns[i].PickList.Assign(Time);
        'Competição_AP':
          grdApostas.Columns[i].PickList.Assign(Competicao);
        'Unidade':
          grdApostas.Columns[i].PickList.Assign(Unidade);
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasCellClick(Column: TColumn);
begin
  with formPrincipal do
    begin
    writeln('Detectado lique em célula do grdApostas!');
    if not (qrApostas.State in [dsEdit, dsInsert]) then
      begin
      writeln('Colocando query em estado de edição...');
      qrApostas.Edit;
      end;

    if Column.Field is TBooleanField then
      begin
      writeln('Detectada coluna booleana!');
        try
        writeln('Postando alterações...');
        qrApostas.Post;
        grdApostas.Invalidate;
        qrApostas.Edit;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message + ' Abortando...');
          qrApostas.Cancel;
          writeln('Revertendo alterações no banco de dados...');
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao remover a aposta. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message +
            ' Revertendo alterações no banco de dados...');
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasColEnter(Sender: TObject);
begin
  with formPrincipal do
    begin
    writeln('Entrado na coluna!');
    if (qrApostas.State in [dsEdit, dsInsert]) then
      try
      writeln('Postando alterações...');
      qrApostas.Post;
      qrApostas.ApplyUpdates;
      transactionBancoDados.Commit;
      qrApostas.Open;
      writeln('Atualizando o grid...');
      grdApostas.Invalidate;
      qrApostas.Edit;
      except
      on E: Exception do
        begin
        writeln('Erro ao atualizar o banco de dados. ' + E.Message);
        end;
      end;

    if (Sender is TDBGrid) and (TDBGrid(Sender).SelectedField is TBooleanField) then
      begin
      writeln('Detectada coluna booleana!');
        try
        writeln('Postando alterações...');
        qrApostas.Post;
        writeln('Aplicando alterações no query...');
        qrApostas.ApplyUpdates;
        writeln('Salvando alterações no banco de dados...');
        transactionBancoDados.Commit;
        writeln('Reabrindo o query...');
        qrApostas.Open;
        writeln('Atualizando o grid...');
        grdApostas.Invalidate;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message + ' Abortando...');
          qrApostas.Cancel;
          writeln('Revertendo alterações no banco de dados...');
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasColExit(Sender: TObject);
begin
  with formPrincipal do
    begin
    if (qrApostas.State in [dsEdit, dsInsert]) then
      begin
        try
        writeln('Postando alterações...');
        qrApostas.Post;
        grdApostas.Invalidate;
        qrApostas.Edit;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco de dados. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          qrApostas.Cancel;
          writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao salvar dados, tente novamente. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasExit(Sender: TObject);
begin
  with formPrincipal do
    begin
      try
      if qrApostas.State in [dsEdit, dsInsert] then
        begin
        writeln('Postando alterações do Gird...');
        qrApostas.Post;
        end;
      MudarCorLucro;
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        qrApostas.Cancel;
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      on E: Exception do
        begin
        MessageDlg('Erro',
          'Erro ao salvar os dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      end;
    end;
end;

procedure TEventosApostas.btnRemoverApostaClick(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not dsApostas.DataSet.Active then
      begin
      writeln('Abrindo o query...');
      dsApostas.DataSet.Open;
      end;

    if dsApostas.DataSet.IsEmpty then
      begin
      ShowMessage('Não há apostas para remover.');
      Exit;
      end;

      try
      writeln('Removendo aposta...');
      dsApostas.DataSet.Delete;
      writeln('Aplicando alteações no query...');
      qrApostas.ApplyUpdates;
      writeln('Salvando alterações no banco de dados...');
      transactionBancoDados.Commit;
      writeln('Reabrindo o query...');
      qrApostas.Open;
      writeln('Atualizando o dataset...');
      dsApostas.DataSet.Refresh;
      writeln('Atualizando o grid...');
      grdApostas.Invalidate;
      ShowMessage('Aposta(s) Removida(s)!');
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      on E: Exception do
        begin
        MessageDlg('Erro',
          'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      end;
    if qrApostas.IsEmpty then
      begin
      writeln('Desabilitando o grid...');
      grdApostas.Enabled := False;
      end
    else
      begin
      writeln('Habilitando o grid...');
      grdApostas.Enabled := True;
      end;
    MudarCorLucro;
    end;
end;

procedure TEventosApostas.btnNovaApostaClick(Sender: TObject);
var
  novaApostaForm: TformNovaAposta;
begin
  with formPrincipal do
    begin
    writeln('Criando formulário...');
    novaApostaForm := TformNovaAposta.Create(nil);
      try
      writeln('Exibindo o formulário...');
      novaApostaForm.ShowModal;
      finally
      writeln('Destruindo o formulário...');
      novaApostaForm.Free;
      ReiniciarTodosOsQueries;
      if qrApostas.IsEmpty then
        begin
        writeln('Desabilitando o TDBGrid...');
        grdApostas.Enabled := False;
        end
      else
        begin
        writeln('Habilitando o TDBGrid...');
        grdApostas.Enabled := True;
        end;
      end;
    end;
end;

procedure TEventosApostas.MudarCoresDasCelulas(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Status, Retorno, ProfitL: string;
begin
  with formPrincipal do
    begin
    Status  := qrApostas.FieldByName('Status').AsString;
    Retorno := qrApostas.FieldByName('Retorno').AsString;
    ProfitL := qrApostas.FieldByName('Profit_L').AsString;
    case Column.FieldName of
      'Status': case Status of
          'Red': grdApostas.Canvas.Font.Color      := clRed;
          'Green': grdApostas.Canvas.Font.Color    := clGreen;
          'Anulada': grdApostas.Canvas.Font.Color  := clYellow;
          'Cashout': grdApostas.Canvas.Font.Color  := clSkyBlue;
          'Pré-live': grdApostas.Canvas.Font.Color := clWindow;
          'Meio Green': grdApostas.Canvas.Font.Color := $0000FFB4;
          'Meio Red': grdApostas.Canvas.Font.Color := $000084FF;
          end;
      'Retorno': case Status of
          'Red': grdApostas.Canvas.Font.Color      := clRed;
          'Green': grdApostas.Canvas.Font.Color    := clGreen;
          'Anulada': grdApostas.Canvas.Font.Color  := clYellow;
          'Cashout': grdApostas.Canvas.Font.Color  := clSkyBlue;
          'Pré-live': grdApostas.Canvas.Font.Color := clWindow;
          'Meio Green': grdApostas.Canvas.Font.Color := $0000FFB4;
          'Meio Red': grdApostas.Canvas.Font.Color := $000084FF;
          end;
      'Profit_L': case Status of
          'Red': grdApostas.Canvas.Font.Color      := clRed;
          'Green': grdApostas.Canvas.Font.Color    := clGreen;
          'Anulada': grdApostas.Canvas.Font.Color  := clYellow;
          'Cashout': grdApostas.Canvas.Font.Color  := clSkyBlue;
          'Pré-live': grdApostas.Canvas.Font.Color := clWindow;
          'Meio Green': grdApostas.Canvas.Font.Color := $0000FFB4;
          'Meio Red': grdApostas.Canvas.Font.Color := $000084FF;
          end;
      end;
    grdApostas.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
end;

end.
