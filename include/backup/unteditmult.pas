unit untEditMult;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Buttons, Math,
  SQLScript;

type

  { TformEditMult }

  TformEditMult = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnNovaLinha: TButton;
    btnNovoJogo: TButton;
    btnRemoverJogo: TButton;
    btnRemoverLinha: TButton;
    dsJogo: TDataSource;
    dsMetodo: TDataSource;
    grbLinhas: TGroupBox;
    grbJogos: TGroupBox;
    grdLinhas: TDBGrid;
    grdJogos: TDBGrid;
    qrJogo: TSQLQuery;
    qrJogoCod_Jogo: TLargeintField;
    qrJogoCompeticao: TStringField;
    qrJogoMandante: TStringField;
    qrJogoVisitante: TStringField;
    qrMetodo: TSQLQuery;
    qrMetodoCod_Mercado: TLargeintField;
    qrMetodoLinha: TStringField;
    qrMetodoMtodo: TStringField;
    qrMetodoOdd: TBCDField;
    qrMetodoStatus: TStringField;
    procedure btnCancelClick(Sender: TObject);
    procedure btnNovaLinhaClick(Sender: TObject);
    procedure btnNovoJogoClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnRemoverJogoClick(Sender: TObject);
    procedure btnRemoverLinhaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdJogosCellClick(Column: TColumn);
    procedure EditaGridMetiodosLinhas(Column: TColumn);
    procedure AtualizaMetLin(Sender: TObject);
    procedure grdJogosEditingDone(Sender: TObject);
    procedure grdLinhasEditingDone(Sender: TObject);
  private
    Ok, GlobalExcecao, Nao: boolean;
    procedure VerificaRegistros;
  public

  end;

var
  formEditMult: TformEditMult;

implementation

uses
  untMain, untApostas;

  {$R *.lfm}

  { TformEditMult }

procedure TformEditMult.FormShow(Sender: TObject);
begin
  Ok := False;
  with formPrincipal do
  begin
    with grdJogos do
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        SQL.Text := 'SELECT Competicao FROM Competicoes';
        Open;
        First;
        while not EOF do
        begin
          Columns[0].PickList.Add(FieldByName('Competicao').AsString);
          Next;
        end;
        Close;
        SQL.Text := 'SELECT Time FROM Times';
        Open;
        First;
        while not EOF do
        begin
          Columns[1].PickList.Add(FieldByName('Time').AsString);
          Columns[2].PickList.Add(FieldByName('Time').AsString);
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
      grdJogosCellClick(nil);
    end;
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
      qrJogo.Refresh;
      qrMetodo.Refresh;
    finally
      Free;
    end;
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
  Cancelar, AbortFech, SairSemSalvar;
begin
  with formPrincipal do
  begin
    GlobalExcecao := False;
    Nao := False;

    if not Ok then goto Cancelar;

    VerificaRegistros;
    if Nao then goto AbortFech;

    if GlobalExcecao then
    begin
      MessageDlg('Erro ao salvar alterações, tente novamente.', mtError, [mbOK], 0);
      goto SairSemSalvar;
    end;
    Exit;

    Cancelar:

      writeln('Cancelando');
    if MessageDlg('Confirmação',
      'Tem certeza que deseja cancelar a edição da aposta?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo then goto AbortFech
    else
    begin

      SairSemSalvar:

        writeln('Fechando sem salvar');
      transactionBancoDados.RollbackRetaining;
      Exit;
    end;

    AbortFech:

      writeln('Abortando fechamento');
    CloseAction := caNone;
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

procedure TformEditMult.grdJogosCellClick(Column: TColumn);
var
  CodJogo: integer;
begin
  CodJogo := qrJogo.FieldByName('Cod_Jogo').AsInteger;
  with qrMetodo do
  begin
    if Active then Close;
    ParamByName('CodJogo').AsInteger := CodJogo;
    Open;
  end;

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

procedure TformEditMult.VerificaRegistros;
var
  NomePais, ComparaMandante, ComparaVisitante, ComparaCampeonato: string;
  MandanteExiste, VisitanteExiste, PaisExiste, CampeonatoExiste, Multipla: boolean;
  i, Contagem: integer;
begin
  with formPrincipal do
  begin
    Nao := False;
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
              end;

            end
            else
              Nao := True;
            transactionBancoDados.CommitRetaining;
          end;
          qrJogo.Next;
        end;
      except
        on E: Exception do
        begin
          Cancel;
          writeln('Erro: ' + E.Message);
          transactionBancoDados.RollbackRetaining;
          GlobalExcecao := True;
        end;
      end;
      Free;
    end;
  end;
end;

procedure TformEditMult.EditaGridMetiodosLinhas(Column: TColumn);
var
  P: TPoint;
  Query: TSQLQuery;
  Item: TMenuItem;
begin
  with formPrincipal do
  begin
    Query := TSQLQuery.Create(nil);
    Query.DataBase := conectBancoDados;
    Screen.Cursor := crAppStart;
    popupLinhas.Items.Clear;

    ColunaAtual := Column;

    case Column.FieldName of
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
          'SELECT Nome FROM Linhas WHERE Cod_Metodo = (SELECT Cod_Metodo FROM Métodos WHERE Métodos.Nome = :SelecMetodo)';
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

end.
