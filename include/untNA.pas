unit untNA;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Math,
  SQLScript;

type

  { TformNovaAposta }

  TformNovaAposta = class(TForm)
    btnNovaLinha: TButton;
    btnNovaLinhaMult: TButton;
    btnOk: TButton;
    btnCancelar: TButton;
    btnAddJogo: TButton;
    cbCompeticao: TComboBox;
    cbCompMult: TComboBox;
    cbMandante: TComboBox;
    cbMandanteMult: TComboBox;
    cbUnidade: TComboBox;
    cbUnidadeMult: TComboBox;
    cbVisitante: TComboBox;
    cbVisitanteMult: TComboBox;
    dsLinhaMultipla: TDataSource;
    dsJogos: TDataSource;
    deAposta: TDateEdit;
    deApostaMult: TDateEdit;
    dsNovaAposta: TDataSource;
    edtOdd: TEdit;
    edtOddMult: TEdit;
    edtValor: TEdit;
    edtValorMult: TEdit;
    grbNovaLinha: TGroupBox;
    grbNovaLinha1: TGroupBox;
    grdNovaAposta: TDBGrid;
    grdLinhaMult: TDBGrid;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbCompeticao: TLabel;
    lbCompeticao1: TLabel;
    lbMandante2: TLabel;
    lbMandante3: TLabel;
    lbOdd: TLabel;
    lbOdd1: TLabel;
    lbVisitante2: TLabel;
    lbVisitante3: TLabel;
    lsbJogos: TListBox;
    pcApostas: TPageControl;
    popupLinhas: TPopupMenu;
    qrJogosCodJogo: TLargeintField;
    qrJogosCompetio: TStringField;
    qrJogosJogo: TStringField;
    qrJogosMandante: TStringField;
    qrJogosVisitante: TStringField;
    qrLinhaMultiplaCodJogo: TLargeintField;
    qrLinhaMultiplaCodLinha: TLargeintField;
    qrLinhaMultiplaCodMetodo: TLargeintField;
    qrLinhaMultiplaLinha: TStringField;
    qrLinhaMultiplaMtodo: TStringField;
    qrLinhaMultiplaROWID: TLargeintField;
    qrLinhaMultiplaSituacao: TStringField;
    qrNovaAposta: TSQLQuery;
    qrLinhaMultipla: TSQLQuery;
    qrNovaApostaCodJogo: TLongintField;
    qrNovaApostaCodLinha: TLongintField;
    qrNovaApostaCodMetodo: TLongintField;
    qrNovaApostaCompetio: TStringField;
    qrNovaApostaData: TDateField;
    qrNovaApostaJogo: TStringField;
    qrNovaApostaLinha: TStringField;
    qrNovaApostaMandante: TStringField;
    qrNovaApostaMtodo: TStringField;
    qrNovaApostaROWID: TLongintField;
    qrNovaApostaSituacao: TStringField;
    qrNovaApostaVisitante: TStringField;
    scriptCancelar: TSQLScript;
    scriptNovaAposta: TSQLScript;
    scriptNovoJogo: TSQLScript;
    scriptNovoMercado: TSQLScript;
    qrJogos: TSQLQuery;
    tsMultipla: TTabSheet;
    tsSimples: TTabSheet;
    transactionNovaAposta: TSQLTransaction;
    procedure btnAddJogoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovaLinhaMultClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure cbCompeticaoChange(Sender: TObject);
    procedure cbCompMultChange(Sender: TObject);
    procedure cbMandanteChange(Sender: TObject);
    procedure cbMandanteMultChange(Sender: TObject);
    procedure cbUnidadeChange(Sender: TObject);
    procedure cbUnidadeMultChange(Sender: TObject);
    procedure cbVisitanteChange(Sender: TObject);
    procedure cbVisitanteMultChange(Sender: TObject);
    procedure deApostaChange(Sender: TObject);
    procedure deApostaMultChange(Sender: TObject);
    procedure edtOddChange(Sender: TObject);
    procedure edtOddKeyPress(Sender: TObject; var Key: char);
    procedure edtOddMultChange(Sender: TObject);
    procedure edtValorChange(Sender: TObject);
    procedure edtValorKeyPress(Sender: TObject; var Key: char);
    procedure edtValorMouseEnter(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdLinhaMultCellClick(Column: TColumn);
    procedure grdLinhaMultEditingDone(Sender: TObject);
    procedure grdNovaApostaCellClick(Column: TColumn);
    procedure grdNovaApostaEditingDone(Sender: TObject);
    procedure lsbJogosClick(Sender: TObject);
    procedure pcApostasChange(Sender: TObject);
    procedure tsMultiplaShow(Sender: TObject);
    procedure tsSimplesShow(Sender: TObject);
  private
    MotivoOk: boolean;
    procedure CalcularValorAposta;
    procedure HabilitarBotaoOk;
    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure AtualizaMetLinMult(Sender: TObject);
    procedure HabilitarGridSimples;
  public

  end;

  TItemInfo = class
    Text: string;
    CodJogo: integer;
  end;

var
  formNovaAposta: TformNovaAposta;
  qrSavePoint: TSQLQuery;
  GlobalCodJogo: integer;
  ListaJogo: TList;
  InfoJogo: TItemInfo;

implementation

uses
  untMain;

  {$R *.lfm}

  { TformNovaAposta }

procedure TformNovaAposta.btnAddJogoClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  with formPrincipal do
  begin
    query := TSQLQuery.Create(nil);
    query.DataBase := conectBancoDados;
    query.Transaction := transactionBancoDados;

    query.SQL.Text :=
      'INSERT INTO Jogo (Cod_Comp, Mandante, Visitante) ' +
      'VALUES (                                      ' +
      '   (SELECT Cod_Comp FROM Competições C         ' +
      '    WHERE C.Competição = :Competicao),          ' +
      '   :Mandante,                                  ' + '   :Visitante)';
    query.ParamByName('Mandante').AsString := cbMandanteMult.Text;
    query.ParamByName('Visitante').AsString := cbVisitanteMult.Text;
    query.ParamByName('Competicao').AsString := cbCompMult.Text;
    query.ExecSQL;

    query.SQL.Text :=
      'INSERT INTO Mercados (Cod_Jogo, Cod_Aposta) ' +
      'VALUES (                                                          ' +
      '   (SELECT MAX(Cod_Jogo) FROM Jogo),                              ' +
      '   (SELECT MAX(Cod_Aposta) FROM Apostas))                           ';
    query.ExecSQL;

    if qrJogos.Active then qrJogos.Refresh
    else
      qrJogos.Open;

    qrLinhaMultipla.Open;

    lsbJogos.Items.Clear;
    qrJogos.First;
    while not qrJogos.EOF do
    begin
      InfoJogo := TItemInfo.Create;
      InfoJogo.Text := qrJogos.FieldByName('Jogo').AsString;
      InfoJogo.CodJogo := qrJogos.FieldByName('CodJogo').AsInteger;
      ListaJogo.Add(InfoJogo);
      lsbJogos.Items.Add(InfoJogo.Text);
      qrJogos.Next;
    end;

    query.Free;

    btnNovaLinhaMult.Enabled := True;
    grdLinhaMult.Enabled := True;
    HabilitarBotaoOk;
  end;
end;




procedure TformNovaAposta.FormShow(Sender: TObject);
var
  qrNACompeticao, qrNATimes: TSQLQuery;
begin
  MotivoOk := False;
  Screen.Cursor := crAppStart;
  HabilitarBotaoOk;
  writeln('Criando aposta');
  writeln('Atualizando o query');
  if not qrNovaAposta.Active then qrNovaAposta.Open;
  qrNovaAposta.Refresh;
  CalcularValorAposta;
  btnOk.Enabled := False;

  // Listar competições no ComboBox "Competição":
  writeln('Listando itens nos ComboBoxes');
  qrNACompeticao := TSQLQuery.Create(nil);
  qrNACompeticao.DataBase := formPrincipal.conectBancoDados;
  qrNACompeticao.SQL.Text := 'SELECT Competição FROM Competições';
  qrNACompeticao.Open;
  while not qrNACompeticao.EOF do
  begin
    cbCompeticao.items.AddObject(
      qrNACompeticao.FieldByName('Competição').AsString,
      TObject(qrNACompeticao.FieldByName('Competição').AsString));
    cbCompMult.items.AddObject(
      qrNACompeticao.FieldByName('Competição').AsString,
      TObject(qrNACompeticao.FieldByName('Competição').AsString));
    qrNACompeticao.Next;
  end;
  qrNACompeticao.Free;
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
    cbMandanteMult.Items.AddObject(
      qrNATimes.FieldByName('Time').AsString,
      TObject(qrNATimes.FieldByName('Time').AsString));
    cbVisitante.Items.AddObject(
      qrNATimes.FieldByName('Time').AsString,
      TObject(qrNATimes.FieldByName('Time').AsString));
    cbVisitanteMult.Items.AddObject(
      qrNATimes.FieldByName('Time').AsString,
      TObject(qrNATimes.FieldByName('Time').AsString));
    qrNATimes.Next;
  end;


  qrNATimes.Free;


  //Exibir valor padrão do edtValor:
  CalcularValorAposta;

  formPrincipal.transactionBancoDados.CommitRetaining;

  formPrincipal.Cursor := crDefault;

  ListaJogo := TList.Create;

  Screen.Cursor := crDefault;

  tsSimples.Show;
end;

procedure TformNovaAposta.grdLinhaMultCellClick(Column: TColumn);
var
  P: TPoint;
  Query: TSQLQuery;
  Item: TMenuItem;
begin
  qrLinhaMultipla.Edit;
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
        qrLinhaMultipla.FieldByName('Método').AsString;
      Query.Open;
    end;
    'Situacao':
    begin
      popupLinhas.Items.Clear;
      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Pré-live';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Green';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Red';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Anulada';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Green';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Red';
      Item.OnClick := @AtualizaMetLinMult;
      popupLinhas.Items.Add(Item);
    end;
  end;
  while not Query.EOF do
  begin
    Item := TMenuItem.Create(popupLinhas);
    Item.Caption := Query.FieldByName('Nome').AsString;
    Item.OnClick := @AtualizaMetLinMult;
    popupLinhas.Items.Add(Item);
    Query.Next;
  end;

  P := Mouse.CursorPos;
  popupLinhas.PopUp(P.X, P.Y);
  Screen.Cursor := crDefault;
  Query.Free;
end;

procedure TformNovaAposta.grdLinhaMultEditingDone(Sender: TObject);
begin
  Screen.Cursor := crAppStart;
  try
    writeln('Postando alterações');
    qrLinhaMultipla.Post;
  except
    on E: Exception do
    begin
      writeln('Erro: ' + E.Message);
    end;
  end;
  qrLinhaMultipla.Edit;
  HabilitarBotaoOk;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.grdNovaApostaCellClick(Column: TColumn);
var
  P: TPoint;
  Query: TSQLQuery;
  Item: TMenuItem;
begin
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
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.grdNovaApostaEditingDone(Sender: TObject);
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
      writeln('Erro: ' + E.Message);
    end;
  end;
  qrNovaAposta.Edit;
  HabilitarBotaoOk;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.lsbJogosClick(Sender: TObject);
var
  CodJogo, i: integer;
  ItemSelec: string;
begin
  with formPrincipal do
  begin
    if lsbJogos.ItemIndex <> -1 then
    begin
      CodJogo := -1;

      for i := 0 to ListaJogo.Count - 1 do
      begin
        if TItemInfo(ListaJogo[i]).Text = lsbJogos.Items[lsbJogos.ItemIndex] then
        begin
          CodJogo := TItemInfo(ListaJogo[i]).CodJogo;
          writeln('Item Selecionado: ', CodJogo);
          Break;
        end;
      end;

      if CodJogo <> -1 then
      begin
        GlobalCodJogo := CodJogo;
        writeln('Código do jogo: ', GlobalCodJogo);
      end
      else
        writeln('Código do jogo não encontrado.');

      if qrLinhaMultipla.Active then
        qrLinhaMultipla.Close;

      qrLinhaMultipla.ParamByName('CodJogo').AsInteger := GlobalCodJogo;
      qrLinhaMultipla.Open;
    end;
  end;
end;


procedure TformNovaAposta.pcApostasChange(Sender: TObject);
begin

end;

procedure TformNovaAposta.tsMultiplaShow(Sender: TObject);
begin
  deApostaMult.SetFocus;
  formPrincipal.transactionBancoDados.RollbackRetaining;
  with TSQLQuery.Create(nil) do
  begin
    DataBase := formPrincipal.conectBancoDados;
    try
      SQL.Text := 'UPDATE Apostas SET Múltipla = 1 WHERE Cod_Aposta = ' +
        '(SELECT MAX(Cod_Aposta) FROM Apostas)';
      writeln('SQL: ',SQL.Text);
      ExecSQL;
      SQL.Text := 'DELETE FROM Jogo WHERE Cod_Jogo = (SELECT Cod_Jogo FROM Mercados ' +
        'WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo AND Mercados.Cod_Aposta = (SELECT MAX(' +
        'Cod_Aposta) FROM Apostas))';
      writeln('SQL: ',SQL.Text);
      ExecSQL;
      SQL.Text := 'DELETE FROM Mercados WHERE Cod_Aposta = (SELECT MAX(Cod_Aposta)' +
        'FROM Apostas)';
      writeln('SQL: ',SQL.Text);
      ExecSQL;
    except
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message);
        Cancel;
      end;
    end;
    Free;
  end;
  deApostaMult.SetFocus;
