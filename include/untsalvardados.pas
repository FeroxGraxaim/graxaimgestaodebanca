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
  TextoSQL, DataFormatada, S: string;
begin
  Script := TStringList.Create;
  try
    with formPrincipal do
    begin
      with TSQLQuery.Create(nil) do
      begin
        DataBase := conectBancoDados;

        //Salvar Banca
        if chbBanca.Checked then
        begin
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
        end;

        //Salvar Apostas
        if chbApostas.Checked then
        begin
          Close;

          if chbDatas.Checked then
          begin
            SQL.Text := 'SELECT * FROM Apostas WHERE Data BETWEEN :prim AND :fim';
            ParamByName('prim').AsDateTime := deInicio.Date;
            ParamByName('fim').AsDateTime := deFim.Date;
          end
          else
            SQL.Text := 'SELECT * FROM Apostas';
          Open;
          First;
          while not EOF do
          begin
            TextoSQL := 'INSERT INTO Apostas (';
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
                ftDate, ftDateTime:
                  begin
                  DataFormatada := FloatToStr(
                  DateTimeToJulianDate(Fields[i].AsDateTime));
                  DataFormatada := StringReplace(DataFormatada, ',', '.',
                  [rfReplaceAll]);
                  TextoSQL := TextoSQL + DataFormatada;
                  end;
                ftString, ftWideString:
                  TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
                else
                  TextoSQL := TextoSQL + Fields[i].AsString;
              end;
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Apostas ' +
              'WHERE Cod_Aposta = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;

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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Jogo ' +
              'WHERE Cod_Jogo = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;

          Close;
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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Mercados ' +
              'WHERE Cod_Mercado = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;
        end;

        //Salvar Métodos e Linhas
        if chbMetodosLinhas.Checked then
        begin
          Close;
          SQL.Text := 'SELECT * FROM Métodos';
          Open;
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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Linhas WHERE ' +
              Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;
        end;

        //Salvar Países
        if chbPaises.Checked then
        begin
          Close;
          SQL.Text := 'SELECT * FROM Países';
          Open;
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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Países WHERE ' +
              Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;
        end;

        //Salvar Competições
        if chbCompeticoes.Checked then
        begin
          Close;
          SQL.Text := 'SELECT * FROM Competicoes';
          Open;
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
        end;

        //Salvar Times
        if chbTimes.Checked then
        begin
          Close;
          SQL.Text := 'SELECT * FROM Times';
          Open;
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
              TextoSQL := TextoSQL + QuotedStr(Fields[i].AsString);
              if i < FieldCount - 1 then
                TextoSQL := TextoSQL + ', ';
            end;
            TextoSQL := TextoSQL + ' WHERE NOT EXISTS (SELECT 1 FROM Times WHERE ' +
              Fields[0].FieldName + ' = ' + QuotedStr(Fields[0].AsString) + ');';
            Script.Add(TextoSQL);
            Next;
          end;
        end;

        //Salvar Arquivo
        with TSaveDialog.Create(nil) do
        try
          Filter :=
            'Arquivo de Texto (*.txt)|*.txt|Arquivo CSV (*.csv)|*.csv|' +
            'Arquivo SQL (*.sql)|*.sql|Todos os Arquivos (*.*)|*.*';
          DefaultExt := 'txt';
          while Execute do
          begin
            if ExtractFileExt(FileName) = '' then
              FileName := FileName + '.txt';

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
      end;
    end;
  except
    on E: Exception do
      MessageDlg('Erro: ' + E.Message, mtError, [mbOK], 0);
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

procedure TformSalvarDados.Cancelar(Sender: TObject);
begin
  Ok := False;
  Close;
end;

end.
