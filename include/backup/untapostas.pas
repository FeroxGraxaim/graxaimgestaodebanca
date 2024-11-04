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

procedure AtualizaQRApostas;
procedure CalculaDadosAposta;
//procedure DefineOdd;

type
  { TEventosApostas }

  TEventosApostas = class(TformPrincipal)
  public
    GlobalCodAposta: integer;
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
    procedure FiltrarAposta(Sender: TObject);
    procedure LimparFiltros(Sender: TObject);
    procedure TudoGreenRed(Sender: TObject);
    procedure AoSairGrdApostas(Sender: TObject);
    procedure TrocarSeparadorDecimal(Sender: TObject; var Key: char);
    procedure AbrirEditarAposta(Sender: TObject);

    procedure grdApostasDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
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

uses untNA, untEditSimples, untEditMult;

procedure TEventosApostas.tsApostasShow(Sender: TObject);
begin
  with formPrincipal do
  begin
    writeln('Exibido tsApostas');
    if qrApostas.State in [dsEdit, dsInsert] then
      qrApostas.Cancel;
    with qrApostas do
    begin
      if Active then Close;
      ParamByName('primDia').AsString := Format('%.2d', [1]);
      ParamByName('ultDia').AsString := Format('%.2d', [31]);
      ParamByName('primMes').AsString := Format('%.2d', [mesSelecionado]);
      ParamByName('ultMes').AsString := Format('%.2d', [mesSelecionado]);
      ParamByName('primAno').AsString := Format('%.2d', [anoSelecionado]);
      ParamByName('ultAno').AsString := Format('%.4d', [anoSelecionado]);
      Open;

      grdApostas.Enabled := not IsEmpty;

      btnCashout.Enabled := False;
      btnTudoGreen.Enabled := False;
      btnTudoRed.Enabled := False;
      grdDadosAp.Visible := False;

      if grdApostas.Enabled then Last;
    end;
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
        BarraStatus.Panels[0].Text := 'Aposta marcada para remoção!';
        qrApostas.Edit;
        SalvarEdicaoGrid;
        qrApostas.Edit;
      end
      else
        BarraStatus.Panels[0].Text := 'Aposta selecionada!';
      if qrDadosAposta.Active then qrDadosAposta.Close;
      qrDadosAposta.ParamByName('CodAposta').AsInteger :=
        qrApostas.FieldByName('Cod_Aposta').AsInteger;
      qrDadosAposta.Open;
      grdDadosAp.Visible := True;
      btnTudoGreen.Enabled := True;
      btnTudoRed.Enabled := True;
      btnCashout.Enabled := True;
      if qrApostas.FieldByName('Cashout').AsBoolean = False then
        btnCashout.Caption := 'Cashout'
      else
        btnCashout.Caption := 'Desfazer Cashout';
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
  erro: boolean;
  ComandoErro: string;
  MensagemE: string;
