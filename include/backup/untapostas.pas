unit untApostas;

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
    procedure CorrigeBancaFinalApostas;
    procedure SalvarEdicaoGrid;
    procedure btnAtualizaApostasClick(Sender: TObject);
    procedure SelecionarUltimaLinha;
    procedure AtualizaApostas;
    procedure PreencheDadosAposta(CodAposta: integer);
    procedure grdDadosApDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure btnCashoutClick(Sender: TObject);
    procedure qrApostasCalcFields(DataSet: TDataSet);
    procedure CalcularBancaFinal;
  end;

type
  TDadosAposta = record
    Jogo: string;
    Metodo: string;
    Linha: string;
    Odd: string;
    Status: string;
  end;

var
  GridData: array of TDadosAposta;
  ValorEstorno: double;

implementation

uses untNA;

procedure TEventosApostas.tsApostasShow(Sender: TObject);
begin
  with formPrincipal do
  begin
    writeln('Exibido tsApostas');
    if qrApostas.State in [dsEdit, dsInsert] then
      qrApostas.Cancel;

    if qrApostas.Active then qrApostas.Close;
    qrApostas.ParamByName('mesSelec').AsString := Format('%.2d', [mesSelecionado]);
    qrApostas.ParamByName('anoSelec').AsString := Format('%.4d', [anoSelecionado]);
    qrApostas.Open;

    grdApostas.Enabled := not qrApostas.IsEmpty;
  end;
end;

procedure TEventosApostas.grdApostasCellClick(Column: TColumn);
begin
  with formPrincipal do
  begin
    try
      writeln('Detectado lique em célula do grdApostas!');
      qrApostas.Edit;

      if Column.Field is TBooleanField then
      begin
        writeln('Detectada coluna booleana!');
        qrApostas.Edit;
        SalvarEdicaoGrid;
        qrApostas.Edit;
      end;
      if qrDadosAposta.Active then qrDadosAposta.Close;
      qrDadosAposta.ParamByName('CodAposta').AsInteger :=
        qrApostas.FieldByName('Cod_Aposta').AsInteger;
      qrDadosAposta.Open;
      grdDadosAp.Visible := True;
      grdDadosAp.Invalidate;
    except
      on E: EDatabaseError do
      begin
        writeln('Erro: ' + E.Message);
        qrApostas.Cancel;
      end;
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message);
        qrApostas.Cancel;
      end;
    end;
  end;
end;

procedure TEventosApostas.grdApostasColEnter(Sender: TObject);
begin
  with formPrincipal do
  begin
    writeln('Entrado na coluna!');
    qrApostas.Edit;
  end;
end;

procedure TEventosApostas.grdApostasColExit(Sender: TObject);
begin
  writeln('Saindo da coluna');
end;

procedure TEventosApostas.grdApostasExit(Sender: TObject);
begin
  writeln('Saindo do grid');
  grdDadosAp.Visible := False;
end;

procedure TEventosApostas.btnRemoverApostaClick(Sender: TObject);
var
  i: integer;
