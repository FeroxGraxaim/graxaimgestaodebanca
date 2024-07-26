unit untNA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, Math, SQLScript;

type

  { TformNovaAposta }

  TformNovaAposta = class(TForm)
    btnAddJogo: TButton;
    btnNovaLinha: TButton;
    btnOk: TButton;
    btnCancelar: TButton;
    cbMandante: TComboBox;
    cbUnidade: TComboBox;
    cbVisitante: TComboBox;
    cbCompeticao: TComboBox;
    deAposta: TDateEdit;
    dsNovaAposta: TDataSource;
    edtValor: TEdit;
    grdNovaAposta: TDBGrid;
    grbNovaLinha: TGroupBox;
    grbNovoJogo: TGroupBox;
    grbBasico: TGroupBox;
    Label1: TLabel;
    lbVisitante2: TLabel;
    lbMandante2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lbCompeticao: TLabel;
    popupLinhas: TPopupMenu;
    qrNovaAposta: TSQLQuery;
    qrNovaApostaCodJogo: TLongintField;
    qrNovaApostaCodLinha: TLongintField;
    qrNovaApostaCodMetodo: TLongintField;
    qrNovaApostaCompetio: TStringField;
    qrNovaApostaData: TDateField;
    qrNovaApostaJogo: TStringField;
    qrNovaApostaLinha: TStringField;
    qrNovaApostaMandante: TStringField;
    qrNovaApostaMtodo: TStringField;
    qrNovaApostaOddMercado: TBCDField;
    qrNovaApostaROWID: TLongintField;
    qrNovaApostaSituacao: TStringField;
    qrNovaApostaVisitante: TStringField;
    rbtnMultipla: TRadioButton;
    rbtnSimples: TRadioButton;
    scriptNovaAposta: TSQLScript;
    scriptNovoJogo: TSQLScript;
    scriptNovoMercado: TSQLScript;
    scriptCancelar: TSQLScript;
    transactionNovaAposta: TSQLTransaction;
    procedure btnAddJogoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure cbCompeticaoChange(Sender: TObject);
    procedure cbUnidadeChange(Sender: TObject);
    procedure cbVisitanteChange(Sender: TObject);
    procedure deApostaChange(Sender: TObject);
    procedure edtOddChange(Sender: TObject);
    procedure edtOddKeyPress(Sender: TObject; var Key: char);
    procedure edtValorChange(Sender: TObject);
    procedure edtValorKeyPress(Sender: TObject; var Key: char);
    procedure edtValorMouseEnter(Sender: TObject);
    procedure edtValorMouseLeave(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure grdNovaApostaCellClick(Column: TColumn);
    procedure grdNovaApostaEditingDone(Sender: TObject);
    procedure qrNovaApostaBeforePost(DataSet: TDataSet);
    procedure rbtnMultiplaChange(Sender: TObject);
    procedure scriptNovoMercadoDirective(Sender: TObject;
      Directive, Argument: ansistring; var StopExecution: boolean);
  private
    MotivoFechar: string;
    procedure PreencherComboBox;
    procedure CalcularValorAposta;
    procedure HabilitarBotaoOk;
    procedure AtualizaMercado;
    procedure AtualizaMetodoLinha(Sender: TObject);
  public

  end;

var
  formNovaAposta: TformNovaAposta;
  qrSavePoint: TSQLQuery;

implementation

uses
  untMain;

  {$R *.lfm}

  { TformNovaAposta }

procedure TformNovaAposta.FormCreate(Sender: TObject);
begin
  writeln('Criando formulário Nova Aposta');
end;

procedure TformNovaAposta.FormShow(Sender: TObject);
var
  qrNACompeticao, qrNATimes: TSQLQuery;
begin
  Screen.Cursor := crAppStart;
  HabilitarBotaoOk;

  formPrincipal.conectBancoDados.ExecuteDirect('SAVEPOINT Cancelar');
  scriptNovaAposta.Execute;
  if not qrNovaAposta.Active then qrNovaAposta.Open;
  qrNovaAposta.Refresh;
  CalcularValorAposta;
  //btnOk.Enabled := False;

  // Listar competições no ComboBox "Competição":
    qrNACompeticao := TSQLQuery.Create(nil);
    qrNACompeticao.DataBase := formPrincipal.conectBancoDados;
    qrNACompeticao.SQL.Text := 'SELECT Competição FROM Competições';
    qrNACompeticao.Open;
    while not qrNACompeticao.EOF do
    begin
      cbCompeticao.items.AddObject(
        qrNACompeticao.FieldByName('Competição').AsString,
        TObject(qrNACompeticao.FieldByName('Competição').AsString));
      qrNACompeticao.Next;
    end;
    qrNACompeticao.Free;

  try
    qrNATimes := TSQLQuery.Create(nil);
    qrNATimes.DataBase := formPrincipal.conectBancoDados;
    qrNATimes.SQL.Text := 'SELECT Time FROM Times';
    qrNATimes.Open;

    //Listar times no ComboBox "cbMandante":
    while not qrNATimes.EOF do
    begin
      cbMandante.Items.AddObject(
        qrNATimes.FieldByName('Time').AsString,
        TObject(qrNATimes.FieldByName('Time').AsString));
      cbVisitante.Items.AddObject(
        qrNATimes.FieldByName('Time').AsString,
        TObject(qrNATimes.FieldByName('Time').AsString));
      qrNATimes.Next;
    end;

    //Listar times no ComboBox "Visitante":
   { while not qrNATimes.EOF do
    begin
      cbVisitante.Items.AddObject(
        qrNATimes.FieldByName('Time').AsString,
        TObject(qrNATimes.FieldByName('Time').AsString));
      qrNATimes.Next;
    end;}
  finally
    qrNATimes.Free;
    Screen.Cursor := crDefault;
  end;

  //Exibir valor padrão do edtValor:
  CalcularValorAposta;
  formPrincipal.Cursor := crDefault;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.grdNovaApostaCellClick(Column: TColumn);
var
  P: TPoint;
  Query: TSQLQuery;
  Item: TMenuItem;
begin
  {if (qrNovaAposta.State in [dsEdit, dsInsert]) then
  begin
    qrNovaAposta.Post;
    qrNovaAposta.ApplyUpdates;
  end; }
  qrNovaAposta.Edit;
  Query := TSQLQuery.Create(nil);
  Query.DataBase := formPrincipal.conectBancoDados;
  Screen.Cursor := crAppStart;
  popupLinhas.Items.Clear;

  ColunaAtual := Column;

  case Column.FieldName of
    'Método':
    begin
      if Query.Active then Query.Close;
      Query.SQL.Text := 'SELECT Nome FROM Métodos';
      Query.Open;
    end;
    'Linha':
    begin
      if Query.Active then Query.Close;
      Query.SQL.Text :=
        'SELECT Nome FROM Linhas WHERE Cod_Metodo = (SELECT Cod_Metodo FROM Métodos WHERE Métodos.Nome = :SelecMetodo)';
      Query.ParamByName('SelecMetodo').AsString :=
        qrNovaAposta.FieldByName('Método').AsString;
      Query.Open;
    end;
    'Situacao':
    begin
      popupLinhas.Items.Clear;
      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Pré-live';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Green';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Red';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Anulada';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Green';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Red';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);
    end;
  end;
  while not Query.EOF do
  begin
    Item := TMenuItem.Create(popupLinhas);
    Item.Caption := Query.FieldByName('Nome').AsString;
    Item.OnClick := @AtualizaMetodoLinha;
    popupLinhas.Items.Add(Item);
    Query.Next;
  end;

  P := Mouse.CursorPos;
  popupLinhas.PopUp(P.X, P.Y);
  Screen.Cursor := crDefault;
  Query.Free;
