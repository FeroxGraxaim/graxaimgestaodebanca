unit untSalvarDados;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, SQLDB, DB, Forms, Controls, Graphics,
  Dialogs, DBExtCtrls,
  ActnList, StdCtrls, DBCtrls, EditBtn, DBGrids, Menus, ComCtrls, Math;

type

  { TformSalvarDados }

  TformSalvarDados = class(TForm)
    btnOk: TButton;
    btnCancelar: TButton;
    chbBanca: TCheckBox;
    chbApostas: TCheckBox;
    chbMetodosLinhas: TCheckBox;
    chbPaises: TCheckBox;
    chbCompeticoes: TCheckBox;
    chbTimes: TCheckBox;
    chbDatas: TCheckBox;
    deFim: TDateEdit;
    deInicio: TDateEdit;
    Label1: TLabel;
    lbAte: TLabel;
    lbDe: TLabel;
    procedure FecharFormulario(Sender: TObject; var CloseAction: TCloseAction);
    procedure Cancelar(Sender: TObject);
    procedure ExportarDados(Sender: TObject);
    procedure DefinirDatas(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MudarExtensaoAoSalvar(Sender: TObject);
  private
  public

  end;

var
  formSalvarDados: TformSalvarDados;
  dataInicio: TDateTime;
  dataFim: TDateTime;
  Ok: boolean;

implementation

uses
  untMain;

  {$R *.lfm}

  { TformSalvarDados }

procedure TformSalvarDados.FecharFormulario(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if not Ok then
    if MessageDlg('Cancelar Exportação', 'Deseja realmente cancelar a ' +
      'exportação de dados?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      CloseAction := caNone;
end;

procedure TformSalvarDados.ExportarDados(Sender: TObject);
var
  Script: TStringList;
  i: integer;
  TextoSQL: string;
begin
  Script := TStringList.Create;
  with formPrincipal do
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      //Salvar Métodos e Linhas
      if chbMetodosLinhas.Checked then
      begin
        writeln('Salvando métodos e linhas');
        SQL.Text := 'SELECT * FROM Métodos';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Métodos (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            if Fields[i].DataType = ftInteger then
              TextoSQL := TextoSQL + Fields[i].AsString
            else
              TextoSQL := TextoSQL + '"' + Fields[i].AsString + '"';
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Métodos WHERE ' +
            Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;

        Close;
        SQL.Text := 'SELECT * FROM Linhas';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Linhas (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            if Fields[i].DataType = ftInteger then
              TextoSQL := TextoSQL + Fields[i].AsString
            else
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Linhas WHERE ' +
            Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Países
      if chbPaises.Checked then
      begin
        writeln('Salvando países');
        SQL.Text := 'SELECT * FROM Países';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Países (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            case Fields[i].DataType of
              ftDateTime:
                TextoSQL := TextoSQL + StringReplace(DateTimeToJulianDate(
                  Fields[i].AsDateTime).ToString, ',', '.',
                  [rfReplaceAll]);
              ftFloat:
                TextoSQL := TextoSQL + StringReplace(Fields[i].AsString,
                  ',', '.', [rfReplaceAll]);
              ftBoolean:
                TextoSQL := TextoSQL + Fields[i].AsString;
              else
                TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
            end;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Países WHERE ' +
            Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Competições
      if chbCompeticoes.Checked then
      begin
        writeln('Salvando competições');
        SQL.Text := 'SELECT * FROM Competicoes';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Competicoes (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL +
            ' WHERE NOT EXISTS (SELECT 1 FROM Competicoes WHERE ' +
            Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Times
      if chbTimes.Checked then
      begin
        writeln('Salvando times');
        SQL.Text := 'SELECT * FROM Times';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Times (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            case Fields[i].DataType of
              ftDateTime:
                TextoSQL := TextoSQL + StringReplace(DateTimeToJulianDate(
                  Fields[i].AsDateTime).ToString, ',', '.',
                  [rfReplaceAll]);
              ftFloat:
                TextoSQL := TextoSQL + StringReplace(Fields[i].AsString,
                  ',', '.', [rfReplaceAll]);
              ftBoolean:
                TextoSQL := TextoSQL + Fields[i].AsString;
              else
                TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
            end;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Times WHERE ' +
            Fields[1].FieldName + ' = ' + QuotedStr(Fields[1].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Banca
      if chbBanca.Checked then
      begin
        writeln('Salvando banca');
        if not chbDatas.Checked then
          SQL.Text := 'SELECT * FROM Banca'
        else
        begin
          SQL.Text :=
            'SELECT * FROM Banca WHERE Mês BETWEEN ' +
            'strftime(''%m'', :prim) AND strftime(''%m'', :fim) ' +
            'AND Ano BETWEEN strftime(''%Y'', :prim) ' + 'AND strftime(''%Y'', :fim)';
          ParamByName('prim').AsDateTime := deInicio.Date;
          ParamByName('fim').AsDateTime := deFim.Date;
        end;
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Banca (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL +
            ' WHERE NOT EXISTS (SELECT 1 FROM Banca WHERE mês = ' +
            QuotedStr(Fields[0].AsString) + ' AND ano = ' +
            QuotedStr(Fields[1].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Apostas
      if chbApostas.Checked then
      begin
        writeln('Salvando apostas');
        if chbDatas.Checked then
        begin
          SQL.Text := 'SELECT * FROM Apostas WHERE Data BETWEEN :prim AND :fim';
          ParamByName('prim').AsDateTime := deInicio.Date;
          ParamByName('fim').AsDateTime := deFim.Date;
        end
        else
          SQL.Text := 'SELECT * FROM Apostas';
        Open;
        FieldDefs.Update;
        writeln('Dados de aposta selecionados');
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Apostas (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName + '"';
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ') SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            if Fields[i].FieldName = 'Data' then
              TextoSQL := TextoSQL + StringReplace(DateTimeToJulianDate(
                Fields[i].AsDateTime).ToString, ',', '.', [rfReplaceAll])
            else
              TextoSQL := TextoSQL + QuotedStr(StringReplace(Fields[i].AsString,
              ',', '.', [rfReplaceAll]));
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Apostas ' +
            'WHERE Cod_Aposta = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        writeln('Salvando jogos das apostas');
        Close;
        if chbDatas.Checked then
        begin
          SQL.Text :=
            'SELECT * FROM Jogo WHERE (SELECT Data FROM Apostas JOIN Mercados ' +
            'ON Mercados.Cod_Jogo = Jogo.Cod_Jogo WHERE Mercados.Cod_Jogo = ' +
            'Jogo.Cod_Jogo AND Mercados.Cod_Aposta = Apostas.Cod_Aposta) ' +
            'BETWEEN :prim AND :fim';
          ParamByName('prim').AsDateTime := deInicio.Date;
          ParamByName('fim').AsDateTime := deFim.Date;
        end
        else
          SQL.Text := 'SELECT * FROM Jogo';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Jogo (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + QuotedStr(StringReplace(Fields[i].AsString),
              ',', '.', [rfReplaceAll]);
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Jogo ' +
            'WHERE Cod_Jogo = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
        writeln('Salvando mercados das apostas');
        if chbDatas.Checked then
        begin
          SQL.Text := 'SELECT * FROM Mercados WHERE (SELECT Data ' +
            'FROM Apostas JOIN Mercados ON Mercados.Cod_Aposta = ' +
            'Apostas.Cod_Aposta WHERE Mercados.Cod_Aposta = ' +
            'Apostas.Cod_Aposta) BETWEEN :prim AND :fim';
          ParamByName('prim').AsDateTime := deInicio.Date;
          ParamByName('fim').AsDateTime := deFim.Date;
        end
        else
          SQL.Text := 'SELECT * FROM Mercados';
        Open;
        FieldDefs.Update;
        First;
        while not EOF do
        begin
          TextoSQL := 'INSERT INTO Mercados (';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + '"' + Fields[i].FieldName;
            if i < FieldCount - 1 then
              TextoSQL := TextoSQL + '", ';
          end;
          TextoSQL := TextoSQL + '") SELECT ';
          for i := 0 to FieldCount - 1 do
          begin
            TextoSQL := TextoSQL + QuotedStr(StringReplace(Fields[i].AsString),
              ',', '.', [rfReplaceAll]);
            if i < FieldCount - 1 then
            TextoSQL := TextoSQL + ', ';
          end;
          TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Mercados ' +
            'WHERE Cod_Mercado = ' + QuotedStr(Fields[0].AsString) + ');';
          Script.Add(TextoSQL);
          Next;
        end;
        Close;
      end;

      //Salvar Arquivo
      with TSaveDialog.Create(nil) do
      try
        writeln('Abrindo janela de salvamento');
        Filter :=
          'Arquivo SQL (*.sql)|*.sql| Arquivo CSV (*.csv)|*.csv';
        DefaultExt := 'sql';
        FileName := 'Gestão de Banca ' + FormatDateTime('dd-mm-yyyy hh-nn', Now);
        OnTypeChange := @MudarExtensaoAoSalvar;
        while Execute do
        begin
          if FileExists(FileName) then
          begin
            if MessageDlg('O arquivo "' + FileName +
              '" já existe. Deseja substituí-lo?', mtConfirmation,
              [mbYes, mbNo], 0) = mrYes then
            begin
              Script.SaveToFile(FileName);
              Break;
            end
            else
              Continue;
          end
          else
          begin
            Script.SaveToFile(FileName);
            Break;
          end;
        end;
      finally
        Free;
      end;
      Free;
    except
      on E: Exception do
      begin
        Free;
        MessageDlg('Ocorreu um erro ao salvar dados, tente novamente. Se o ' +
          'problema persistir favor informar no GitHub com a seguinte mensagem:'
          +
          sLineBreak + sLineBreak + E.Message, mtError, [mbOK], 0);
      end;
    end;
  Script.Free;
  Ok := True;
  Close;
end;

procedure TformSalvarDados.DefinirDatas(Sender: TObject);
begin
  if chbDatas.Checked then
    with TSQLQuery.Create(nil) do
    begin
      deInicio.Enabled := True;
      deFim.Enabled := True;
      DataBase := formPrincipal.conectBancoDados;
      deInicio.Enabled := True;
      deFim.Enabled := True;
      SQL.Text := 'SELECT Data FROM Apostas';
      Open;
      First;
      dataInicio := FieldByName('Data').AsDateTime;
      Last;
      dataFim := FieldByName('Data').AsDateTime;
      Free;
    end
  else
  begin
    deInicio.Enabled := False;
    deFim.Enabled := False;
  end;
end;

procedure TformSalvarDados.FormShow(Sender: TObject);
begin
  Ok := False;
end;

procedure TformSalvarDados.MudarExtensaoAoSalvar(Sender: TObject);
begin
  with TSaveDialog(Sender) do
  begin
    if FIleName <> '' then
    begin
      case FilterIndex of
        1: if ExtractFileName(FileName) <> '.sql' then
            FileName := ChangeFileExt(FileName, '.sql');
        2: if ExtractFileName(FileName) <> '.csv' then
            FileName := ChangeFileExt(FileName, '.csv');
      end;
    end;
  end;
end;

procedure TformSalvarDados.Cancelar(Sender: TObject);
begin
  Ok := False;
  Close;
end;

end.