begin
  with formPrincipal do
  begin
    if not qrApostas.Active then
    begin
      writeln('Abrindo o query...');
      qrApostas.Open;
    end;

    if qrApostas.IsEmpty then
    begin
      ShowMessage('Não há apostas para remover.');
      Exit;
    end
    else
    begin
      try
        Screen.Cursor := crAppStart;
        qrApostas.Close;
        writeln('Salvando alterações pendentes');
        transactionBancoDados.CommitRetaining;
        writeln('Executando script para remover aposta');
        try
          scriptRemoverAposta.Execute;
          transactionBancoDados.CommitRetaining;
        except
          on E: Exception do
          begin
            writeln('Erro: ' + E.Message + 'Comando SQL: ' +
              scriptRemoverAposta.Script[i]);
            transactionBancoDados.RollbackRetaining;
          end;
          on E: EDatabaseError do
          begin
            writeln('Erro: ' + E.Message);
            transactionBancoDados.RollbackRetaining;
          end;
        end;
        ReiniciarTodosOsQueries;
        grdApostas.Invalidate;
        if qrApostas.IsEmpty then
          grdApostas.Enabled := False
        else
          grdApostas.Enabled := True;
        if not grdApostas.Enabled then grdDadosAp.Visible := False;
        ShowMessage('Aposta(s) Removida(s)!');
      except
        on E: ESQLdatabaseError do
        begin
          Screen.Cursor := crDefault;
          writeln('Erro: ' + E.Message);
          transactionBancoDados.RollbackRetaining;
        end;
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          MessageDlg('Erro',
            'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
          transactionBancoDados.RollbackRetaining;
        end;
      end;
      ReiniciarTodosOsQueries;
    end;
  end;
end;

procedure TEventosApostas.btnNovaApostaClick(Sender: TObject);
var
  NovaApostaForm: TformNovaAposta;
begin
  with formPrincipal do
  begin
    Screen.Cursor := crAppStart;
    try
      NovaApostaForm := TformNovaAposta.Create(nil);
      try
        Screen.Cursor := crDefault;
        conectBancoDados.ExecuteDirect('INSERT INTO Apostas DEFAULT VALUES');
        transactionBancoDados.CommitRetaining;
        NovaApostaForm.ShowModal;
      finally
        NovaApostaForm.Free;
      end;

      ReiniciarTodosOsQueries;
      if not qrApostas.IsEmpty then grdApostas.Enabled := True;
    except
      on E: Exception do
      begin
        MessageDlg('Erro', 'Erro ao criar o formulário de nova aposta: ' +
          E.Message, mtError, [mbOK], 0);
      end;
    end;
  end;
end;

procedure TEventosApostas.SalvarEdicaoGrid;
begin
  Screen.Cursor := crAppStart;
  with formPrincipal do
  begin
    //Salvar alterações
    if not (qrApostas.State in [dsEdit, dsInsert]) then
      qrApostas.Edit
    else
    begin
      try
        writeln('Postando alterações...');
        qrApostas.Post;
        qrApostas.ApplyUpdates;
        transactionBancoDados.CommitRetaining;
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
  Screen.Cursor := crDefault;
end;

procedure TEventosApostas.CorrigeBancaFinalApostas;
var
  Query: TSQLQuery;
begin
  with formPrincipal do
  begin
    try
      Query := TSQLQuery.Create(nil);
      Query.Database := conectBancoDados;
      Query.SQL.Text := 'UPDATE Apostas SET Retorno = :Retorno';
      Query.ExecSQL;
      transactionBancoDados.CommitRetaining;
      writeln('Corrigido valores');
      if not qrApostas.Active then qrApostas.Open
      else
      begin
        qrApostas.Close;
        qrApostas.Open;
      end;
    except
      On E: Exception do
      begin
        writeln('Erro ao corrigir banca final: ' + E.Message);
        transactionBancoDados.Rollback;
        if not qrApostas.Active then qrApostas.Open
        else
        begin
          qrApostas.Close;
          qrApostas.Open;
        end;
      end;
    end;
    Query.Free;
  end;
end;

procedure TEventosApostas.btnAtualizaApostasClick(Sender: TObject);
begin
  CorrigeBancaFinalApostas;
  formPrincipal.ReiniciarTodosOsQueries;
end;

procedure TEventosApostas.SelecionarUltimaLinha;
begin
  with formPrincipal do
  begin
    if not qrAPostas.Active then qrApostas.Open;
    qrApostas.DisableControls;
    qrApostas.Last;
    qrApostas.MoveBy(0);
    qrApostas.EnableControls;
  end;
end;

procedure TEventosApostas.AtualizaApostas;
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
    if not qrApostas.Active then qrApostas.Open;
    qrApostas.EnableControls;

    writeln('Exibida aba Apostas!');
    if not qrApostas.Active then
    begin
      writeln('Abrindo o query...');
      qrApostas.Open;
    end;

    //Criando as StringLists
    Estrategias := TStringList.Create;
    Situacao := TStringList.Create;
    Competicao := TStringList.Create;
    Time := TStringList.Create;
    Unidade := TStringList.Create;
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
  end;
end;

procedure TEventosApostas.PreencheDadosAposta(CodAposta: integer);
var
  Row: integer;
begin
  with formPrincipal do
  begin
  end;
end;

procedure TEventosApostas.grdDadosApDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  with formPrincipal do
  begin
    {qrDadosAposta.ParamByName('CodAposta').AsInteger :=
      qrApostas.FieldByName('Cod_Aposta').AsInteger;
    qrDadosAposta.Open;
    grdDadosAp.Invalidate; }
  end;
end;

procedure TEventosApostas.btnCashoutClick(Sender: TObject);
var
  query: TSQLQuery;
  ValorEntrada: string;
label
  Valor;
begin
  with formPrincipal do
  begin
    Valor:
      if InputQuery('Inserir Valor', 'Insira o valor retirado da aposta:',
      ValorEntrada) then
      begin
        if TryStrToFloat(valorEntrada, ValorEstorno) then
        begin
          Screen.Cursor := crAppStart;
          query := TSQLQuery.Create(nil);
          query.Database := conectBancoDados;
          query.SQL.Text := 'UPDATE Apostas SET Cashout = 1, Status = ''Cashout''';
          query.ExecSQL;
          query.ApplyUpdates;
          transactionBancoDados.CommitRetaining;
          Screen.Cursor := crDefault;
        end
        else
        begin
          MessageDlg('Erro', 'Insira um valor numérico!', mtError, [mbOK], 0);
          goto Valor;
        end;
      end;
  end;
end;

procedure TEventosApostas.qrApostasCalcFields(DataSet: TDataSet);
begin
  with formPrincipal do
  begin
    writeln('Formatando valor retorno');
    qrApostas.FieldByName('RSRetorno').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Retorno').AsFloat);

    writeln('Formatando valor lucro');
    qrApostas.FieldByName('RSLucro').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Lucro').AsFloat);

    writeln('Formatando valor Banca Final');
    qrApostas.FieldByName('RSBancaFinal').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Banca_Final').AsFloat);

    writeln('Finalizando qrApostasCalcFields');
  end;
end;


procedure TEventosApostas.CalcularBancaFinal;
var
  Status: string;
  ValorAnterior: double;
  Retorno, Lucro, BancaFinal, ValorAposta: double;
  Calculando: boolean;
begin
  with formPrincipal do
  begin
    writeln('Iniciando cálculos');

    // Evite recalcular se já foi feito
    // if Calculando then Exit;
    // Calculando := True;
    // Certifique-se de que os campos estão corretamente inicializados

    writeln('Finalizando cálculos');
    // Garantir que a variável de controle seja reconfigurada
    // Calculando := False;
  end;
end;

end.
