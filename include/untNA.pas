unit untNA;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, LCLType,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Buttons,
  StrUtils;

type

  { TformNovaAposta }

  TformNovaAposta = class(TForm)
    btnOk:      TBitBtn;
    btnCancelar: TBitBtn;
    btnNovaLinha: TButton;
    btnNovaLinhaMult: TButton;
    btnAddJogo: TButton;
    cbCompeticao: TComboBox;
    cbCompMult: TComboBox;
    cbMandante: TComboBox;
    cbMandanteMult: TComboBox;
    cbUnidade:  TComboBox;
    cbUnidadeMult: TComboBox;
    cbVisitante: TComboBox;
    cbVisitanteMult: TComboBox;
    dsLinhaMultipla: TDataSource;
    dsJogos:    TDataSource;
    deAposta:   TDateEdit;
    deApostaMult: TDateEdit;
    dsNovaAposta: TDataSource;
    edtValor:   TEdit;
    edtValorMult: TEdit;
    grbNovaLinha: TGroupBox;
    grbNovaLinha1: TGroupBox;
    grdNovaAposta: TDBGrid;
    grdLinhaMult: TDBGrid;
    lbOddSimples: TLabel;
    lbData:     TLabel;
    lbOddMult:  TLabel;
    lbValorApMult: TLabel;
    lbDataMult: TLabel;
    lbUnidade:  TLabel;
    lbValorAp:  TLabel;
    lbUnidadeMult: TLabel;
    lbCompeticao: TLabel;
    lbCompeticao1: TLabel;
    lbMandante2: TLabel;
    lbMandanteMult: TLabel;
    lbOdd:      TLabel;
    lbOdd1:     TLabel;
    lbVisitante2: TLabel;
    lbVisitanteMult: TLabel;
    lsbJogosNA: TListBox;
    pcApostas:  TPageControl;
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
    qrLinhaMultiplaOdd: TBCDField;
    qrLinhaMultiplaROWID: TLargeintField;
    qrLinhaMultiplaSituacao: TStringField;
    qrNovaAposta: TSQLQuery;
    qrLinhaMultipla: TSQLQuery;
    qrNovaApostaCodJogo: TLongintField;
    qrNovaApostaCodLinha: TLongintField;
    qrNovaApostaCodMetodo: TLongintField;
    qrNovaApostaCompeticao: TStringField;
    qrNovaApostaData: TDateField;
    qrNovaApostaJogo: TStringField;
    qrNovaApostaLinha: TStringField;
    qrNovaApostaMandante: TStringField;
    qrNovaApostaMtodo: TStringField;
    qrNovaApostaOdd: TBCDField;
    qrNovaApostaROWID: TLongintField;
    qrNovaApostaSituacao: TStringField;
    qrNovaApostaVisitante: TStringField;
    scriptCancelar: TSQLScript;
    scriptNovaAposta: TSQLScript;
    scriptNovoJogo: TSQLScript;
    scriptNovoMercado: TSQLScript;
    qrJogos:    TSQLQuery;
    tsMultipla: TTabSheet;
    tsSimples:  TTabSheet;
    transactionNovaAposta: TSQLTransaction;
    procedure btnAddJogoClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovaLinhaMultClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure cbCompeticaoChange(Sender: TObject);
    procedure cbCompMultChange(Sender: TObject);
    procedure cbMandanteMultChange(Sender: TObject);
    procedure cbUnidadeChange(Sender: TObject);
    procedure cbUnidadeMultChange(Sender: TObject);
    procedure cbVisitanteChange(Sender: TObject);
    procedure cbVisitanteMultChange(Sender: TObject);
    procedure deApostaChange(Sender: TObject);
    procedure deApostaMultChange(Sender: TObject);
    procedure edtOddChange(Sender: TObject);
    procedure edtValorChange(Sender: TObject);
    procedure edtValorKeyPress(Sender: TObject; var Key: char);
    procedure edtValorMouseEnter(Sender: TObject);
    procedure edtValorMouseLeave(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdLinhaMultCellClick(Sender: TObject);
    procedure grdLinhaMultEditingDone(Sender: TObject);
    procedure grdLinhaMultKeyPress(Sender: TObject; var Key: char);
    procedure ClicarBotaoColunaNovaAposta(Sender: TObject);
    procedure EditarOddAposta(Column: TColumn);
    procedure grdNovaApostaColEnter(Sender: TObject);
    procedure grdNovaApostaColExit(Sender: TObject);
    procedure grdNovaApostaEditingDone(Sender: TObject);
    procedure grdNovaApostaExit(Sender: TObject);
    procedure grdNovaApostaKeyPress(Sender: TObject; var Key: char);
    procedure lsbJogosNAClick(Sender: TObject);
    procedure pcApostasChange(Sender: TObject);
    procedure pcApostasChanging(Sender: TObject; var AllowChange: boolean);
    procedure pcApostasEnter(Sender: TObject);
    procedure popupLinhasPopup(Sender: TObject);
    procedure tsMultiplaEnter(Sender: TObject);
    procedure tsMultiplaShow(Sender: TObject);
    procedure tsSimplesEnter(Sender: TObject);
    procedure tsSimplesShow(Sender: TObject);

    procedure MudarUnidade(Sender: TObject);
    procedure LimparControle(Sender: TObject);
    procedure SalvaColuna(Sender: TObject);
  private
    MotivoOk: boolean;
    procedure CalcularValorAposta;
    procedure HabilitarBotaoOk;
    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure AtualizaMetLinMult(Sender: TObject);
    procedure HabilitarBtnNovaLinha;
    procedure VerificaRegistros;
    procedure HabilitaBotaoAddJogo;
    procedure DefineOdd;
  public

  end;

  TItemInfo = class
    Text:    string;
    CodJogo: integer;
  end;

var
  formNovaAposta: TformNovaAposta;
  qrSavePoint: TSQLQuery;
  GlobalCodJogo: integer;
  ListaJogo: TList;
  InfoJogo: TItemInfo;
  GlobalExcecao: boolean;
  Nao: boolean;
  GlobalMultipla: boolean;
  Odd: double;

implementation

uses
  untMain;

  {$R *.lfm}

  { TformNovaAposta }

procedure TformNovaAposta.btnAddJogoClick(Sender: TObject);
begin
  with formPrincipal do
  begin
    VerificaRegistros;
    if GlobalExcecao or Nao then Exit;

    with TSQLQuery.Create(nil) do
    begin
      DataBase := conectBancoDados;
      try
        SQL.Text :=
          'INSERT INTO Jogo (Cod_Comp, Mandante, Visitante) ' +
          'VALUES (                                      ' +
          '   (SELECT Cod_Comp FROM Competicoes C         ' +
          '    WHERE C.Competicao = :Competicao),          ' +
          '   :Mandante, :Visitante)';
        ParamByName('Mandante').AsString := cbMandanteMult.Text;
        ParamByName('Visitante').AsString := cbVisitanteMult.Text;
        ParamByName('Competicao').AsString := cbCompMult.Text;
        ExecSQL;
        SQL.Text :=
          'INSERT INTO Mercados (Cod_Jogo, Cod_Aposta) ' +
          'VALUES (                                                          ' +
          '   (SELECT MAX(Cod_Jogo) FROM Jogo),                              ' +
          '   (SELECT MAX(Cod_Aposta) FROM Apostas))                           ';
        ExecSQL;
      except
        on E: Exception do
        begin
          MessageDlg('Erro', 'Erro ao inserir jogo, tente novamente. Se o problema ' +
            'persistir favor informar no GitHub com a seguinte mensagem: ' +
            sLineBreak + E.Message, mtError, [mbOK], 0);
          Cancel;
        end;
      end;
      Free;
    end;

    if qrJogos.Active then qrJogos.Refresh
    else
      qrJogos.Open;

    lsbJogosNA.Items.Clear;
    qrJogos.First;
    while not qrJogos.EOF do
    begin
      InfoJogo      := TItemInfo.Create;
      InfoJogo.Text := qrJogos.FieldByName('Jogo').AsString;
      InfoJogo.CodJogo := qrJogos.FieldByName('CodJogo').AsInteger;
      ListaJogo.Add(InfoJogo);
      lsbJogosNA.Items.Add(InfoJogo.Text);
      qrJogos.Next;
    end;
  end;
  HabilitarBotaoOk;

  cbCompMult.Text      := '';
  cbMandanteMult.Text  := '';
  cbVisitanteMult.Text := '';
  btnAddJogo.Enabled   := False;

  lsbJogosNA.ItemIndex := lsbJogosNA.Items.IndexOf(InfoJogo.Text);
  lsbJogosNAClick(nil);
end;



procedure TformNovaAposta.FormShow(Sender: TObject);
var
  qrNACompeticao, qrNATimes: TSQLQuery;
begin
  MotivoOk      := False;
  GlobalMultipla := False;
  Screen.Cursor := crAppStart;
  tsSimples.OnHide := @LimparControle;
  tsSimples.OnClick := @LimparControle;
  tsMultipla.OnClick := @LimparControle;
  tsMultipla.OnHide := @LimparControle;
  pcApostas.OnClick := @LimparControle;

  HabilitarBotaoOk;
  writeln('Criando aposta');
  writeln('Atualizando o query');
  if not qrNovaAposta.Active then qrNovaAposta.Open
  else
    qrNovaAposta.Refresh;
  CalcularValorAposta;
  //btnOk.Enabled := False;

  // Listar Competicoes no ComboBox "Competicao":
  writeln('Listando itens nos ComboBoxes');
  qrNACompeticao := TSQLQuery.Create(nil);
  qrNACompeticao.DataBase := formPrincipal.conectBancoDados;
  qrNACompeticao.SQL.Text := 'SELECT Competicao FROM Competicoes';
  qrNACompeticao.Open;
  while not qrNACompeticao.EOF do
  begin
    cbCompeticao.items.AddObject(
      qrNACompeticao.FieldByName('Competicao').AsString,
      TObject(qrNACompeticao.FieldByName('Competicao').AsString));
    cbCompMult.items.AddObject(
      qrNACompeticao.FieldByName('Competicao').AsString,
      TObject(qrNACompeticao.FieldByName('Competicao').AsString));
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

procedure TformNovaAposta.grdLinhaMultCellClick(Sender: TObject);
var
  P:      TPoint;
  Query:  TSQLQuery;
  Item:   TMenuItem;
  Indice: integer;
begin
  Query := TSQLQuery.Create(nil);
  Query.DataBase := formPrincipal.conectBancoDados;
  Screen.Cursor := crAppStart;
  popupLinhas.Items.Clear;
  with grdLinhaMult do
    with qrLinhaMultipla do
    begin
      {if (State in [dsEdit, dsInsert]) then begin
      writeln('Salvando odd');
      Indice := Columns.ColumnByFieldName('Odd').Index;
      FieldByName('Odd').AsFloat := Columns[Indice].Field.AsFloat;
      Post;
      DefineOdd;
      end;}
      qrLinhaMultipla.Edit;
      ColunaAtual := Columns.ColumnByFieldName(SelectedField.FieldName);
      case SelectedField.FieldName of
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
  with qrLinhaMultipla do
    if (State in [dsInsert, dsEdit]) then
    try
      Post;
      ApplyUpdates;
      Refresh;
    except
      Cancel;
    end;
  qrLinhaMultipla.Edit;
  DefineOdd;
  HabilitarBotaoOk;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.grdLinhaMultKeyPress(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
  DefineOdd;
end;

procedure TformNovaAposta.ClicarBotaoColunaNovaAposta(Sender: TObject);
var
  P:      TPoint;
  Query:  TSQLQuery;
  Grid:   TDBGrid;
  Item:   TMenuItem;
  Indice: integer;
begin
  //grdNovaApostaEditingDone(nil);
  Screen.Cursor := crAppStart;

  if tsSimples.Showing then begin
    Query := qrNovaAposta;
    Grid  := grdNovaAposta;
  end
  else begin
    Query := qrLinhaMultipla;
    Grid  := grdLinhaMult;
  end;

  popupLinhas.Items.Clear;
  with Grid do
  begin
    ColunaAtual := Columns.ColumnByFieldname(SelectedField.FieldName);
    with TSQLQuery.Create(nil) do
    try
      DataBase := formPrincipal.conectBancoDados;
      case SelectedField.FieldName of
        'Método':
        begin
          if Active then Close;
          SQL.Text := 'SELECT Nome FROM Métodos';
          Open;
        end;
        'Linha':
        begin
          if Query.Active then Close;
          SQL.Text :=
            'SELECT Nome FROM Linhas WHERE Cod_Metodo = (SELECT Cod_Metodo FROM Métodos WHERE Métodos.Nome = :SelecMetodo)';
          ParamByName('SelecMetodo').AsString :=
            Query.FieldByName('Método').AsString;
          Open;
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
      while not EOF do
      begin
        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := FieldByName('Nome').AsString;
        Item.OnClick := @AtualizaMetodoLinha;
        popupLinhas.Items.Add(Item);
        Next;
      end;
    finally
      Free;
    end;
    P := Mouse.CursorPos;
    popupLinhas.PopUp(P.X, P.Y);
    Screen.Cursor := crDefault;
    HabilitarBotaoOk;
  end;
end;

procedure TformNovaAposta.EditarOddAposta(Column: TColumn);
var
  Query: TSQLQuery;
  Grid:  TDBGrid;
begin
  //Verificando se a aposta é simples ou múltipla
  if tsSimples.Showing then begin
    Query := qrNovaAposta;
    Grid  := grdNovaAposta;
  end
  else begin
    Query := qrLinhaMultipla;
    Grid  := grdLinhaMult;
  end;
  ColunaAtual := Column;
    if Column.FieldName = 'Odd' then Grid.EditorMode := true;
end;

procedure TformNovaAposta.grdNovaApostaColEnter(Sender: TObject);
begin
  grdNovaApostaEditingDone(nil);
end;

procedure TformNovaAposta.grdNovaApostaColExit(Sender: TObject);
begin
  {with grdNovaAposta do
    if EditorMode then EditingDone; }
end;

procedure TformNovaAposta.grdNovaApostaEditingDone(Sender: TObject);
begin
  Screen.Cursor := crAppStart;
  with qrNovaAposta do
    if (State in [dsInsert, dsEdit]) then
    try
      writeln('Postando alterações após editar');
      Post;
      ApplyUpdates;
    except
      Cancel;
    end;
  //qrNovaAposta.Edit;
  DefineOdd;
  HabilitarBotaoOk;
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.grdNovaApostaExit(Sender: TObject);
begin

end;

procedure TformNovaAposta.grdNovaApostaKeyPress(Sender: TObject; var Key: char);
begin
  if FormatSettings.DecimalSeparator = ',' then
    if Key = '.' then
      Key := ','
    else if FormatSettings.DecimalSeparator = '.' then
      if Key = ',' then
        Key := '.';
  DefineOdd;
end;

procedure TformNovaAposta.lsbJogosNAClick(Sender: TObject);
var
  CodJogo, i: integer;
begin
  with formPrincipal do
  begin
    if lsbJogosNA.ItemIndex <> -1 then
    begin
      CodJogo := -1;

      for i := 0 to ListaJogo.Count - 1 do
      begin
        if TItemInfo(ListaJogo[i]).Text = lsbJogosNA.Items[lsbJogosNA.ItemIndex] then
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
      writeln('Aberto query com o código de jogo ', GlobalCodJogo);
    end;
    if not grdLinhaMult.Enabled and not btnNovaLinhaMult.Enabled then
    begin
      grdLinhaMult.Enabled     := True;
      btnNovaLinhaMult.Enabled := True;
    end;
  end;
end;

procedure TformNovaAposta.pcApostasChanging(Sender: TObject; var AllowChange: boolean);
begin
  Application.ProcessMessages;
  if Assigned(ActiveControl) then
    ActiveControl := nil;
  Application.ProcessMessages;
end;

procedure TformNovaAposta.pcApostasEnter(Sender: TObject);
begin

end;

procedure TformNovaAposta.popupLinhasPopup(Sender: TObject);
begin
  EditarOddAposta(ColunaAtual);
end;


procedure TformNovaAposta.pcApostasChange(Sender: TObject);
begin
  Application.ProcessMessages;
  if Assigned(ActiveControl) then
    ActiveControl := nil;
  Application.ProcessMessages;
  if tsSimples.Showing then
    GlobalMultipla := True
  else if tsMultipla.Showing then
    GlobalMultipla := False;
end;

procedure TformNovaAposta.tsMultiplaEnter(Sender: TObject);
begin
  //deApostaMult.SetFocus;
end;

procedure TformNovaAposta.tsMultiplaShow(Sender: TObject);
begin
  GlobalMultipla := True;
  //LimparControle(nil);
  with TSQLQuery.Create(nil) do
  begin
    DataBase := formPrincipal.conectBancoDados;
    try
      formPrincipal.transactionBancoDados.RollbackRetaining;
      SQL.Text := 'UPDATE Apostas SET Múltipla = 1 WHERE Cod_Aposta = ' +
        '(SELECT MAX(Cod_Aposta) FROM Apostas)';
      writeln('SQL: ', SQL.Text);
      ExecSQL;
      SQL.Text := 'DELETE FROM Jogo WHERE Cod_Jogo = (SELECT Cod_Jogo FROM Mercados ' +
        'WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo AND Mercados.Cod_Aposta = (SELECT MAX('
        +
        'Cod_Aposta) FROM Apostas))';
      writeln('SQL: ', SQL.Text);
      ExecSQL;
      SQL.Text := 'DELETE FROM Mercados WHERE Cod_Aposta = (SELECT MAX(Cod_Aposta)' +
        'FROM Apostas)';
      writeln('SQL: ', SQL.Text);
      ExecSQL;
      LimparControle(nil);
    except
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message);
        Cancel;
      end;
    end;
    Free;
  end;
end;

procedure TformNovaAposta.tsSimplesEnter(Sender: TObject);
begin
  //deAposta.SetFocus;
end;

procedure TformNovaAposta.tsSimplesShow(Sender: TObject);
begin
  GlobalMultipla := False;
  writeln('Exibida aba de aposta simples');
  LimparControle(nil);
  HabilitarBotaoOk;
  if qrNovaAposta.Active then qrNovaAposta.Close;
  try
    with TSQLQuery.Create(nil) do
    begin
      try
        formPrincipal.transactionBancoDados.RollbackRetaining;
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
        qrNovaAposta.Insert;
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
begin
  //Calculando valor da aposta
  case cbUnidade.Text of
    '0,25 Un': CalcUnidade := 0.25;
    '0,5 Un': CalcUnidade  := 0.5;
    '0,75 Un': CalcUnidade := 0.75;
    '1 Un': CalcUnidade    := 1.0;
    '1,25 Un': CalcUnidade := 1.25;
    '1,5 Un': CalcUnidade  := 1.5;
    '1,75 Un': CalcUnidade := 1.75;
    '2 Un': CalcUnidade    := 2.0;
    else
      CalcUnidade := 1.0;
  end;
  ValorAposta   := (stakeAposta * CalcUnidade);
  edtValor.Text := FormatFloat('0.00', ValorAposta);

  case cbUnidadeMult.Text of
    '0,25 Un': CalcUnidade := 0.25;
    '0,5 Un': CalcUnidade  := 0.5;
    '0,75 Un': CalcUnidade := 0.75;
    '1 Un': CalcUnidade    := 1.0;
    '1,25 Un': CalcUnidade := 1.25;
    '1,5 Un': CalcUnidade  := 1.5;
    '1,75 Un': CalcUnidade := 1.75;
    '2 Un': CalcUnidade    := 2.0;
    else
      CalcUnidade := 1.0;
  end;
  ValorAposta := (stakeAposta * CalcUnidade);
  edtValorMult.Text := FormatFloat('0.00', ValorAposta);
end;

procedure TformNovaAposta.HabilitarBotaoOk;
begin
  if tsSimples.Showing then
  begin
    //writeln('Verificando se pode habilitar o botão Ok em aposta simples');
    if (deAposta.Text <> '') and (cbCompeticao.Text <> '') and
      (cbMandante.Text <> '') and (cbVisitante.Text <> '') and
      (edtValor.Text <> '') and (Odd <> 0) and not
      qrNovaAposta.FieldByName('Método').IsNull and not
      qrNovaAposta.FieldByName('Linha').IsNull and not
      qrNovaAposta.FieldByName('Situacao').IsNull then btnOk.Enabled := True
    else
      btnOk.Enabled := False;
  end
  else if tsMultipla.Showing then
  begin
    //writeln('Verificando se pode habilitar o botão Ok em aposta múltipla');
    if (deApostaMult.Text <> '') and (edtValorMult.Text <> '') and
      (Odd <> 0) and not qrLinhaMultipla.FieldByName('Método').IsNull and
      not qrLinhaMultipla.FieldByName('Linha').IsNull and not
      qrLinhaMultipla.FieldByName('Situacao').IsNull then btnOk.Enabled := True
    else
      btnOk.Enabled := False;
  end;
end;

procedure TformNovaAposta.AtualizaMetodoLinha(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  with qrNovaAposta do
  begin
    if Assigned(ColunaAtual) and Assigned(SelectedItem) then
    begin
      Edit;
      FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
      writeln('Item selecionado: ', SelectedItem.Caption);
      Post;
    end;
  end;
end;

procedure TformNovaAposta.AtualizaMetLinMult(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    with qrLinhaMultipla do
    begin
      Edit;
      case ColunaAtual.FieldName of
        'Método': FieldByName('Método').AsString := SelectedItem.Caption;
        'Linha': FieldByName('Linha').AsString     := SelectedItem.Caption;
        'Situacao': FieldByName('Situacao').AsString := SelectedItem.Caption;
      end;
      writeln('Item selecionado: ', SelectedItem.Caption);
      Post;
      DefineOdd;
    end;
  end;
end;

procedure TformNovaAposta.HabilitarBtnNovaLinha;
begin
  if (cbCompeticao.Text <> '') and (cbMandante.Text <> '') and
    (cbVisitante.Text <> '') then
    btnNovaLinha.Enabled := True
  else
    btnNovaLinha.Enabled := False;
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
    with qrLinhaMultipla do
      if State = dsEdit then Post;
    if not qrLinhaMultipla.Active then qrLinhaMultipla.Open;
    qrLinhaMultipla.Insert;
    qrLinhaMultipla.Edit;
    qrLinhaMultipla.FieldByName('CodJogo').AsInteger := GlobalCodJogo;
    qrLinhaMultipla.ApplyUpdates;
    qrLinhaMultipla.Refresh;
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
    Data      := qrNovaAposta.FieldByName('Data').AsDateTime;
    Competicao := qrNovaAposta.FieldByName('Competicao').AsString;
    Jogo      := qrNovaAposta.FieldByName('Jogo').AsString;
    Mandante  := qrNovaAposta.FieldByName('Mandante').AsString;
    Visitante := qrNovaAposta.FieldByName('Visitante').AsString;
    writeln('Inserido nova linha');
    qrNovaAposta.Insert;
    qrNovaAposta.FieldByName('Data').AsDateTime := Data;
    qrNovaAposta.FieldByName('Competicao').AsString := Competicao;
    qrNovaAposta.FieldByName('Mandante').AsString := Mandante;
    qrNovaAposta.FieldByName('Visitante').AsString := Visitante;
    qrNovaAposta.FieldByName('Jogo').AsString := Jogo;
    qrNovaAposta.Post;
    qrNovaAposta.ApplyUpdates;
    qrNovaAposta.Refresh;
    qrNovaAposta.Edit;
    if not grdNovaAposta.Enabled then
      grdNovaAposta.Enabled := True;
  except
    on E: Exception do
    begin
      MessageDlg('Erro',
        'Erro ao inserir mercado, tente novamente. Se o problema persistir ' +
        'informe no Github com a seguinte mensagem: ' + sLineBreak + E.Message,
        mtError, [mbOK], 0);
    end;
  end;
end;


procedure TformNovaAposta.cbCompeticaoChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitarBtnNovaLinha;
end;

procedure TformNovaAposta.cbCompMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitaBotaoAddJogo;
end;

procedure TformNovaAposta.cbUnidadeChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitarBtnNovaLinha;
end;

procedure TformNovaAposta.cbMandanteMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitaBotaoAddJogo;
end;

procedure TformNovaAposta.MudarUnidade(Sender: TObject);
begin

  //Simples
  if Sender = cbUnidade then
    if cbUnidade.Text = 'Outro Valor' then
    begin
      edtValor.ReadOnly := False;
      edtValor.Color    := clWindow;
      edtValor.Cursor   := crIBeam;
    end
    else
    begin
      edtValor.ReadOnly := True;
      edtValor.Color    := clInactiveBorder;
      edtValor.Cursor   := crNo;
    end
  else if Sender = cbUnidadeMult then
    if cbUnidadeMult.Text = 'Outro Valor' then
    begin
      edtValorMult.ReadOnly := False;
      edtValorMult.Color    := clWindow;
      edtValorMult.Cursor   := crIBeam;
    end
    else
    begin
      edtValorMult.ReadOnly := True;
      edtValorMult.Color    := clInactiveBorder;
      edtValorMult.Cursor   := crNo;
    end;
  CalcularValorAposta;
  HabilitarBotaoOk;
end;

procedure TformNovaAposta.cbUnidadeMultChange(Sender: TObject);
begin
  if cbUnidadeMult.Text = 'Outro Valor' then
  begin
    edtValorMult.ReadOnly := False;
    edtValorMult.Color    := clWindow;
    edtValorMult.Cursor   := crIBeam;
  end
  else
  begin
    edtValorMult.ReadOnly := True;
    edtValorMult.Color    := clInactiveBorder;
    edtValorMult.Cursor   := crNo;
  end;
  CalcularValorAposta;
  HabilitarBotaoOk;
end;



procedure TformNovaAposta.cbVisitanteChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitarBtnNovaLinha;
end;

procedure TformNovaAposta.cbVisitanteMultChange(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitaBotaoAddJogo;
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
    Screen.Cursor := crNo;
end;

procedure TformNovaAposta.edtValorMouseLeave(Sender: TObject);
begin
  Screen.Cursor := crDefault;
end;

procedure TformNovaAposta.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
  excecao, Multipla: boolean;
label
  Salvar, Cancelar, Fim;
begin
  if not MotivoOk then
    if MessageDlg('Deseja realmente cancelar o registro da aposta?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    begin
      CloseAction := caNone;
      Exit;
    end
    else
      goto Cancelar;

  GlobalExcecao := False;

  VerificaRegistros;

  if GlobalExcecao or Nao then
  begin
    CloseAction := caNone;
    Exit;
  end
  else
  begin
    excecao := False;

    if tsSimples.Showing then Multipla := False
    else if tsMultipla.Showing then Multipla := True;

    with formPrincipal do
    begin
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := formPrincipal.conectBancoDados;
          writeln('Excluindo registros vazios');
          SQL.Text :=
            'DELETE FROM Mercados WHERE Cod_Metodo IS NULL AND Cod_Linha IS NULL';
          ExecSQL;
          writeln('Atualizando tabela "Apostas"');
          SQL.Text :=
            'UPDATE Apostas                                     ' +
            'SET                                                ' +
            '    Data = :Data,                                  ' +
            'Valor_Aposta = :Valor_Aposta,                      ' +
            'Múltipla = :Múltipla,                              ' +
            'Odd = :Odd                                         ' +
            'WHERE                                              ' +
            'Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas);';
          writeln('SQL: ', SQL.Text);

          if not Multipla then
          begin
            ParamByName('Data').AsDateTime := deAposta.Date;
            ParamByName('Valor_Aposta').AsFloat := StrToFloat(edtValor.Text);
            ParamByName('Múltipla').AsBoolean := False;
            ParamByName('Odd').AsFloat := Odd;
          end
          else
          begin
            ParamByName('Data').AsDateTime := deApostaMult.Date;
            ParamByName('Valor_Aposta').AsFloat := StrToFloat(edtValorMult.Text);
            ParamByName('Múltipla').AsBoolean := True;
            ParamByName('Odd').AsFloat := Odd;
          end;
          ExecSQL;

        except
          on E: Exception do
          begin
            Cancel;
            writeln('Erro ao atualizar tabela Apostas: ' + E.Message);
            MessageDlg('Erro',
              'Ocorreu um erro, a aposta será cancelada. Se o problema persistir ' +
              'favor informe no Github com a seguinte mensagem: ' +
              sLineBreak + E.Message,
              mtError, [mbOK], 0);
            excecao := True;
          end;
        end;

        Salvar:

          if excecao then
          begin
            Free;
            goto Cancelar;
          end;

        try
          if not Multipla then
          begin
            SQL.Text :=
              'UPDATE Jogo SET Cod_Comp = (SELECT Cod_Comp FROM Competicoes ' +
              'WHERE Competicao = :Comp), Mandante = :Mandante, Visitante = :Visitante '
              + 'WHERE (SELECT Cod_Aposta FROM Mercados ' +
              'WHERE Mercados.Cod_Jogo = Jogo.Cod_Jogo ' +
              'AND Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas))';
            ParamByName('Comp').AsString := cbCompeticao.Text;
            ParamByName('Mandante').AsString := cbMandante.Text;
            ParamByName('Visitante').AsString := cbVisitante.Text;
            writeln('SQL: ', SQL.Text);
            ExecSQL;
          end;
          writeln('Salvando alterações no banco de dados');
          transactionBancoDados.Commitretaining;
        except
          on E: Exception do
          begin
            writeln('Erro ao salvar aposta ' + E.Message);
            MessageDlg('Erro',
              'Erro ao salvar, aposta será cancelada. Se o problema persistir ' +
              'favor informe no Github com a seguinte mensagem: ' +
              sLineBreak + sLineBreak + E.Message,
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

        writeln
        ('Desfazendo alterações no banco de dados');
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        SQL.Text := 'DELETE FROM Jogo ' +
          'WHERE Jogo.Cod_Jogo = (SELECT Cod_Jogo FROM Mercados WHERE  ' +
          'Mercados.Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas)) ';
        ExecSQL;
        SQL.Text := 'DELETE FROM Mercados WHERE Mercados.Cod_Aposta = ' +
          '(SELECT MAX(Cod_Aposta) FROM Apostas)';
        writeln('SQL: ', SQL.Text);
        SQL.Text :=
          'DELETE FROM Apostas WHERE Cod_Aposta = ' +
          '(SELECT MAX(Cod_Aposta) FROM Apostas)';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        writeln('Salvando processos no banco de dados');
        transactionBancoDados.CommitRetaining;
        Free;
      except
        on E: Exception do
        begin
          transactionBancoDados.RollbackRetaining;
          writeln('Erro: ' + E.Message + 'Código: ' + SQL.Text);
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
end;

procedure TformNovaAposta.VerificaRegistros;
var
  NomePais, ComparaMandante, ComparaVisitante, ComparaCampeonato: string;
  MandanteExiste, VisitanteExiste, PaisExiste, CampeonatoExiste, Multipla: boolean;
begin
  with formPrincipal do
  begin
    Nao := False;
    if tsSimples.Showing then Multipla := False
    else if tsMultipla.Showing then Multipla := True;
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Competicao FROM Competicoes WHERE Competicao = :comp';
        if not Multipla then
          ComparaCampeonato := cbCompeticao.Text
        else
          ComparaCampeonato := cbCompMult.Text;
        ParamByName('comp').AsString := ComparaCampeonato;
        Open;
        if FieldByName('Competicao').AsString = ComparaCampeonato then
          CampeonatoExiste := True
        else
          CampeonatoExiste := False;
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :mandante';
        if not Multipla then
          ComparaMandante := cbMandante.Text
        else
          ComparaMandante := cbMandanteMult.Text;
        ParamByName('mandante').AsString := ComparaMandante;
        Open;
        if FieldByName('Time').AsString = ComparaMandante then
          MandanteExiste := True
        else
          MandanteExiste := False;
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :visitante';
        if not Multipla then ParamByName('visitante').AsString :=
            cbVisitante.Text
        else
          ParamByName('visitante').AsString :=
            cbVisitanteMult.Text;
        Open;
        if not Multipla then
          ComparaVisitante := cbVisitante.Text
        else
          ComparaVisitante := cbVisitanteMult.Text;

        if ComparaVisitante = FieldByName('Time').AsString then
          VisitanteExiste := True
        else
          VisitanteExiste := False;

        if not CampeonatoExiste or not MandanteExiste or not VisitanteExiste then
        begin
          if MessageDlg(
            'Há time(s)/Competição inserido(s) que não está(ão) no banco de dados, ' +
            'ou houve um erro de digitação. Caso tenha digitado corretamente, deseja ' +
            'registrá-lo(s) no banco de dados agora?', mtConfirmation, [mbYes, mbNo], 0) =
            mrYes then
          begin
            if InputQuery('Inserir Dados',
              'Digite CORRETAMENTE o país do time/campeonato:', NomePais) then
            begin
              Close;
              SQL.Text := 'SELECT País FROM Países WHERE País = :país';
              ParamByName('país').AsString := NomePais;
              Open;
              if NomePais <> FieldByName('País').AsString then
              begin
                if MessageDlg(
                  'País não encontrado no banco de dados. Deseja registrá-lo agora?',
                  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                begin
                  Close;
                  SQL.Text := 'INSERT INTO Países (País) VALUES (:país)';
                  ParamByName('país').AsString := NomePais;
                  ExecSQL;
                end;
              end;
              if not CampeonatoExiste then
              begin
                Close;
                SQL.Text :=
                  'INSERT INTO Competicoes (País, Competicao) VALUES (:pais, :comp)';
                ParamByName('pais').AsString := NomePais;
                ParamByName('comp').AsString := ComparaCampeonato;
                ExecSQL;
              end;
              if not MandanteExiste then
              begin
                Close;
                SQL.Text := 'INSERT INTO Times (País, Time) VALUES (:pais, :time)';
                ParamByName('pais').AsString := NomePais;
                ParamByName('time').AsString := ComparaMandante;
                ExecSQL;
              end;
              if not VisitanteExiste then
              begin
                Close;
                SQL.Text := 'INSERT INTO Times (País, Time) VALUES (:pais, :time)';
                ParamByName('pais').AsString := NomePais;
                ParamByName('time').AsString := ComparaVisitante;
                ExecSQL;
              end;
            end
            else
              Nao := True;
            transactionBancoDados.CommitRetaining;
          end
          else
            Nao := True;
        end;
      except
        on E: Exception do
        begin
          MessageDlg('Erro', 'Ocorreu um erro: ' + sLineBreak +
            E.Message, mtError, [mbOK], 0);
          Cancel;
          transactionBancoDados.RollbackRetaining;
          GlobalExcecao := True;
        end;
      end;
      Free;
    end;
  end;
end;

procedure TformNovaAposta.HabilitaBotaoAddJogo;
begin
  if (cbCompMult.Text <> '') and (cbMandanteMult.Text <> '') and
    (cbVisitanteMult.Text <> '') then btnAddJogo.Enabled := True
  else
    btnAddJogo.Enabled := False;
end;

procedure TformNovaAposta.DefineOdd;
var
  OddFormat: string;
begin
  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text :=
        'SELECT Odd FROM Mercados WHERE Mercados.Cod_Aposta = (SELECT MAX(Cod_Aposta) FROM Apostas)';
      Open;
      First;
      Odd := FieldByName('Odd').AsFloat;
      Next;
      while not EOF do
      begin
        if FieldByName('Odd').IsNull then
          Odd := Odd * 1
        else
          Odd := Odd * FieldByName('Odd').AsFloat;
        OddFormat := FormatFloat('0.00', Odd);
        Odd := StrToFloat(OddFormat);
        Next;
      end;
    finally
      Free;
    end;
  end;
  if tsSimples.Showing then lbOddSimples.Caption := FormatFloat('0.00', Odd)
  else if tsMultipla.Showing then lbOddMult.Caption := FormatFloat('0.00', Odd);
end;

procedure TformNovaAposta.SalvaColuna(Sender: TObject);
var
  Query: TSQLQuery;
begin
  if tsSimples.Showing then
    Query := qrNovaAposta
  else
    Query := qrLinhaMultipla;
  with Query do
    if (State in [dsInsert, dsEdit]) then
    try
      writeln('Postando alterações no procedimento "Salva coluna"');
      Post;
      ApplyUpdates;
      Refresh;
    except
      Cancel;
    end;
end;

procedure TformNovaAposta.LimparControle(Sender: TObject);
begin
  Application.ProcessMessages;
  writeln('Limpando controle');
  if Assigned(ActiveControl) then
    ActiveControl := nil;
  Application.ProcessMessages;
end;

end.