end;

procedure TformNovaAposta.grdNovaApostaEditingDone(Sender: TObject);
var
  i: integer;
  Metodo, Linha, Status: string;
  Odd: double;
begin
  Screen.Cursor := crAppStart;
  qrNovaAposta.Edit;
  try
    writeln('Postando alterações');
    qrNovaAposta.Post;
    qrNovaAposta.ApplyUpdates;
  except
    on E: Exception do
    begin
      MessageDlg('Erro',
        'Erro ao atualizar mercado, tente novamente. Se o problema persistir ' +
        'informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
    end;
  end;
  qrNovaAposta.Edit;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.qrNovaApostaBeforePost(DataSet: TDataSet);
begin

end;

procedure TformNovaAposta.rbtnMultiplaChange(Sender: TObject);
begin
  if rbtnMultipla.Checked then btnAddJogo.Enabled := True
  else btnAddJogo.Enabled := False;
end;

procedure TformNovaAposta.scriptNovoMercadoDirective(Sender: TObject;
  Directive, Argument: ansistring; var StopExecution: boolean);
begin

end;

procedure TformNovaAposta.PreencherComboBox;
begin

end;


//Calcular valor da aposta
procedure TformNovaAposta.CalcularValorAposta;
var
  CalcUnidade, ValorAposta: double;
  qrDefinirStake: TSQLQuery;
begin

  //Coletando valor da stake do banco de dados
  try
    qrDefinirStake := TSQLQuery.Create(nil);
    qrDefinirStake.DataBase := formPrincipal.conectBancoDados;
    qrDefinirStake.SQL.Text :=
      'SELECT Stake FROM Banca WHERE Mês = :mesSelecionado AND Ano = :anoSelecionado';
    qrDefinirStake.ParamByName('mesSelecionado').AsInteger := mesSelecionado;
    qrDefinirStake.ParamByName('anoSelecionado').AsInteger := anoSelecionado;
    qrDefinirStake.Open;
    stakeAposta := qrDefinirStake.FieldByName('Stake').AsFloat;
  finally
    qrDefinirStake.Free;
  end;

  //Calculando valor da aposta
  if cbUnidade.Text <> 'Outro Valor' then
  begin
    case cbUnidade.Text of
      '0,25 Un': CalcUnidade := 0.25;
      '0,5 Un': CalcUnidade := 0.5;
      '0,75 Un': CalcUnidade := 0.75;
      '1 Un': CalcUnidade := 1.0;
      '1,25 Un': CalcUnidade := 1.25;
      '1,5 Un': CalcUnidade := 1.5;
      '1,75 Un': CalcUnidade := 1.75;
      '2 Un': CalcUnidade := 2.0;
      else
        CalcUnidade := 1.0;
    end;
    ValorAposta := stakeAposta * CalcUnidade;
    edtValor.Text := FloatToStr(ValorAposta);

  end;
end;

procedure TformNovaAposta.HabilitarBotaoOk;
begin
  {if not qrNovaAposta.FieldByName('Competição').IsNull and not
    qrNovaAposta.FieldByName('Jogo').IsNull and not
    qrNovaAposta.FieldByName('Método').IsNull and not
    qrNovaAposta.FieldByName('Linha').IsNull and not
    qrNovaAposta.FieldByName('Odd').IsNull and not
    qrNovaAposta.FieldByName('Status').IsNull then
    btnOk.Enabled := True
  else
    btnOk.Enabled := False;  }
end;

procedure TformNovaAposta.AtualizaMercado;
var
  i: integer;
begin

end;

procedure TformNovaAposta.AtualizaMetodoLinha(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    qrNovaAposta.Edit;
    qrNovaAposta.FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
    writeln('Item selecionado: ', SelectedItem.Caption);
    qrNovaAposta.Post;
    qrNovaAposta.ApplyUpdates;
  end;
end;

procedure TformNovaAposta.btnCancelarClick(Sender: TObject);
begin
  //formPrincipal.conectBancoDados.ExecuteDirect('ROLLBACK TO SAVEPOINT Cancelar');
  //formPrincipal.conectBancoDados.ExecuteDirect('RELEASE SAVEPOINT IF EXISTS Cancelar');
  MotivoFechar := 'Cancelar';

  Close;
end;

procedure TformNovaAposta.btnAddJogoClick(Sender: TObject);
var
  query: TSQLQuery;
  Competicao, Mandante, Visitante: String;
begin
  try
     if qrNovaAposta.Active then
      qrNovaAposta.Close;

    query := TSQLQuery.Create(nil);
    query.Database := formPrincipal.conectBancoDados;

    writeln('Inserindo na tabela Jogo');
    query.SQL.Text :=
      'INSERT INTO Jogo (Cod_Jogo, Cod_Comp, Mandante, Visitante,   ' +
      '                  Cod_Aposta)                                ' +
      'VALUES                                                       ' +
      '    :Cod_Jogo,                                               ' +
      '    (SELECT Cod_Comp FROM Competições WHERE                  ' +
      '    Competições.Competição = :Competicao),                   ' +
      '    :Mandante,                                               ' +
      '    :Visitante,                                              ' +
      '    (SELECT MAX(A.Cod_Aposta) FROM Apostas A)                ';

    query.ParamByName('Competicao').AsString := cbCompeticao.Text;
    query.ParamByName('Mandante').AsString := cbMandante.Text;
    query.ParamByName('Visitante').AsString := cbVisitante.Text;
    query.ExecSQL;
    writeln('Dado Exec com o comando ',query.SQL.Text);

    writeln('Atualizando tabela Mercados');
    query.SQL.Text :=
      'UPDATE Mercados               ' +
      'SET Cod_Jogo = (              ' +
      'SELECT J.Cod_Jogo        ' +
      'FROM Jogo J              ' +
      'WHERE J.Cod_Jogo = (     ' +
      'SELECT MAX(Cod_Jogo) ' +
      'FROM Jogo))          ' +
      'WHERE Mercados.Cod_Aposta = ( ' +
      'SELECT MAX(Cod_Aposta)        ' +
      'FROM Apostas);                ';
    query.ExecSQL;
    writeln('Dado Exec com o comando ',query.SQL.Text);
    query.Free;

    qrNovaAposta.Open;
    qrNovaAposta.Refresh;

    grdNovaAposta.Enabled := True;
    btnNovaLinha.Enabled := True;
    if not rbtnMultipla.Checked then
      btnAddJogo.Enabled := False;

  except
    on E: Exception do
    begin
      MessageDlg('Erro', 'Erro ao adicionar jogo, tente novamente. Mensagem de erro: ' +
        E.Message, mtError, [mbOK], 0);
      qrNovaAposta.Cancel;
    end;
  end;
end;

procedure TformNovaAposta.btnOkClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  try
    writeln('Verificando se os dados foram inseridos');
    if (qrNovaAposta.FieldByName('Método').IsNull or
      qrNovaAposta.FieldByName('Linha').IsNull or
      qrNovaAposta.FieldByName('Mandante').IsNull or
      qrNovaAposta.FieldByName('Visitante').IsNull or
      qrNovaAposta.FieldByName('OddMercado').IsNull) then
      MessageDlg('Erro: Dados inseridos não estão registrados no banco de dados. Verifique se os times, '
        + 'métodos e linhas estão registrados no banco de dados e tente novamente.',
        mtError, [mbOK], 0)
    else
    begin
      writeln('Atualizando tabela "Apostas"');
      query := TSQLQuery.Create(nil);
      query.DataBase := formPrincipal.conectBancoDados;
      query.SQL.Text :=
        'UPDATE Apostas                                   ' +
        'SET                                              ' +
        '    Data = :Data,                                ' +
        'Valor_Aposta = :Valor_Aposta,                      ' +
        'Múltipla = :Múltipla                               ' +
        'WHERE                                              ' +
        'Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas);';
      query.ParamByName('Data').AsDateTime := deAposta.Date;
      query.ParamByName('Valor_Aposta').AsFloat := StrToFloat(edtValor.Text);
      query.ParamByName('Múltipla').AsBoolean := rbtnMultipla.Checked;
      query.ExecSQL;
      query.Close;

      writeln('Atualizando tabela "Jogo"');
      {query.SQL.Text :=
        'UPDATE Jogo                                                                            '
        + 'SET                                                                                    '
        + '   Mandante = CASE WHEN Cod_Jogo IS NOT NULL THEN :Mandante ELSE Jogo.Mandante END,    '
        + '   Visitante = CASE WHEN Cod_Jogo IS NOT NULL THEN :Visitante ELSE Jogo.Visitante END  '
        + 'WHERE Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas)                               '
        + 'AND ROWID = (SELECT ROWID FROM Jogo AS ROWID WHERE ROWID = :ROWID);';

      query.ParamByName('Mandante').AsString :=
        qrNovaAposta.FieldByName('Mandante').AsString;
      query.ParamByName('Visitante').AsString :=
        qrNovaAposta.FieldByName('Visitante').AsString;
      query.ExecSQL;
      query.Close; }

      if (qrNovaAposta.State in [dsEdit, dsInsert]) then
      begin
        writeln('Atualizando tabela "Mercados"');
        qrNovaAposta.Post;
        qrNovaAposta.ApplyUpdates;
      end;

      writeln('Salvando alterações no banco de dados');
      formPrincipal.transactionBancoDados.Commit;
      //formPrincipal.conectBancoDados.ExecuteDirect('RELEASE SAVEPOINT IF EXISTS Cancelar');
      query.Free;
      MotivoFechar := 'Ok';
      Close;
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Erro',
        'Erro ao salvar aposta, tente novamente. Se o problema persistir ' +
        'informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
      formPrincipal.transactionBancoDados.Rollback;
    end;
  end;
end;

procedure TformNovaAposta.btnNovaLinhaClick(Sender: TObject);
var
  Data: TDateTime;
  Competicao, Jogo, Mandante, Visitante: string;
begin
  try
    Data := qrNovaAposta.FieldByName('Data').AsDateTime;
    Competicao := qrNovaAposta.FieldByName('Competição').AsString;
    Jogo := qrNovaAposta.FieldByName('Jogo').AsString;
    Mandante := qrNovaAposta.FieldByName('Mandante').AsString;
    Visitante := qrNovaAposta.FieldByName('Visitante').AsString;
    writeln('Inserido nova linha');
    qrNovaAposta.Insert;
    qrNovaAposta.FieldByName('Data').AsDateTime := Data;
    qrNovaAposta.FieldByName('Competição').AsString := Competicao;
    qrNovaAposta.FieldByName('Mandante').AsString := Mandante;
    qrNovaAposta.FieldByName('Visitante').AsString := Visitante;
    qrNovaAposta.FieldByName('Jogo').AsString := Jogo;
    qrNovaAposta.ApplyUpdates;
    qrNovaAposta.Refresh;
    qrNovaAposta.Edit;
  except
    on E: Exception do
    begin
      MessageDlg('Erro',
        'Erro ao inserir mercado, tente novamente. Se o problema persistir ' +
        'informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
    end;
  end;
  //query.Free;
end;


procedure TformNovaAposta.cbCompeticaoChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbUnidadeChange(Sender: TObject);
begin
  //Bloquear ou liberar o edtValor
  if cbUnidade.Text = 'Outro Valor' then
  begin
    edtValor.ReadOnly := False;
    edtValor.Color := clWindow;
    edtValor.Cursor := crIBeam;
  end
  else
  begin
    edtValor.ReadOnly := True;
    edtValor.Color := clInactiveBorder;
    edtValor.Cursor := crNo;
  end;
  //Chamar o procedimento para calcular o valor da aposta
  CalcularValorAposta;
end;



procedure TformNovaAposta.cbVisitanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.deApostaChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddKeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then
    Key := ',';
end;

procedure TformNovaAposta.edtValorChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtValorKeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then
    Key := ',';
end;

procedure TformNovaAposta.edtValorMouseEnter(Sender: TObject);
begin
  if edtValor.ReadOnly then
    edtValor.Cursor := crNo;
end;

procedure TformNovaAposta.edtValorMouseLeave(Sender: TObject);
begin
  //  if edtValor.ReadOnly then
  //  edtValor.Cursor := crDefault;
end;

procedure TformNovaAposta.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  with formPrincipal do
  begin
    if MotivoFechar = 'Ok' then
      transactionBancoDados.CommitRetaining
    else
      transactionBancoDados.RollbackRetaining;
  end;
end;



end.
