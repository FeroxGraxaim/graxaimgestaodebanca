unit untEditMult;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Buttons, Math,
  SQLScript;

type

  { TformEditMult }

  TformEditMult = class(TForm)
    btnAlterar: TButton;
    btnNovoJogo: TButton;
    btnOk:      TBitBtn;
    btnCancel:  TBitBtn;
    btnNovaLinha: TButton;
    btnRemoverJogo: TButton;
    btnRemoverLinha: TButton;
    cbCompeticao: TComboBox;
    cbMandante: TComboBox;
    cbVisitante: TComboBox;
    dsJogo:     TDataSource;
    dsMetodo:   TDataSource;
    grbLinhas:  TGroupBox;
    grbJogos:   TGroupBox;
    grdLinhas:  TDBGrid;
    lbCompeticao: TLabel;
    lbMandante2: TLabel;
    lbVisitante2: TLabel;
    lsbJogos:   TListBox;
    qrJogo:     TSQLQuery;
    qrJogoCod_Jogo: TLargeintField;
    qrJogoCompeticao: TStringField;
    qrJogoMandante: TStringField;
    qrJogoVisitante: TStringField;
    qrMetodo:   TSQLQuery;
    qrMetodoCod_Mercado: TLargeintField;
    qrMetodoLinha: TStringField;
    qrMetodoMtodo: TStringField;
    qrMetodoOdd: TBCDField;
    qrMetodoStatus: TStringField;
    procedure btnAlterarClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure btnNovoJogoClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnRemoverJogoClick(Sender: TObject);
    procedure btnRemoverLinhaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure AtualizaMetLin(Sender: TObject);
    procedure grdJogosEditingDone(Sender: TObject);
    procedure grdLinhasEditingDone(Sender: TObject);
    procedure lsbJogosClick(Sender: TObject);
    procedure SalvarAoClicar(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure ClicarBotaoColuna(Sender: TObject);
  private
    Ok, GlobalExcecao, Nao: boolean;
    function VerificaRegistros;
    procedure CarregaJogos;
    function MultiplosJogos: Boolean;
  public

  end;

  TItemInfo = class
    Text:    string;
    CodJogo: integer;
  end;

var
  formEditMult:  TformEditMult;
  InfoJogo:      TItemInfo;
  ListaJogo:     TList;
  GlobalCodJogo: integer;

implementation

uses
  untMain, untApostas;

  {$R *.lfm}

  { TformEditMult }

procedure TformEditMult.FormShow(Sender: TObject);
var
  comp, Mand, Visit: string;
begin
  Ok := False;
  ListaJogo := TList.Create;
  InfoJogo := TItemInfo.Create;
  with formPrincipal do
  begin
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
    finally
      Free;
    end;
    with qrJogo do
    begin
      if Active then Close;
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      Open;
      First;
    end;
    CarregaJogos;
  end;
end;

procedure TformEditMult.lsbJogosClick(Sender: TObject);
var
  CodJogo, i: integer;
begin
  begin
    if lsbJogos.ItemIndex <> -1 then
    begin
      CodJogo := -1;

      for i := 0 to ListaJogo.Count - 1 do
      begin
        if TItemInfo(ListaJogo[i]).Text = lsbJogos.Items[lsbJogos.ItemIndex] then
        begin
          writeln(TItemInfo(ListaJogo[i]).Text);
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

      if qrMetodo.Active then
        qrMetodo.Close;
      with qrJogo do
      begin
        Locate('Cod_Jogo', CodJogo, []);
        cbCompeticao.Text := FieldByName('Competicao').AsString;
        cbMandante.Text   := FieldByName('Mandante').AsString;
        cbVisitante.Text  := FieldByName('Visitante').AsString;
      end;
      with qrMetodo do
      begin
        if Active then Close;
        ParamByName('CodJogo').AsInteger := CodJogo;
        Open;
      end;
      writeln('Aberto query com o código de jogo ', CodJogo);
    end;
  end;
end;

procedure TformEditMult.SalvarAoClicar(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  with qrMetodo do
    if (State in [dsEdit, dsInsert]) then
      Post
    else
      Edit;
end;

procedure TformEditMult.ClicarBotaoColuna(Sender: TObject);
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

    with grdLinhas do
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
          Item.OnClick := @AtualizaMetLin;
          popupLinhas.Items.Add(Item);
          Query.Next;
        end;
      end;
      'Linha':
      begin
        if Query.Active then Query.Close;
        Query.SQL.Text :=
          'SELECT Nome FROM Linhas WHERE Cod_Metodo = (SELECT Cod_Metodo FROM ' +
          'Métodos WHERE Métodos.Nome = :SelecMetodo)';
        Query.ParamByName('SelecMetodo').AsString :=
          qrMetodo.FieldByName('Método').AsString;
        Query.Open;
        while not Query.EOF do
        begin
          Item := TMenuItem.Create(popupLinhas);
          Item.Caption := Query.FieldByName('Nome').AsString;
          Item.OnClick := @AtualizaMetLin;
          popupLinhas.Items.Add(Item);
          Query.Next;
        end;
      end;
      'Status':
      begin
        popupLinhas.Items.Clear;
        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Pré-live';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Green';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Red';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Anulada';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Meio Green';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);

        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := 'Meio Red';
        Item.OnClick := @AtualizaMetLin;
        popupLinhas.Items.Add(Item);
      end;
    end;

    P := Mouse.CursorPos;
    popupLinhas.PopUp(P.X, P.Y);
    Screen.Cursor := crDefault;
    Query.Free;
    qrMetodo.Edit;
  end;
end;

procedure TformEditMult.CarregaJogos;
var
  comp, Mand, Visit: string;
begin
  lsbJogos.Items.Clear;
  ListaJogo.Clear;
  InfoJogo.Free;
  writeln('Carregando jogos');
  with TSQLQuery.Create(nil) do
  begin
    try
      DataBase := formPrincipal.conectBancoDados;
      writeln('Abrindo lista de jogos');
      SQL.Text := 'SELECT J.Cod_Jogo, C.Competicao, J.Mandante, J.Visitante ' +
        'FROM Jogo J                                                        ' +
        'LEFT JOIN Competicoes C ON C.Cod_Comp = J.Cod_Comp                 ' +
        'LEFT JOIN Mercados M ON M.Cod_Jogo = J.Cod_Jogo                    ' +
        'WHERE M.Cod_Aposta = :CodAposta GROUP BY J.Cod_Jogo                ';
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      Open;
      First;
      while not EOF do
      begin
        comp  := FieldByName('Competicao').AsString;
        mand  := FieldByName('Mandante').AsString;
        visit := FieldByName('Visitante').AsString;

        InfoJogo      := TItemInfo.Create;
        InfoJogo.Text := (comp + ': ' + mand + ' X ' + visit);
        InfoJogo.CodJogo := FieldByName('Cod_Jogo').AsInteger;
        ListaJogo.Add(InfoJogo);
        lsbJogos.Items.Add(InfoJogo.Text);
        Next;
      end;
    except
      On E: Exception do
        writeln(E.Message);
    end;
    Free;
  end;
  lsbJogos.ItemIndex := 0;
  lsbJogosClick(nil);
end;

function TformEditMult.MultiplosJogos: Boolean;
begin
  Result := False;
  with TSQLQuery.Create(nil) do
  try
    DataBase := formPrincipal.conectBancoDados;
    SQL.Text := 'SELECT COUNT(*) FROM Jogo J LEFT JOIN Mercados M ON ' +
      'M.Cod_Jogo = J.Cod_Jogo WHERE M.Cod_Aposta = :cod';
    ParamByName('cod').AsInteger := GlobalCodAposta;
    Open;
    if not IsEmpty then
      Result := (FIelds[1].AsInteger > 1);
  finally
    Free;
  end;
end;

procedure TformEditMult.btnAlterarClick(Sender: TObject);
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'UPDATE Jogo                                  ' +
        'SET Cod_Comp = (SELECT Cod_Comp FROM Competicoes C     ' +
        'WHERE C.Competicao = :comp), Mandante = :mand,         ' +
        'Visitante = :visit                                     ' +
        'WHERE Cod_Jogo = :CodJogo                              ';
      ParamByName('CodJogo').AsInteger := GlobalCodJogo;
      ParamByName('comp').AsString := cbCompeticao.Text;
      ParamByName('mand').AsString := cbMandante.Text;
      ParamByName('visit').AsString := cbVisitante.Text;
      ExecSQL;
      qrJogo.Refresh;
      CarregaJogos;
    finally
      Free;
    end;
end;

procedure TformEditMult.btnNovoJogoClick(Sender: TObject);
var
  CodJogo: integer;
begin
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'INSERT INTO Jogo DEFAULT VALUES';
      ExecSQL;
      SQL.Text := 'SELECT MAX(Cod_Jogo) AS CodJogo FROM Jogo';
      Open;
      CodJogo := FieldByName('CodJogo').AsInteger;
      Close;
      SQL.Text := 'INSERT INTO Mercados DEFAULT VALUES';
      ExecSQL;
      SQL.Text := 'UPDATE Mercados SET Cod_Aposta = :CodAposta,     ' +
        'Cod_Jogo = :CodJogo                                        ' +
        'WHERE Cod_Mercado = (SELECT MAX(Cod_Mercado) FROM Mercados)';
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      ParamByName('CodJogo').AsInteger := CodJogo;
      ExecSQL;
      SQL.Text := 'UPDATE Jogo SET Cod_Comp = (SELECT C.Cod_Comp     ' +
        'FROM Competicoes C WHERE C.Competicao = :comp),   ' +
        'Mandante = :mand, Visitante = :visit              ' +
        'WHERE Cod_Jogo = :codjogo                         ';
      ParamByName('codjogo').AsInteger := CodJogo;
      ParamByName('comp').AsString := cbCompeticao.Text;
      ParamByName('mand').AsString := cbMandante.Text;
      ParamByName('visit').AsString := cbVisitante.Text;
      ExecSQL;
      qrJogo.Refresh;
      qrMetodo.Refresh;
    finally
      Free;
    end;
  CarregaJogos;
end;

procedure TformEditMult.btnOkClick(Sender: TObject);
begin
  Ok := True;
end;

procedure TformEditMult.btnRemoverJogoClick(Sender: TObject);
var
  CodJogo: integer;
begin
  CodJogo := qrJogo.FieldByName('Cod_Jogo').AsInteger;
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'DELETE FROM Mercados WHERE Cod_Jogo = :CodJogo';
      ParamByName('CodJogo').AsInteger := CodJogo;
      ExecSQL;
      SQL.Text := 'DELETE FROM Jogo WHERE Cod_Jogo = :CodJogo';
      ParamByName('CodJogo').AsInteger := CodJogo;
      ExecSQL;
    finally
      Free;
    end;
  qrJogo.Refresh;
  qrMetodo.Refresh;
  CarregaJogos;
end;

procedure TformEditMult.btnRemoverLinhaClick(Sender: TObject);
begin
  with qrMetodo do
  begin
    Delete;
    ApplyUpdates;
  end;
end;

procedure TformEditMult.FormClose(Sender: TObject; var CloseAction: TCloseAction);
label
  Abortar, Fim;
begin
  with formPrincipal do
    with transactionBancoDados do
    begin
      if not Ok then
        if MessageDlg('Confirmação',
          'Tem certeza que deseja cancelar a edição da aposta?',
          mtConfirmation, [mbYes, mbNo], 0) = mrNo then goto Abortar
        else begin
          RollbackRetaining;
          goto Fim;
        end;

      if not VerificaRegistros then
      goto Abortar;

      if not MultiplosJogos then
      begin
        MessageDlg('Erro', 'Não é possível fazer aposta múltipla com apenas ' +
        'um jogo!', mtError, [mbOk], 0);
        Abortar:
        begin
          CloseAction := caNone;
          Exit;
        end;
      end;
      CommitRetaining;

      Fim:
      begin
        ListaJogo.Free;
        InfoJogo.Free;
      end;
    end;
end;

procedure TformEditMult.btnNovaLinhaClick(Sender: TObject);
var
  CodJogo: integer;
begin
  CodJogo := qrJogo.FieldByName('Cod_Jogo').AsInteger;
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'INSERT INTO Mercados DEFAULT VALUES';
      ExecSQL;
      SQL.Text := 'UPDATE Mercados SET Cod_Aposta = :CodAposta,     ' +
        'Cod_Jogo = :CodJogo                                        ' +
        'WHERE Cod_Mercado = (SELECT MAX(Cod_Mercado) FROM Mercados)';
      ParamByName('CodAposta').AsInteger := GlobalCodAposta;
      ParamByName('CodJogo').AsInteger := CodJogo;
      ExecSQL;
      qrMetodo.Close;
      qrMetodo.Open;
    finally
      Free;
    end;
end;

procedure TformEditMult.btnCancelClick(Sender: TObject);
begin
  Ok := False;
end;

procedure TformEditMult.AtualizaMetLin(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    with formPrincipal.transactionBancoDados do
      with qrMetodo do
      begin
        Edit;
        FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
        writeln('Item selecionado: ', SelectedItem.Caption);
        Post;
        ApplyUpdates;
        CommitRetaining;
      end;
  end;
end;

procedure TformEditMult.grdJogosEditingDone(Sender: TObject);
begin
  with qrJogo do
  begin
    Edit;
    Post;
    ApplyUpdates;
  end;
end;

procedure TformEditMult.grdLinhasEditingDone(Sender: TObject);
begin
  with qrMetodo do
  begin
    Edit;
    Post;
    ApplyUpdates;
  end;
end;

function TformEditMult.VerificaRegistros: boolean;
var
  NomePais, ComparaMandante, ComparaVisitante, ComparaCampeonato: string;
  MandanteExiste, VisitanteExiste, PaisExiste, CampeonatoExiste, Multipla: boolean;
  i, Contagem: integer;
begin
  Result := True;
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        qrJogo.First;
        writeln('Verificando registros');
        while not qrJogo.EOF do
        begin
          SQL.Text := 'SELECT Competicao FROM Competicoes WHERE Competicao = :comp';
          ComparaCampeonato := qrJogo.FieldByName('Competicao').AsString;
          ParamByName('comp').AsString := ComparaCampeonato;
          Open;
          if not IsEmpty then
            CampeonatoExiste := True
          else
            CampeonatoExiste := False;
          Close;
          SQL.Text := 'SELECT Time FROM Times WHERE Time = :mandante';
          ComparaMandante := qrJogo.FieldByName('Mandante').AsString;
          ParamByName('mandante').AsString := ComparaMandante;
          Open;
          if not IsEmpty then
            MandanteExiste := True
          else
            MandanteExiste := False;
          Close;
          SQL.Text := 'SELECT Time FROM Times WHERE Time = :visitante';
          ComparaVisitante := qrJogo.FieldByName('Visitante').AsString;
          ParamByName('visitante').AsString := ComparaVisitante;
          Open;

          if not IsEmpty then
            VisitanteExiste := True
          else
            VisitanteExiste := False;

          if not CampeonatoExiste or not MandanteExiste or not VisitanteExiste then
            if MessageDlg(
              'Há time(s)/Competição inserido(s) que não está(ão) no banco de dados, ' +
              'ou houve um erro de digitação. Caso tenha digitado corretamente, deseja ' +
              'registrá-lo(s) no banco de dados agora?', mtConfirmation, [mbYes, mbNo], 0) =
              mrYes then
            begin
              if InputQuery('Inserir Dados',
                'Digite CORRETAMENTE o país do campeonato:', NomePais) then
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
              end;
              Result := True;
            end
            else
              Result := False;
          transactionBancoDados.CommitRetaining;
          qrJogo.Next;
        end;
      except
        on E: Exception do
        begin
          Cancel;
          writeln('Erro: ' + E.Message);
          transactionBancoDados.RollbackRetaining;
          Result := False;
        end;
      end;
      Free;
    end;
end;

end.
