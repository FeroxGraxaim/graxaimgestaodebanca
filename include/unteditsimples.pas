unit untEditSimples;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Buttons, Math,
  SQLScript, untApostas;

type

  { TformEditSimples }

  TformEditSimples = class(TForm)
    btnOk:      TBitBtn;
    btnCancel:  TBitBtn;
    btnNovaLinha: TButton;
    btnRemoverSelecionada: TButton;
    cbCompeticao: TComboBox;
    cbMandante: TComboBox;
    cbVisitante: TComboBox;
    dsEditarAposta: TDataSource;
    grbNovaLinha: TGroupBox;
    grdEditarAposta: TDBGrid;
    lbCompeticao: TLabel;
    lbMandante2: TLabel;
    lbVisitante2: TLabel;
    qrEditarAposta: TSQLQuery;
    qrEditarApostaCod_Mercado: TLargeintField;
    qrEditarApostaLinha: TStringField;
    qrEditarApostaMtodo: TStringField;
    qrEditarApostaOdd: TBCDField;
    qrEditarApostaSituacao: TStringField;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnRemoverSelecionadaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ClicarBotaoColuna(Sender: TObject);
    procedure grdEditarApostaEditingDone(Sender: TObject);
    function MudarJogo: boolean;
    function VerificaRegistros: boolean;
    procedure AtualizaMetodoELinha(Sender: TObject);
    procedure SalvarAoClicar(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
  private
    GlobalExcecao, Nao: boolean;
  public

  end;

var
  formEditSimples: TformEditSimples;
  Ok: boolean = False;
  EventosApostas: TEventosApostas;
  CodAposta: integer;

implementation

uses untMain;

  {$R *.lfm}

  { TformEditSimples }

procedure TformEditSimples.FormShow(Sender: TObject);
var
  comp, Mand, Visit: string;
begin
  Ok := False;
  with qrEditarAposta do
  begin
    if Active then Close;
    ParamByName('CodAposta').AsInteger := GlobalCodAposta;
    Open;
    CodAposta := GlobalCodAposta;
  end;
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'SELECT Competicao FROM Competicoes';
      Open;
      First;
      while not EOF do
      begin
        comp := FieldByName('Competicao').AsString;
        cbCompeticao.Items.AddObject(comp, TObject(comp));
        Next;
      end;
      Close;
      SQL.Text := 'SELECT Time FROM Times';
      Open;
      First;
      while not EOF do
      begin
        Mand  := FieldByName('Time').AsString;
        Visit := FieldByName('Time').AsString;
        cbMandante.Items.AddObject(Mand, TObject(Mand));
        cbVisitante.Items.AddObject(Visit, TObject(Visit));
        Next;
      end;
      Close;
      SQL.Text :=
        'SELECT C.Competicao, J.Mandante, J.Visitante ' + 'FROM Jogo J ' +
        'LEFT JOIN Mercados M ON M.Cod_Jogo = J.Cod_Jogo ' +
        'LEFT JOIN Apostas A ON M.Cod_Aposta = A.Cod_Aposta ' +
        'LEFT JOIN Competicoes C ON C.Cod_Comp = J.Cod_Comp ' +
        'WHERE A.Cod_Aposta = :codAposta ';
      ParamByName('codAposta').AsInteger := GlobalCodAposta;
      Open;
      comp  := FieldByName('Competicao').AsString;
      Mand  := FieldByName('Mandante').AsString;
      Visit := FieldByName('Visitante').AsString;
      cbCompeticao.ItemIndex := cbCompeticao.Items.IndexOf(comp);
      cbMandante.ItemIndex := cbMandante.Items.IndexOf(Mand);
      cbVisitante.ItemIndex := cbMandante.Items.IndexOf(Visit);
    finally
      Free;
    end;
end;

procedure TformEditSimples.AtualizaMetodoELinha(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    with formPrincipal.transactionBancoDados do
      with qrEditarAposta do
      begin
        Edit;
        FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
        writeln('Item selecionado: ', SelectedItem.Caption);
        Post;
      end;
  end;
end;

procedure TformEditSimples.SalvarAoClicar(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  with qrEditarAposta do
    if (State in [dsEdit, dsInsert]) then
      Post
    else
      Edit;
end;

procedure TformEditSimples.ClicarBotaoColuna(Sender: TObject);
var
  P:     TPoint;
  Query: TSQLQuery;
  Item:  TMenuItem;
begin
  with formPrincipal do
  begin
    Query := TSQLQuery.Create(nil);
    Query.DataBase := conectBancoDados;
    Screen.Cursor := crAppStart;
    popupLinhas.Items.Clear;

    with grdEditarAposta do
      ColunaAtual := Columns.ColumnByFieldName(SelectedField.FieldName);

    case ColunaAtual.FieldName of
      'Método':
      begin
        if Query.Active then Query.Close;
        Query.SQL.Text := 'SELECT Nome FROM Métodos';
        Query.Open;
        while not Query.EOF do
        begin
          Item := TMenuItem.Create(popupLinhas);
          Item.Caption := Query.FieldByName('Nome').AsString;
          Item.OnClick := @AtualizaMetodoELinha;
          popupLinhas.Items.Add(Item);
          Query.Next;
        end;
      end;
      'Linha':
      begin
        if Query.Active then Query.Close;
        Query.SQL.Text :=
          'SELECT Nome FROM Linhas WHERE Cod_Metodo = (SELECT Cod_Metodo FROM Métodos WHERE Métodos.Nome = :SelecMetodo)';
        Query.ParamByName('SelecMetodo').AsString :=
          qrEditarAposta.FieldByName('Método').AsString;
        Query.Open;
        while not Query.EOF do
        begin
          Item := TMenuItem.Create(popupLinhas);
          Item.Caption := Query.FieldByName('Nome').AsString;
          Item.OnClick := @AtualizaMetodoELinha;
          popupLinhas.Items.Add(Item);
          Query.Next;
        end;
      end;
      'Situacao':
      begin
        popupLinhas.Items.Clear;
        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Pré-live';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Green';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Red';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Anulada';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Meio Green';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Meio Red';
        Item.OnClick := @AtualizaMetodoELinha;
        popupLinhas.Items.Add(Item);
      end;
    end;

    P := Mouse.CursorPos;
    popupLinhas.PopUp(P.X, P.Y);
    Screen.Cursor := crDefault;
    Query.Free;
    qrEditarAposta.Edit;
  end;
end;

function TformEditSimples.MudarJogo: boolean;
begin
  with formPrincipal do
    with transactionBancoDados do
      with TSQLQuery.Create(nil) do
      begin
        try
          DataBase := conectBancoDados;
          SQL.Text :=
            'UPDATE Jogo SET                                        ' +
            'Cod_Comp = (SELECT Cod_Comp From Competicoes WHERE     ' +
            'Competicoes.Competicao = :Comp),                       ' +
            'Mandante = :mandante,                                  ' +
            'Visitante = :visitante                                 ' +
            'WHERE (SELECT Cod_Aposta FROM Mercados WHERE           ' +
            'Mercados.Cod_Jogo = Jogo.Cod_Jogo) = :CodAposta        ';
          ParamByName('Comp').AsString := cbCompeticao.Text;
          ParamByName('mandante').AsString := cbMandante.Text;
          ParamByName('visitante').AsString := cbVisitante.Text;
          ParamByName('CodAposta').AsInteger := CodAposta;
          ExecSQL;
          CommitRetaining;
          Result := True;
        except
          on E: Exception do
          begin
            Cancel;
            RollbackRetaining;
            writeln('Erro: ' + E.Message + ' Código SQL: ' + SQL.Text);
            Result := False;
          end;
        end;
        Free;
      end;
end;

procedure TformEditSimples.grdEditarApostaEditingDone(Sender: TObject);
begin
  with qrEditarAposta do
  begin
    Edit;
    writeln('Postando');
    Post;
    ApplyUpdates;
  end;
end;

procedure TformEditSimples.btnOkClick(Sender: TObject);
begin
  Ok := True;
  Close;
end;

procedure TformEditSimples.btnRemoverSelecionadaClick(Sender: TObject);
begin
  with qrEditarAposta do
  begin
    Delete;
    ApplyUpdates;
  end;
end;

procedure TformEditSimples.FormClose(Sender: TObject; var CloseAction: TCloseAction);
label
  AbortFech, SairSemSalvar;
begin
  with formPrincipal do
  begin
    if Ok then begin
      if not VerificaRegistros then goto AbortFech;
      if not MudarJogo then
      begin
        MessageDlg('Erro ao salvar alterações, tente novamente.', mtError,
        [mbOK], 0);
        goto SairSemSalvar;
      end;
      Exit;
    end
    else begin
      if MessageDlg('Confirmação',
        'Tem certeza que deseja cancelar a edição da aposta?',
        mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin
        AbortFech:
        CloseAction := caNone;
        Exit;
      end
      else
      begin
        SairSemSalvar:
        transactionBancoDados.RollbackRetaining;
      end;
    end;
  end;
end;

procedure TformEditSimples.btnCancelarClick(Sender: TObject);
begin
  Ok := False;
  Close;
end;

procedure TformEditSimples.btnNovaLinhaClick(Sender: TObject);
var
  CodJogo: integer;
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'INSERT INTO Mercados DEFAULT VALUES';
      ExecSQL;
      SQL.Text := 'SELECT J.Cod_Jogo FROM Jogo J      ' +
        'JOIN Mercados M ON M.Cod_Jogo = J.Cod_Jogo   ' +
        'WHERE M.Cod_Aposta = :CodAposta              ';
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      Open;
      CodJogo := FieldByName('Cod_Jogo').AsInteger;
      Close;
      SQL.Text := 'UPDATE Mercados SET Cod_Aposta = :CodAposta,     ' +
        'Cod_Jogo = :CodJogo                                        ' +
        'WHERE Cod_Mercado = (SELECT MAX(Cod_Mercado) FROM Mercados)';
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      ParamByName('CodJogo').AsInteger := CodJogo;
      ExecSQL;
      qrEditarAposta.Close;
      qrEditarAposta.Open;
    finally
      Free;
    end;
end;

function TformEditSimples.VerificaRegistros: boolean;
var
  NomePais, ComparaMandante, ComparaVisitante, ComparaCampeonato: string;
  MandanteExiste, VisitanteExiste, PaisExiste, CampeonatoExiste, Multipla: boolean;
label
  DigitarPais;
begin
  writeln('Verificando Registros');
  Result := False;
  with formPrincipal do
  begin
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Competicao FROM Competicoes WHERE Competicao = :comp';
        ComparaCampeonato := cbCompeticao.Text;
        ParamByName('comp').AsString := ComparaCampeonato;
        Open;
        CampeonatoExiste := (FieldByName('Competicao').AsString =
          ComparaCampeonato);
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :mandante';
        ComparaMandante := cbMandante.Text;
        ParamByName('mandante').AsString := ComparaMandante;
        Open;
        MandanteExiste := (FieldByName('Time').AsString = ComparaMandante);
        Close;
        SQL.Text := 'SELECT Time FROM Times WHERE Time = :visitante';
        ParamByName('visitante').AsString := cbVisitante.Text;
        Open;
        ComparaVisitante := cbVisitante.Text;

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

end.
