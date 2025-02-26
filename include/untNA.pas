unit untNA;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, LCLType,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Buttons,
  StrUtils, Grids;

type

  { TformNovaAposta }

  TformNovaAposta = class(TForm)
    btnOk:      TBitBtn;
    btnCancelar: TBitBtn;
    btnNovaLinha: TButton;
    btnNovaLinhaMult: TButton;
    btnAddJogo: TButton;
    btnEditJogo: TButton;
    btnCriarMetodo: TButton;
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
    procedure btnCriarMetodoClick(Sender: TObject);
    procedure btnNovaLinhaMultClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure edtValorKeyPress(Sender: TObject; var Key: char);
    procedure edtValorMouseEnter(Sender: TObject);
    procedure edtValorMouseLeave(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdLinhaMultEditingDone(Sender: TObject);
    procedure grdLinhaMultKeyPress(Sender: TObject; var Key: char);
    procedure ClicarBotaoColunaNovaAposta(Sender: TObject; aCol, aRow: integer);
    procedure EditarOddAposta(Column: TColumn);
    procedure grdNovaApostaEditingDone(Sender: TObject);
    procedure grdNovaApostaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure lsbJogosNAClick(Sender: TObject);
    procedure pcApostasChange(Sender: TObject);
    procedure pcApostasChanging(Sender: TObject; var AllowChange: boolean);
    procedure popupLinhasPopup(Sender: TObject);
    procedure tsMultiplaShow(Sender: TObject);
    procedure tsSimplesShow(Sender: TObject);

    procedure MudarUnidade(Sender: TObject);
    procedure LimparControle(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure SalvaColuna(Sender: TObject);
    procedure AdicionaMetodosLinhasStatus(Column: TColumn);
    procedure AutoFillETrocaDecimal(Sender: TObject; var Key: char);
    procedure HabilitaSemprePickList(Sender: TObject; const Rect: TRect;
      DataCol: integer; Column: TColumn; State: TGridDrawState);
    procedure HabilitarBotoes(Sender: TObject);
    procedure SalvarAoClicar(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure EditarJogoSelecionado(Sender: TObject);
  private
    MotivoOk: boolean;
    procedure CalcularValorAposta;
    procedure HabilitarBotaoOk;
    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure AtualizaMetLinMult(Sender: TObject);
    procedure HabilitarBtnNovaLinha;
    function VerificaRegistros: boolean;
    procedure HabilitaBotaoAddJogo;
    procedure DefineOdd;
    function MultiplosJogos: boolean;
    procedure PreencheJogos;
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
  EditarJogo: boolean;

implementation

uses
  untMain;

  {$R *.lfm}

  { TformNovaAposta }

procedure TformNovaAposta.btnAddJogoClick(Sender: TObject);
begin
  with formPrincipal do
  begin
    if not VerificaRegistros then Exit;

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
  end;
  PreencheJogos;

  cbCompMult.Text      := '';
  cbMandanteMult.Text  := '';
  cbVisitanteMult.Text := '';
  HabilitarBotoes(nil);
  lsbJogosNA.ItemIndex := lsbJogosNA.Items.IndexOf(InfoJogo.Text);
  lsbJogosNAClick(nil);
end;



procedure TformNovaAposta.FormShow(Sender: TObject);
var
  qrNACompeticao, qrNATimes: TSQLQuery;
begin
  EditarJogo    := False;
  MotivoOk      := False;
  GlobalMultipla := False;
  Screen.Cursor := crAppStart;

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

end;

procedure TformNovaAposta.ClicarBotaoColunaNovaAposta(Sender: TObject;
  aCol, aRow: integer);
var
  P:      TPoint;
  Query:  TDataSet;
  Grid:   TDBGrid;
  Item:   TMenuItem;
  Indice: integer;
begin
  Screen.Cursor := crAppStart;
  Grid  := TDBGrid(Sender);
  Query := Grid.DataSource.DataSet;

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
            'SELECT Nome FROM Linhas WHERE Cod_Metodo = ' +
            '(SELECT Cod_Metodo FROM Métodos WHERE Métodos.Nome = ' +
            ':SelecMetodo) ' +
            'ORDER BY CAST(REPLACE(REPLACE(TRIM(REPLACE(Nome, '' '', ' +
            ''''')), '','', ''.''), '' '', '''') AS NUMERIC)';
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
  if Column.FieldName = 'Odd' then Grid.EditorMode := True;
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

procedure TformNovaAposta.grdNovaApostaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  with qrNovaAPosta do
    if (State in [dsEdit, dsInsert]) then Post
    else
      Edit;
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
  pcApostas.SetFocus;
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

procedure TformNovaAposta.tsMultiplaShow(Sender: TObject);
begin
  GlobalMultipla := True;
  deApostaMult.SetFocus;
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

procedure TformNovaAposta.tsSimplesShow(Sender: TObject);
begin
  GlobalMultipla := False;
  deAposta.SetFocus;
  writeln('Exibida aba de aposta simples');
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
  if not GlobalMultipla then
    btnOk.Enabled := ((deAposta.Text <> '') and (cbCompeticao.Text <> '') and
      (cbMandante.Text <> '') and (cbVisitante.Text <> '') and
      (edtValor.Text <> '') and (Odd <> 0) and not
      qrNovaAposta.FieldByName('Método').IsNull and not
      qrNovaAposta.FieldByName('Linha').IsNull and not
      qrNovaAposta.FieldByName('Situacao').IsNull)
  else
    btnOk.Enabled := ((deApostaMult.Text <> '') and (edtValorMult.Text <> '') and
      (Odd <> 0) and not qrLinhaMultipla.FieldByName('Método').IsNull and
      not qrLinhaMultipla.FieldByName('Linha').IsNull and not
      qrLinhaMultipla.FieldByName('Situacao').IsNull);
end;

procedure TformNovaAposta.AtualizaMetodoLinha(Sender: TObject);
var
  SelectedItem: TMenuItem;
  Query: TSQLQuery;
begin
  SelectedItem := TMenuItem(Sender);
  if tsSimples.Showing then Query := qrNovaAposta
  else
    Query := qrLinhaMultipla;
  with Query do
  begin
    if Assigned(ColunaAtual) and Assigned(SelectedItem) then
    begin
      if not (State in [dsEdit, dsInsert]) then Edit;
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
  if tsSimples.Showing then
    btnNovaLinha.Enabled := ((cbCompeticao.Text <> '') and
      (cbMandante.Text <> '') and (cbVisitante.Text <> ''));
end;

procedure TformNovaAposta.btnCancelarClick(Sender: TObject);
begin
  MotivoOk := False;
  Close;
end;

procedure TformNovaAposta.btnCriarMetodoClick(Sender: TObject);
var
  CodMetodo: integer;
  Metodo, Linha: string;
label
  Voltar;
begin
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          Voltar:
          begin
            if CriarMetodoLinha(Linha, Metodo) then
              SQL.Text := 'SELECT Nome FROM Métodos WHERE Nome = :nome';
            ParamByName('nome').AsString := Metodo;
            Open;
          end;
          if IsEmpty then
          if MessageDlg('Método não existe', 'O método digitado não existe, ' +
          'deseja criá-lo agora?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
          then begin
            Close;
            SQL.Text := 'INSERT INTO Métodos (Nome) VALUES (:nome)';
            ParamByName('nome').AsString := Metodo;
            ExecSQL;
          end
          else goto Voltar;
          SQL.Text := 'SELECT Cod_Metodo FROM Métodos WHERE Nome = :nome';
          ParamByName('nome').AsString := Metodo;
          Open;
          CodMetodo := Fields[0].AsInteger;
          Close;
          SQL.Text := 'INSERT INTO Linhas (Cod_Metodo, Nome) VALUES (:cod, ' +
          ':nome)';
          ParamByName('cod').AsInteger := CodMetodo;
          ParamByName('nome').AsString := Metodo;
          ExecSQL;
          CommitRetaining;
        except
          On E: Exception do
          begin
            Cancel;
            RollbackRetaining;
            MessageDlg('Erro', 'Não foi possível criar método/ĺinha, tente ' +
            'novamente. Se o problema persistir favor informar no GitHub ' +
            'com a seguinte mensagem: ' + sLineBreak + sLineBreak + E.Message,
            mtError, [mbOk], 0);
          end;
        end;
        Free;
      end;
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

procedure TformNovaAposta.HabilitarBotoes(Sender: TObject);
begin
  HabilitarBotaoOk;
  HabilitarBtnNovaLinha;
  HabilitaBotaoAddJogo;
  btnEditJogo.Enabled := not qrJogos.IsEmpty;
end;

procedure TformNovaAposta.SalvarAoClicar(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  Query: TDataSet;
begin
  Query := TDBGrid(Sender).DataSource.DataSet;

  with Query do
    if (State in [dsEdit, dsInsert]) then begin
      Post;
      DefineOdd;
    end
    else
      Edit;
end;

procedure TformNovaAposta.EditarJogoSelecionado(Sender: TObject);
begin
  if not EditarJogo then
    with qrJogos do
    begin
      btnAddJogo.Enabled := False;
      cbCompMult.Text := FieldByName('Competição').AsString;
      cbMandanteMult.Text := FieldByName('Mandante').AsString;
      cbVisitanteMult.Text := FieldByName('Visitante').AsString;
      btnEditJogo.Caption := 'Salvar';
      EditarJogo := True;
    end
  else begin
    if not VerificaRegistros then Exit;
    with formPrincipal do
      with transactionBancoDados do
        with TSQLQuery.Create(nil) do
        begin
          DataBase := conectBancoDados;
          try
            SQL.Text := 'UPDATE Jogo SET Cod_Comp = (SELECT C.Cod_Comp ' +
              'FROM Competicoes C WHERE C.Competicao = :comp), Mandante = ' +
              ':mand, Visitante = :visit WHERE Cod_Jogo = :cod';
            ParamByName('comp').AsString := cbCompMult.Text;
            ParamByName('mand').AsString := cbMandanteMult.Text;
            ParamByName('visit').AsString := cbVisitanteMult.Text;
            ParamByName('cod').AsInteger := GlobalCodJogo;
            ExecSQL;
            CommitRetaining;
          except
            On E: Exception do
            begin
              Cancel;
              RollbackRetaining;
              MessageDlg('Erro', 'Não foi possível alterar jogo, tente ' +
                'novamente. Se o problema persistir favor informar no GitHub ' +
                'com a seguinte mensagem: ' + sLineBreak + sLineBreak +
                E.Message, mtError, [mbOK], 0);
            end;
          end;
          Free;
        end;
    PreencheJogos;
    EditarJogo      := False;
    btnEditJogo.Caption := 'Editar Jogo Selecionado';
    cbCompMult.Text := '';
    cbMandanteMult.Text := '';
    cbVisitanteMult.Text := '';
    HabilitarBotoes(nil);
    lsbJogosNA.ItemIndex := lsbJogosNA.Items.IndexOf(InfoJogo.Text);
    lsbJogosNAClick(nil);
  end;
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
  Salvar, Cancelar, Abortar, Fim;
begin
  if not MotivoOk then
    if MessageDlg('Deseja realmente cancelar o registro da aposta?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      goto Abortar
    else
      goto Cancelar;
  if not VerificaRegistros then
    goto Abortar
  else
  begin
    excecao := False;

    Multipla := not tsSimples.Showing;

    if Multipla and not MultiplosJogos then
    begin
      MessageDlg('Erro', 'Não é possível fazer aposta múltipla com apenas ' +
        'um jogo!', mtError, [mbOK], 0);
      Abortar:
      begin
        CloseAction := caNone;
        Exit;
      end;
    end;
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

function TformNovaAposta.VerificaRegistros: boolean;
var
  NomePais, ComparaMandante, ComparaVisitante, ComparaCampeonato: string;
  MandanteExiste, VisitanteExiste, PaisExiste, CampeonatoExiste, Multipla: boolean;
  Competicao, Mandante, Visitante: TComboBox;
label
  DigitarPais;
begin
  writeln('Verificando Registros');
  Result := False;
  with formPrincipal do
  begin
    Multipla := not tsSimples.Showing;
    if not Multipla then begin
      Competicao := cbCompeticao;
      Mandante   := cbMandante;
      Visitante  := cbVisitante;
    end
    else begin
      Competicao := cbCompMult;
      Mandante   := cbMandanteMult;
      Visitante  := cbVisitanteMult;
    end;
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Competicao FROM Competicoes WHERE Competicao = :comp';
        ComparaCampeonato := Competicao.Text;
        ParamByName('comp').AsString := ComparaCampeonato;
        Open;
        CampeonatoExiste := (FieldByName('Competicao').AsString =
          ComparaCampeonato);
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :mandante';
        ComparaMandante := Mandante.Text;
        ParamByName('mandante').AsString := ComparaMandante;
        Open;
        MandanteExiste := (FieldByName('Time').AsString = ComparaMandante);
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :visitante';
        ParamByName('visitante').AsString := Visitante.Text;
        Open;
        ComparaVisitante := Visitante.Text;

        VisitanteExiste := (ComparaVisitante = FieldByName('Time').AsString);

        if not CampeonatoExiste or not MandanteExiste or not VisitanteExiste then
          if MessageDlg(
            'Há time(s)/Competição inserido(s) que não está(ão) no banco de dados, ' +
            'ou houve um erro de digitação. Caso tenha digitado corretamente, deseja ' +
            'registrá-lo(s) no banco de dados agora?', mtConfirmation, [mbYes, mbNo], 0) =
            mrYes then
          begin
            DigitarPais:
              if not CampeonatoExiste then
                if InputQuery('Inserir Dados', 'Digite CORRETAMENTE o país do ' +
                'campeonato:', NomePais) then
                begin
                  Close;
                  SQL.Text := 'SELECT País FROM Países WHERE País = :país';
                  ParamByName('país').AsString := NomePais;
                  Open;
                  if NomePais <> FieldByName('País').AsString then
                    if MessageDlg(
                    'País não encontrado no banco de dados. Deseja registrá-lo agora?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
                    begin
                      Close;
                      SQL.Text := 'INSERT INTO Países (País) VALUES (:país)';
                      ParamByName('país').AsString := NomePais;
                      ExecSQL;
                    end
                    else
                      goto DigitarPais;
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
                    SQL.Text := 'INSERT INTO Times (Time) VALUES (:time)';
                    ParamByName('time').AsString := ComparaMandante;
                    ExecSQL;
                  end;
                  if not VisitanteExiste then
                  begin
                    Close;
                    SQL.Text := 'INSERT INTO Times (Time) VALUES (:time)';
                    ParamByName('time').AsString := ComparaVisitante;
                    ExecSQL;
                  end;
                end
                else begin
                  Result := False;
                  transactionBancoDados.RollbackRetaining;
                  Exit;
                end;
            transactionBancoDados.CommitRetaining;
            Result := True;
          end
          else
            Result := False
        else
          Result   := True;
      except
        on E: Exception do
        begin
          MessageDlg('Erro', 'Ocorreu um erro: ' + sLineBreak +
            E.Message, mtError, [mbOK], 0);
          Cancel;
          transactionBancoDados.RollbackRetaining;
          Result := False;
        end;
      end;
      Free;
    end;
  end;
end;

procedure TformNovaAposta.HabilitaBotaoAddJogo;
begin
  if tsMultipla.Showing then
    btnAddJogo.Enabled := (not EditarJogo and (cbCompMult.Text <> '') and
      (cbMandanteMult.Text <> '') and (cbVisitanteMult.Text <> ''));
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

function TformNovaAposta.MultiplosJogos: boolean;
begin
  Result := (qrJogos.FieldCount > 1);
end;

procedure TformNovaAposta.PreencheJogos;
begin
  with qrJogos do
  begin
    if not Active then Open
    else
      Refresh;
    lsbJogosNA.Items.Clear;
    First;
    while not EOF do
    begin
      InfoJogo      := TItemInfo.Create;
      InfoJogo.Text := FieldByName('Jogo').AsString;
      InfoJogo.CodJogo := FieldByName('CodJogo').AsInteger;
      ListaJogo.Add(InfoJogo);
      lsbJogosNA.Items.Add(InfoJogo.Text);
      Next;
    end;
  end;
end;

procedure TformNovaAposta.AdicionaMetodosLinhasStatus(Column: TColumn);
var
  Query:  TSQLQuery;
  Grid:   TDBGrid;
  Metodo: string;
begin
  if tsSimples.Showing then
  begin
    Query := qrNovaAposta;
    Grid  := grdNovaAposta;
  end
  else
  begin
    Query := qrLinhaMultipla;
    Grid  := grdLinhaMult;
  end;
  Query.Edit;
  with Grid do
  begin
    SelectedIndex := Column.Index;
    SetFocus;
  end;

  Column.PickList.Clear;

  with TSQLQuery.Create(nil) do
  try
    DataBase := formPrincipal.conectBancoDados;
    case Column.FieldName of
      'Método':
      begin
        if Grid.EditorMode then Grid.EditingDone;
        SQL.Text := 'SELECT Nome FROM Métodos';
        Open;
        while not EOF do
        begin
          Column.PickList.Add(FieldByName('Nome').AsString);
          Next;
        end;
        Close;
      end;

      'Linha':
      begin
        if Grid.EditorMode then Grid.EditingDone;
        Metodo   := Query.FieldByName('Método').AsString;
        SQL.Text := 'SELECT L.Nome AS Linha FROM Linhas L LEFT JOIN ' +
          'Métodos M ON M.Cod_Metodo = L.Cod_Metodo WHERE M.Nome = :met';
        writeln('Método: ', Metodo);
        ParamByName('met').AsString := Metodo;
        Open;
        while not EOF do
        begin
          Column.PickList.Add(FieldByName('Linha').AsString);
          Next;
        end;
        Close;
      end;

      'Odd': Query.Edit;

      'Situacao':
      begin
        if Grid.EditorMode then Grid.EditingDone;
        Column.PickList.Add('Pré-live');
        Column.PickList.Add('Green');
        Column.PickList.Add('Red');
        Column.PickList.Add('Anulada');
        Column.PickList.Add('Meio Green');
        Column.PickList.Add('Meio Red');
      end;
    end;
  finally
    Free;
  end;
end;

procedure TformNovaAposta.AutoFillETrocaDecimal(Sender: TObject; var Key: char);
var
  i:     integer;
  Texto: string;
  Grid:  TDBGrid;
begin
  if tsSimples.Showing then
    Grid := grdNovaAposta
  else
    Grid := grdLinhaMult;
  with Grid do
    {if (SelectedField.FieldName = 'Método') or
      (SelectedField.FieldName = 'Linha') or
      (SelectedField.FieldName = 'Situacao') then begin
      Texto := SelectedField.Text + Key;
      with Columns[SelectedIndex] do
        for i := 0 to PickList.Count - 1 do
          if Pos(LowerCase(Texto), LowerCase(PickList[i])) = 1 then begin
            SelectedField.Text := PickList[i];
            //SelectedField.SelStart := Length(Texto);
            Key := #0;
            Break;
          end;
    end
    else}
    case FormatSettings.DecimalSeparator of
      ',':
        if Key = '.' then
          Key := ',';
      '.':
        if Key = ',' then
          Key := '.';
    end;
end;

procedure TformNovaAposta.HabilitaSemprePickList(Sender: TObject;
  const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  Grid: TDBGrid;
begin
  if tsSimples.Showing then Grid := grdNovaAposta
  else
    Grid := grdLinhaMult;

  with Grid do
    if Column.PickList.Count > 0 then
    begin
      Canvas.FillRect(Rect);
      Canvas.MoveTo(Rect.Right - 15, Rect.Top + 5);
      Canvas.LineTo(Rect.Right - 10, Rect.Top + 5);
      Canvas.LineTo(Rect.Right - 12, Rect.Top + 7);
      Canvas.LineTo(Rect.Right - 8, Rect.Top + 7);
      Canvas.LineTo(Rect.Right - 10, Rect.Top + 9);
      Canvas.LineTo(Rect.Right - 15, Rect.Top + 9);
      Canvas.LineTo(Rect.Right - 12, Rect.Top + 7);
    end;
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

procedure TformNovaAposta.LimparControle(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  Application.ProcessMessages;
  writeln('Limpando controle');
  if Assigned(ActiveControl) then
    ActiveControl := nil;
  Application.ProcessMessages;
end;

end.