end;

procedure TformNovaAposta.tsSimplesShow(Sender: TObject);
begin
  deAposta.SetFocus;
  formPrincipal.transactionBancoDados.RollbackRetaining;
  writeln('Exibida aba de aposta simples');
  HabilitarBotaoOk;
  if qrNovaAposta.Active then qrNovaAposta.Close;
  try
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := formPrincipal.conectBancoDados;
        SQL.Text := 'UPDATE Apostas SET Múltipla = 0 WHERE Cod_Aposta = ' +
          '(SELECT MAX(Cod_Aposta) FROM Apostas)';
        ExecSQL;
        writeln('Texto SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'INSERT INTO Jogo DEFAULT VALUES';
        writeln('Texto SQL: ', SQL.Text);
        ExecSQL;
       // SQL.Text := 'INSERT INTO Mercados (Cod_Jogo, Cod_Aposta) VALUES ' +
       //   '((SELECT MAX(Cod_Jogo) FROM Jogo), (SELECT MAX(Cod_Aposta) FROM Apostas))';
       // writeln('Texto SQL: ', SQL.Text);
       // ExecSQL;
       if not qrNovaAposta.Active then qrNovaAposta.Open;
       qrNovaAposta.Append;
       qrNovaAposta.ApplyUpdates;
      except
        on E: Exception do
        begin
          writeln('Erro: ' + E.Message);
          Cancel;
        end;
      end;
      Free;
    end;
    qrNovaAposta.Open;
  except
    on E: Exception do
    begin
      writeln('Erro ao criar aposta: ' + E.Message);
      qrNovaAposta.Cancel;
      MessageDlg('Erro', 'Erro ao criar aposta, o processo será cancelado.',
        mtError, [mbOK], 0);
      Close;
    end;
  end;
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
  except
    on E: Exception do
    begin
      writeln('Erro: ' + E.Message);
      MessageDlg('Erro',
        'Erro ao definir valores de unidades, selecione a opção "Outro Valor"' +
        'e digite o valor da aposta manualmente.', mtError, [mbOK], 0);
      qrDefinirStake.Cancel;
    end;
  end;
  qrDefinirStake.Free;

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
    edtValorMult.Text := FloatToStr(ValorAposta);

  end;
end;

procedure TformNovaAposta.HabilitarBotaoOk;
label
  Simples, Multipla, Fim;
begin
  if tsSimples.Showing then goto Simples
  else if tsMultipla.Showing then goto Multipla;

  Simples:

    if (deAposta.Text <> '') and (cbCompeticao.Text <> '') and
      (cbMandante.Text <> '') and (cbVisitante.Text <> '') and
      (edtValor.Text <> '') and (edtOdd.Text <> '') and not
      qrNovaAposta.FieldByName('Método').IsNull and not
      qrNovaAposta.FieldByName('Linha').IsNull and not
      qrNovaAposta.FieldByName('Situacao').IsNull then btnOk.Enabled := True
    else
      btnOk.Enabled := False;
  goto Fim;

  Multipla:

    if (deApostaMult.Text <> '') and (cbCompMult.Text <> '') and
      (cbMandanteMult.Text <> '') and (cbVisitanteMult.Text <> '') and
      (edtValorMult.Text <> '') and (edtOddMult.Text <> '') and not
      qrJogos.IsEmpty and not qrLinhaMultipla.FieldByName('Método').IsNull and
      not qrLinhaMultipla.FieldByName('Linha').IsNull and not
      qrLinhaMultipla.FieldByName('Situacao').IsNull then btnOk.Enabled := True
    else
      btnOk.Enabled := False;

  Fim: ;
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
  end;
end;

procedure TformNovaAposta.AtualizaMetLinMult(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    try
      qrLinhaMultipla.Edit;
      qrLinhaMultipla.FieldByName(ColunaAtual.FieldName).AsString :=
        SelectedItem.Caption;
      writeln('Item selecionado: ', SelectedItem.Caption);
    except
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message);
        qrLinhaMultipla.Cancel;
      end;
    end;
  end;
end;

procedure TformNovaAposta.HabilitarGridSimples;
begin
  if (cbCompeticao.Text <> '') and (cbMandante.Text <> '') and
    (cbVisitante.Text <> '') then grdNovaAposta.Enabled := True
  else
    grdNovaAposta.Enabled := False;
end;

procedure TformNovaAposta.btnCancelarClick(Sender: TObject);
begin
  MotivoOk := False;
  Close;
end;

procedure TformNovaAposta.btnNovaLinhaMultClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  with formPrincipal do
  begin
    if not qrLinhaMultipla.Active then qrLinhaMultipla.Open;
    qrLinhaMultipla.Insert;
    qrLinhaMultipla.FieldByName('CodJogo').AsInteger := GlobalCodJogo;
    grdLinhaMult.Enabled := True;
  end;
end;

procedure TformNovaAposta.btnOkClick(Sender: TObject);
var
  query: TSQLQuery;
begin
  MotivoOk := True;
  Close;
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
    qrNovaAposta.Append;
    qrNovaAposta.FieldByName('Data').AsDateTime := Data;
    qrNovaAposta.FieldByName('Competição').AsString := Competicao;
    qrNovaAposta.FieldByName('Mandante').AsString := Mandante;
    qrNovaAposta.FieldByName('Visitante').AsString := Visitante;
    qrNovaAposta.FieldByName('Jogo').AsString := Jogo;
    qrNovaAposta.ApplyUpdates;
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
  with TSQLQuery.Create(nil) do
  begin
    qrNovaAposta.Close;
    DataBase := formPrincipal.conectBancoDados;
    SQL.Text :=
      'UPDATE Jogo SET Cod_Comp = (SELECT Cod_Comp FROM Competições WHERE ' +
      'Competições.Competição = :Competição) WHERE EXISTS (' +
      '  SELECT 1 FROM Mercados ' + '  WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo)';
    writeln('SQL: ',SQL.Text);
    ParamByName('Competição').AsString := cbCompeticao.Text;
    ExecSQL;
    qrNovaAposta.Open;
    Free;
  end;
  HabilitarGridSimples;
end;

procedure TformNovaAposta.cbCompMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbMandanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  with TSQLQuery.Create(nil) do
  begin
    qrNovaAposta.Close;
    DataBase := formPrincipal.conectBancoDados;
    SQL.Text :=
      'UPDATE Jogo ' + 'SET Mandante = :Mandante ' + 'WHERE EXISTS (' +
      '  SELECT 1 ' + '  FROM Mercados ' +
      '  WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo)';
    writeln('SQL: ',SQL.Text);
    ParamByName('Mandante').AsString := cbMandante.Text;
    ExecSQL;
    qrNovaAposta.Open;
    Free;
  end;
  HabilitarGridSimples;
end;

procedure TformNovaAposta.cbMandanteMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbUnidadeChange(Sender: TObject);
begin
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
  CalcularValorAposta;
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbUnidadeMultChange(Sender: TObject);
begin
  if cbUnidadeMult.Text = 'Outro Valor' then
  begin
    edtValorMult.ReadOnly := False;
    edtValorMult.Color := clWindow;
    edtValorMult.Cursor := crIBeam;
  end
  else
  begin
    edtValorMult.ReadOnly := True;
    edtValorMult.Color := clInactiveBorder;
    edtValorMult.Cursor := crNo;
  end;
  CalcularValorAposta;
  HabilitarBotaoOk;
end;



procedure TformNovaAposta.cbVisitanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  with TSQLQuery.Create(nil) do
  begin
    qrNovaAposta.Close;
    DataBase := formPrincipal.conectBancoDados;
    SQL.Text :=
      'UPDATE Jogo ' + 'SET Visitante = :Visitante ' + 'WHERE EXISTS (' +
      '  SELECT 1 ' + '  FROM Mercados ' + '  WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo)';
    ParamByName('Visitante').AsString := cbVisitante.Text;
    ExecSQL;
    qrNovaAposta.Open;
    Free;
  end;
  HabilitarGridSimples;
end;

procedure TformNovaAposta.cbVisitanteMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.deApostaChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.deApostaMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtOddKeyPress(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
end;

procedure TformNovaAposta.edtOddMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtValorChange(Sender: TObject);
begin
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.edtValorKeyPress(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
end;

procedure TformNovaAposta.edtValorMouseEnter(Sender: TObject);
begin
  if edtValor.ReadOnly then
    edtValor.Cursor := crNo;
end;

procedure TformNovaAposta.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
  excecao: boolean;
label
  Simples, Multipla, Salvar, Ok, Cancelar, Fim;
begin
  excecao := False;
  with formPrincipal do
  begin

    with TSQLQuery.Create(nil) do
    begin
      if MotivoOk then goto Ok
      else
        goto Cancelar;

      Ok:

        try
          writeln('Atualizando tabela "Apostas"');

          DataBase := formPrincipal.conectBancoDados;
          SQL.Text :=
            'UPDATE Apostas                                     ' +
            'SET                                                ' +
            '    Data = :Data,                                  ' +
            'Valor_Aposta = :Valor_Aposta,                      ' +
            'Múltipla = :Múltipla,                              ' +
            'Odd = :Odd                                         ' +
            'WHERE                                              ' +
            'Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas);';
        except
          on E: Exception do
          begin
            MessageDlg('Erro',
            'Ocorreu um erro, a aposta será cancelada. Se o problema persistir ' +
            'favor informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
            mtError, [mbOK], 0);
            Cancel;
            excecao := True;
          end;
        end;

      if excecao then
      begin
        Free;
        goto Cancelar;
      end;

      if tsSimples.Showing then goto Simples
      else if tsMultipla.Showing then goto Multipla
      else
      begin
        MessageDlg('Erro', 'Erro ao identificar se é aposta simples ou múltipla. '
          + 'A aposta será cancelada.', mtError, [mbOK], 0);
        goto Cancelar;
      end;

      Simples:

        ParamByName('Data').AsDateTime := deAposta.Date;
      ParamByName('Valor_Aposta').AsFloat := StrToFloat(edtValor.Text);
      ParamByName('Múltipla').AsBoolean := False;
      ParamByName('Odd').AsFloat := StrToFloat(edtOdd.Text);

      if (qrNovaAposta.State in [dsEdit, dsInsert]) then
      begin
        writeln('Atualizando tabela "Mercados"');
        qrNovaAposta.Post;
        qrNovaAposta.ApplyUpdates;
      end;
      goto Salvar;

      Multipla:

        ParamByName('Data').AsDateTime := deApostaMult.Date;
      ParamByName('Valor_Aposta').AsFloat := StrToFloat(edtValorMult.Text);
      ParamByName('Múltipla').AsBoolean := True;
      ParamByName('Odd').AsFloat := StrToFloat(edtOddMult.Text);

      if (qrLinhaMultipla.State in [dsEdit, dsInsert]) then
      begin
        writeln('Atualizando tabela "Mercados"');
        qrLinhaMultipla.Post;
        qrLinhaMultipla.ApplyUpdates;
      end;

      Salvar:

        try
          ExecSQL;
          writeln('Salvando alterações no banco de dados');
          transactionBancoDados.Commitretaining;
        except
          on E: Exception do
          begin
            MessageDlg('Erro',
            'Erro ao salvar, aposta será cancelada. Se o problema persistir ' +
            'favor informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
            mtError, [mbOK], 0);
            Cancel;
            excecao := True;
          end;
        end;
      Free;
    end;
    if excecao then goto Cancelar
    else
      goto Fim;


    Cancelar:

      transactionBancoDados.RollbackRetaining;
    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      try
        SQL.Text :=
          'DELETE FROM Apostas WHERE Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas)';
        ExecSQL;
        transactionBancoDados.CommitRetaining;
      finally
        Free;
      end;
    end;

    Fim:

      qrSavePoint.Free;
    for i := 0 to ListaJogo.Count - 1 do
      TItemInfo(ListaJogo[i]).Free;
    ListaJogo.Free;
  end;
end;

end.