begin
  erro := False;
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
    try
      if MessageDlg('Confirmação',
        'Deseja realmente remover a(s) aposta(s) selecionada(s)?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      try
        Screen.Cursor := crAppStart;
        BarraStatus.Panels[0].Text := 'Removendo aposta...';
        qrApostas.Close;
        writeln('Salvando alterações pendentes');
        progStatus.Position := 25;
        transactionBancoDados.CommitRetaining;
        progStatus.Position := 50;
        writeln('Executando script para remover aposta');
        scriptRemoverAposta.Execute;
        progStatus.Position := 75;
        transactionBancoDados.CommitRetaining;
        progStatus.Position := 100;
      except
        on E: Exception do
        begin
          Screen.Cursor := crDefault;
          ComandoErro := scriptRemoverAposta.Script[i];
          transactionBancoDados.RollbackRetaining;
          writeln('Erro: ' + E.Message + 'Comando SQL: ', ComandoErro);
          MensagemE := E.Message;
          erro := True;
        end;
      end;
      qrApostas.Open;
      grdApostas.Invalidate;
      if qrApostas.IsEmpty then
        grdApostas.Enabled := False
      else
        grdApostas.Enabled := True;
      if not grdApostas.Enabled then grdDadosAp.Visible := False;

      if erro then
        raise Exception.Create('"Erro de banco de dados: ' + MensagemE +
          sLineBreak + sLineBreak + 'Comando: ' + sLineBreak + ComandoErro)
      else
        Screen.Cursor := crDefault;
      ShowMessage('Aposta(s) Removida(s)!');
    except
      on E: Exception do
      begin
        Screen.Cursor := crDefault;
        BarraStatus.Panels[0].Text := 'Erro!';
        progStatus.Color := clRed;
        MessageDlg('Erro',
          'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
      end;
    end;
    progStatus.Position := 0;
    progStatus.Color := clDefault;
  end;
end;

procedure TEventosApostas.btnNovaApostaClick(Sender: TObject);
var
  CodAposta: integer;
  NovaApostaForm: TformNovaAposta;
  Query: TSQLQuery;
begin
  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Valor_Inicial FROM Banca WHERE Mês = :mesSelec AND ' +
        'Ano = :anoSelec';
      ParamByName('mesSelec').AsInteger := mesSelecionado;
      ParamByName('anoSelec').AsInteger := anoSelecionado;
      Open;
      with FieldByName('Valor_Inicial') do
        if IsEmpty or (AsFloat = 0) then
        begin
          ShowMessage('A banca inicial do mês selecionado não foi preenchida, ' +
            'preencha a banca inicial e tente novamente.');
          Exit;
        end;
    finally
      Free;
    end;
    BarraStatus.Panels[0].Text := 'Criando nova aposta...';
    try
      try
        Screen.Cursor := crAppStart;
        NovaApostaForm := TformNovaAposta.Create(nil);
        progStatus.Position := 33;
        conectBancoDados.ExecuteDirect('INSERT INTO Apostas DEFAULT VALUES');
        progStatus.Position := 66;
        transactionBancoDados.CommitRetaining;
        progStatus.Position := 100;
        Screen.Cursor := crDefault;
        NovaApostaForm.ShowModal;
      finally
        NovaApostaForm.Free;
      end;
    except
      on E: Exception do
      begin
        BarraStatus.Panels[0].Text := 'Erro!';
        progStatus.Color := clRed;
        MessageDlg('Erro ao criar o formulário de nova aposta: ' + E.Message,
          mtError, [mbOK], 0);
        Exit;
      end;
    end;
    progStatus.Position := 0;
    progStatus.Color := clDefault;

    if not qrApostas.Active then qrApostas.Open
    else
      qrApostas.Refresh;
    progStatus.Position := 50;
    try
      writeln('Verificando se a tabela está vazia');
      if not qrApostas.IsEmpty then
      begin
        CalculaDadosAposta;
        grdApostas.Enabled := True;
        qrApostas.EnableControls;
        with TSQLQuery.Create(nil) do
        try
          writeln('Selecionando última linha da tabela');
          DataBase := conectBancoDados;
          SQL.Text := 'SELECT MAX(Cod_Aposta) AS CodAposta FROM Apostas';
          Open;
          CodAposta := FieldByName('CodAposta').AsInteger;
          qrApostas.Locate('Cod_Aposta', CodAposta, []);
          Free;
          progStatus.Position := 100;
        except
          On E: Exception do
          begin
            Cancel;
            Free;
            writeln('Erro ao localizar aposta criada: ' + E.Message);
          end;
        end;
      end
      else
        grdApostas.Enabled := False;
    except
      on E: Exception do
        writeln('Erro: ' + E.Message);
    end;
    progStatus.Position := 0;
    BarraStatus.Panels[0].Text := 'Pronto';
  end;
end;

procedure TEventosApostas.SalvarEdicaoGrid;
begin
  Screen.Cursor := crAppStart;
  with formPrincipal do
  begin
    BarraStatus.Panels[0].Text := 'Salvando tabela...';
    //Salvar alterações
    if not (qrApostas.State in [dsEdit, dsInsert]) then
      qrApostas.Edit;
    try
      writeln('Postando alterações...');
      qrApostas.Post;
      progStatus.Position := 33;
      qrApostas.ApplyUpdates;
      progStatus.Position := 66;
      transactionBancoDados.CommitRetaining;
      progStatus.Position := 100;
    except
      on E: EDatabaseError do
      begin
        BarraStatus.Panels[0].Text := 'Erro!';
        progStatus.Color := clRed;
        MessageDlg('Erro',
          'Erro de banco de dados. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        qrApostas.Cancel;
        writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
        transactionBancoDados.RollbackRetaining;
      end;
      on E: Exception do
      begin
        BarraStatus.Panels[0].Text := 'Erro!';
        progStatus.Color := clRed;
        MessageDlg('Erro',
          'Erro ao salvar dados, tente novamente. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
        transactionBancoDados.RollbackRetaining;
      end;
    end;
    progStatus.Position := 0;
    progStatus.Color := clDefault;
    BarraStatus.Panels[0].Text := 'Pronto';
    Screen.Cursor := crDefault;
  end;
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
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Competicao FROM Competicoes';
      Open;
      while not EOF do
      begin
        Competicao.Add(FieldByName('Competicao').AsString);
        Next;
      end;
    finally
      Free;
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
  ValorEntrada: string = '';
  ValorEstorno: double;
label
  Valor;
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      if qrApostas.FieldByName('Cashout').AsBoolean = False then
      begin
        Valor:
          if Active then Close;
        if InputQuery('Inserir Valor', 'Insira o valor retirado da aposta:',
          ValorEntrada) then
        begin
          case FormatSettings.DecimalSeparator of
            '.': if Pos(',', ValorEntrada) > 0 then
                ValorEntrada := StringReplace(ValorEntrada, ',', '.', [rfReplaceAll]);

            ',': if Pos('.', ValorEntrada) > 0 then
                ValorEntrada := StringReplace(ValorEntrada, '.', ',', [rfReplaceAll]);
          end;
          if TryStrToFloat(ValorEntrada, ValorEstorno) then
          begin
            Screen.Cursor := crAppStart;
            SQL.Text :=
              'UPDATE Apostas SET Cashout = 1, Status = ''Cashout'', Retorno = :Retorno WHERE Cod_Aposta = :CodAposta';
            ParamByName('CodAposta').AsInteger :=
              qrApostas.FieldByName('Cod_Aposta').AsInteger;
            ParamByName('Retorno').AsFloat := ValorEstorno;
            ExecSQL;
            transactionBancoDados.CommitRetaining;
          end
          else
          begin
            MessageDlg('Erro', 'Insira um valor numérico!', mtError, [mbOK], 0);
            goto Valor;
          end;
        end;
      end
      else
      begin
        if MessageDlg('Confirmação', 'Deseja realmente desfazer o cashout da aposta?',
          mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          if Active then Close;
          SQL.Text :=
            'UPDATE Apostas SET Cashout = 0, Retorno = Retorno WHERE Cod_Aposta = :CodAposta';
          ParamByName('CodAposta').AsInteger :=
            qrApostas.FieldByName('Cod_Aposta').AsInteger;
          ExecSQL;
          SQL.Text := 'UPDATE Mercados SET Status = Status';
          ExecSQL;
          transactionBancoDados.CommitRetaining;
          btnCashout.Caption := 'Cashout';
        end;
      end;
      AtualizaQRApostas;
      Screen.Cursor := crDefault;
      Free;
      qrApostas.EnableControls;
    except
      on E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        Screen.Cursor := crDefault;
        Free;
        MessageDlg('Erro',
          'Ocorreu um erro, tente novamente. Se o problema persistir favor' +
          'informar no GitHub com a seguinte mensagem: ' + sLineBreak +
          sLineBreak + E.Message, mtError, [mbOK], 0);
      end;
    end;
  CalculaDadosAposta;
end;

procedure TEventosApostas.qrApostasCalcFields(DataSet: TDataSet);
begin
  with formPrincipal do
  begin
    //writeln('Formatando valor retorno');
    qrApostas.FieldByName('RSRetorno').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Retorno').AsFloat);

    //writeln('Formatando valor lucro');
    qrApostas.FieldByName('RSLucro').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Lucro').AsFloat);

    //writeln('Formatando valor Banca Final');
    qrApostas.FieldByName('RSBancaFinal').AsString :=
      FormatFloat('R$ #,##0.00', qrApostas.FieldByName('Banca_Final').AsFloat);

    //writeln('Finalizando qrApostasCalcFields');
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

procedure TEventosApostas.FiltrarAposta(Sender: TObject);
var
  primDia, primMes, primAno, ultDia, ultMes, ultAno: word;
  primData, ultData: TDateTime;
begin
  with formPrincipal do
  begin
    with qrApostas do
    begin
      Close;
      if deFiltroDataInicial.Date = 0 then primData :=
          EncodeDate(anoSelecionado, mesSelecionado, 1)
      else
        primData := deFiltroDataInicial.Date;

      if deFiltroDataFinal.Date = 0 then ultData :=
          EncodeDate(anoSelecionado, mesSelecionado, 31)
      else
        ultData := deFiltroDataFinal.Date;

      if primData > ultData then
      begin
        MessageDlg('Erro', 'A data inicial não pode ser maior que a data final!',
          mtError, [mbOK], 0);
        LimparFiltros(nil);
        Exit;
      end;
      DecodeDate(primData, primAno, primMes, primDia);
      DecodeDate(ultData, ultAno, ultMes, ultDia);
      ParamByName('primDia').AsString := Format('%.2d', [primDia]);
      ParamByName('ultDia').AsString := Format('%.2d', [ultDia]);
      ParamByName('primMes').AsString := Format('%.2d', [primMes]);
      ParamByName('ultMes').AsString := Format('%.2d', [ultMes]);
      ParamByName('primAno').AsString := Format('%.2d', [primAno]);
      ParamByName('ultAno').AsString := Format('%.4d', [ultAno]);
      Open;

      grdApostas.Enabled := not IsEmpty;
      if grdApostas.Enabled then Last;
    end;
  end;
end;

procedure TEventosApostas.LimparFiltros(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrApostas do
    begin
      if Active then Close;
      ParamByName('primDia').AsString := Format('%.2d', [1]);
      ParamByName('ultDia').AsString := Format('%.2d', [31]);
      ParamByName('primMes').AsString := Format('%.2d', [mesSelecionado]);
      ParamByName('ultMes').AsString := Format('%.2d', [mesSelecionado]);
      ParamByName('primAno').AsString := Format('%.2d', [anoSelecionado]);
      ParamByName('ultAno').AsString := Format('%.4d', [anoSelecionado]);
      Open;

      grdApostas.Enabled := not IsEmpty;
      if grdApostas.Enabled then Last;
    end;
  end;
end;

procedure TEventosApostas.TudoGreenRed(Sender: TObject);
begin
  with formPrincipal do
    with tSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      if Sender = btnTudoGreen then
        SQL.Text := 'UPDATE Mercados SET Status = ''Green'' WHERE Cod_Aposta = :CodAposta'
      else if Sender = btnTudoRed then
        SQL.Text := 'UPDATE Mercados SET Status = ''Red'' WHERE Cod_Aposta = :CodAposta';
      ParamByName('CodAposta').AsInteger :=
        qrApostas.FieldByName('Cod_Aposta').AsInteger;
      ExecSQL;
      transactionBancoDados.CommitRetaining;
      qrDadosAposta.Refresh;
      CalculaDadosAposta;
      Free;
    except
      on E: Exception do
      begin
        Cancel;
        Free;
        transactionBancoDados.RollbackRetaining;
        MessageDlg('Erro', 'Erro ao mudar situação, tente novamente. Se o problema ' +
          'persistir favor informar no GitHub com a seguinte mensagem: ' +
          sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
      end;
    end;
  CalculaDadosAposta;
end;

procedure TEventosApostas.AoSairGrdApostas(Sender: TObject);
begin
  //with formPrincipal do
  //grdDadosAp.Visible := false;
end;

procedure TEventosApostas.TrocarSeparadorDecimal(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
end;

procedure TEventosApostas.AbrirEditarAposta(Sender: TObject);
var
  EditarSimples, EditarMultipla: TForm;
begin
  EditarSimples := formEditSimples;
  EditarMultipla := formEditMult;

  with formPrincipal do
    with qrApostas do
    try
      GlobalCodAposta := FieldByName('Cod_Aposta').AsInteger;

      if not FieldByName('Múltipla').AsBoolean then
        formEditSimples.ShowModal
      else
        formEditMult.ShowModal;
    except
      On E: Exception do
      begin
        writeln('Erro ao abrir formulário para editar aposta: ' + E.Message);
        MessageDlg('Erro', 'Erro ao abrir janela de editar aposta, tente novamente. ' +
          'Se o problema persistir favor informar no GitHub com a seguinte mensagem: ' +
          sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
      end;
    end;
end;

procedure CalculaDadosAposta;
var
  Odd, NovaOdd, Retorno, Lucro, BancaFinal: double;
  OddFormat, BancaFormat, RetornoFormat, LucroFormat: string;
  CodAposta: integer;
begin
  writeln('Calculando dados das apostas');
  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      writeln('Procurando dados da aposta localizada');
      SQL.Text :=
        'SELECT Odd, Status FROM Mercados WHERE Mercados.Cod_Aposta = :CodAposta';
      ParamByName('CodAposta').AsInteger :=
        qrApostas.FieldByName('Cod_Aposta').AsInteger;
      ;
      Open;
      First;
      writeln('Calculando a odd da aposta selecionada');
      Odd := FieldByName('Odd').AsFloat;
      case FieldByName('Status').AsString of
        'Meio Green': Odd := (Odd - 1) / 2 + 1;
        'Meio Red': Odd := (Odd - 1) / 2;
        'Anulada': Odd := 1;
      end;
      Next;
      while not EOF do
      begin
        NovaOdd := FieldByName('Odd').AsFloat;
        case FieldByName('Status').AsString of
          'Meio Green': NovaOdd := (NovaOdd - 1) / 2 + 1;
          'Meio Red': NovaOdd := (NovaOdd - 1) / 2;
          'Anulada': NovaOdd := 1;
        end;
        Odd := Odd * NovaOdd;
        OddFormat := FormatFloat('0.00', Odd);
        Odd := StrToFloat(OddFormat);
        Next;
      end;
      writeln('Definindo a odd calculada da aposta selecionada');
      with qrApostas do
      begin
        Edit;
        FieldByName('Odd').AsFloat := Odd;
        Post;
        ApplyUpdates;
      end;
      Close;
      writeln('Executando gatilho "Atualiza Apostas"');
      SQL.Text := 'UPDATE Mercados SET Status = Status';
      ExecSQL;
      transactionBancoDados.CommitRetaining;
      qrApostas.Refresh;
      writeln('Procurando valor inicial da banca do mês atual');
      SQL.Text := 'SELECT Valor_Inicial FROM Banca WHERE Mês = ' +
        '(SELECT Mês FROM "Selecionar Mês e Ano") AND Ano =       ' +
        '(SELECT Ano FROM "Selecionar Mês e Ano")                 ';
      Open;
      BancaFinal := FieldByName('Valor_Inicial').AsFloat;
      Free;
    except
      On E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        writeln('Erro ao calcular dados da aposta: ' + E.Message +
          ' SQL: ' + SQL.Text);
        Free;
        Exit;
      end;
    end;

    writeln('Atualizando dados de todas as apostas do mês atual');
    with qrApostas do
    try
      First;
      while not EOF do
      begin
        //BancaFormat := FormatFloat('0.00', BancaFinal);
        case FieldByName('Status').AsString of
          'Green': begin
            Retorno :=
              (FieldByName('Valor_Aposta').AsFloat) *
              (FieldByName('Odd').AsFloat);
            Lucro := Retorno - (FieldByName('Valor_aposta').AsFloat);
            RetornoFormat := FormatFloat('0.00', Retorno);
            LucroFormat := FormatFloat('0.00', Lucro);
          end;
          'Red': begin
            Retorno := 0;
            Lucro := 0 - (FieldByName('Valor_Aposta').AsFloat);
            RetornoFormat := FormatFloat('0.00', Retorno);
            LucroFormat := FormatFloat('0.00', Lucro);
          end;
          'Anulada': begin
            Retorno := FieldByName('Valor_Aposta').AsFloat;
            Lucro := 0;
            RetornoFormat := FormatFloat('0.00', Retorno);
            LucroFormat := FormatFloat('0.00', Lucro);
          end;
          'Cashout': begin
            Retorno := FieldByName('Retorno').AsFloat;
            Lucro := Retorno - (FieldByName('Valor_aposta').AsFloat);
            RetornoFormat := FormatFloat('0.00', Retorno);
            LucroFormat := FormatFloat('0.00', Lucro);
          end;
          'Pré-live': begin
            Retorno := 0;
            Lucro := 0;
            RetornoFormat := FormatFloat('0.00', Retorno);
            LucroFormat := FormatFloat('0.00', Lucro);
          end;
        end;
        BancaFinal := BancaFinal + FieldByName('Lucro').AsFloat;
        BancaFormat := FormatFloat('0.00', BancaFinal);

        Edit;
        FieldByName('Retorno').AsFloat := StrToFloat(RetornoFormat);
        FieldByName('Lucro').AsFloat := StrToFloat(LucroFormat);
        FieldByName('Banca_Final').AsFloat := StrToFloat(BancaFormat);
        Post;
        Next;
      end;
      ApplyUpdates;
      transactionBancoDados.CommitRetaining;
      Refresh;
    except
      On E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        writeln('Erro: ' + E.Message);
      end;
    end;
    AtualizaQRApostas;
  end;
end;

procedure AtualizaQRApostas;
var
  CodAposta: integer;
begin
  with formPrincipal do
  begin
    Application.ProcessMessages;
    writeln('Lozalizando o código da aposta no qrDadosAposta');
    if qrDadosAposta.Active then
    CodAposta := qrDadosAposta.FieldByName('Cod_Aposta').AsInteger;
    with qrApostas do
    begin
      writeln('Atualizando qrApostas');
      Refresh;
      writeln('Re-selecionando última aposta selecionada');
      Locate('Cod_Aposta', CodAposta, []);
    end;
  end;
end;

procedure AtualizaOdd;
var
  Odd, NovaOdd: double;
  OddFormat: string;
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancODados;
      SQL.Text := 'SELECT Odd, Status FROM Mercados WHERE Cod_Aposta = :CodAposta';
      ParamByName('CodAposta').AsInteger :=
        qrApostas.FieldByName('Cod_Aposta').AsInteger;
      Open;
      First;
      case FieldByName('Status').AsString of
        'Anulada': Odd := 1;
        'Meio Green': Odd := RoundTo((FieldByName('Odd').AsFloat - 1) / 2 + 1, 2);
        'Meio Red': Odd := RoundTo((FieldByName('Odd').AsFloat - 1) / 2, 2);
        else
          Odd := FieldByName('Odd').AsFloat;
      end;
      writeln('Odd: ', Odd);
      Next;
      while not EOF do
      begin
        case FieldByName('Status').AsString of
          'Anulada': NovaOdd := 1;
          'Meio Green': NovaOdd := RoundTo((FieldByName('Odd').AsFloat - 1) / 2 + 1, 2);
          'Meio Red': NovaOdd := RoundTo((FieldByName('Odd').AsFloat - 1) / 2, 2);
          else
            NovaOdd := FieldByName('Odd').AsFloat;
        end;
        writeln('Nova Odd: ', NovaOdd);
        Odd := Odd * NovaOdd;
        Next;
      end;
      OddFormat := FormatFloat('0.00', Odd);
      Odd := StrToFloat(OddFormat);
      with qrApostas do
      begin
        Edit;
        FieldByName('Odd').AsFloat := Odd;
        Post;
        ApplyUpdates;
      end;
      transactionBancoDados.CommitRetaining;
    finally
      Free;
    end;
end;

procedure TEventosApostas.grdApostasDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin
  with formPrincipal do
  begin
    if Column.FieldName = 'Status' then
      with grdApostas.Canvas.Font do
        case qrApostas.FieldByName('Status').AsString of
          'Green': Color := clGreen;
          'Red': Color := clRed;
          'Cashout': Color := clBlue;
          'Meio Green': Color := $0000B6A0;
          'Meio Red': Color := $00007EC3;
          'Pré-live': Color := clDefault;
        end;
    if Column.FieldName = 'RSLucro' then
      with qrApostas do
        with grdApostas.Canvas.Font do
          case Sign(FieldByName('Lucro').AsFloat) of
            1: Color := clGreen;
            -1: Color := clRed;
            0: Color := clDefault;
          end;
    grdApostas.DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

end.
