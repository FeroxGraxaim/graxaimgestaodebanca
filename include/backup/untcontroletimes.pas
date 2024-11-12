unit untControleTimes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  DateUtils, Math, Grids, ValEdit, TAChartAxisUtils, FileUtil, HTTPDefs, untMain;

procedure AtualizaGraficosTimes;

type

  { TEventosTimes }

  TEventosTimes = class(TformPrincipal)
  public
    procedure PesquisarTime(Sender: TObject);
    procedure AoExibir(Sender: TObject);
    procedure AoClicarTime(Column: TColumn);
    procedure DetectarEnterPesquisa(Sender: TObject; var Key: char);
    procedure NovoTime(Sender: TObject);
    procedure RemoverTime(Sender: TObject);
  end;

implementation

procedure AtualizaGraficosTimes;
begin
  with formPrincipal do
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text :=
    'SELECT                                                                  ' +
    'Times.Time,                                                             ' +
    'COUNT(CASE WHEN Mercados.Status = ''Green''                             ' +
    'OR Mercados.Status = ''Meio Green'' THEN 1 END) AS Acertos,             ' +
    'COUNT(CASE WHEN Mercados.Status = ''Red''                               ' +
    'OR Mercados.Status = ''Meio Red'' THEN 1 END) AS Erros,                 ' +
    'COUNT(CASE WHEN Mercados.Status = ''Anulada'' THEN 1 END) AS Anuladas,  ' +
    'SUM(CASE WHEN Apostas.Status = ''Green'' THEN 1 ELSE 0 END) AS Lucros,  ' +
    'SUM(CASE WHEN Apostas.Status = ''Red'' THEN 1 ELSE 0 END) AS Prejuízos  ' +
    'FROM                                                                    ' +
    'Times                                                                   ' +
    'LEFT JOIN                                                               ' +
    'Jogo ON Times.Time = Jogo.Mandante OR Jogo.Visitante                    ' +
    'LEFT JOIN                                                               ' +
    'Mercados ON Jogo.Cod_Jogo = Mercados.Cod_Jogo                           ' +
    'LEFT JOIN                                                               ' +
    'Apostas ON Mercados.Cod_Aposta = Apostas.Cod_Aposta                     ' +
    'WHERE Times.Time = :Time                                                ' +
    'GROUP BY                                                                ' +
    'Times.Time                                                              ';
    ParamByName('Time').AsString :=
    qrTimes.FieldByName('Time').AsString;
    Open;

    (chrtAcertTime.Series[0] as TPieSeries).Clear;
    (chrtLucratTime.Series[0] as TPieSeries).Clear;

    if FieldByName('Acertos').AsInteger <> 0 then
    (chrtAcertTime.Series[0] as TPieSeries).AddPie(
    FieldByName('Acertos').AsInteger,
        'Acertos ', clGreen);

    if FieldByName('Erros').AsInteger <> 0 then
    (chrtAcertTime.Series[0] as TPieSeries).AddPie(
    FieldByName('Erros').AsInteger,
        'Erros ', clRed);

    if FieldByName('Lucros').AsInteger <> 0 then
    (chrtLucratTime.Series[0] as TPieSeries).AddPie(
    FieldByName('Lucros').AsInteger,
        'Lucros', clGreen);

    if FieldByName('Prejuízos').AsInteger <> 0 then
    (chrtLucratTime.Series[0] as TPieSeries).AddPie(
    FieldByName('Prejuízos').AsInteger,
        'Prejuízos', clRed);
  finally
    Free;
  end;
end;

procedure TEventosTimes.PesquisarTime(Sender: TObject);
var pesquisa: string;
begin
  with formPrincipal do
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'SELECT Time FROM Times WHERE Time LIKE :time';
    ParamByName('time').AsString := edtPesquisarTime.Text + '%';
    Open;
    pesquisa := FieldByName('Time').AsString;
    qrTimes.Locate('Time', pesquisa, []);
  finally
    Free;
  end;
end;

procedure TEventosTimes.AoExibir(Sender: TObject);
begin
  with formPrincipal do
  begin
  if not qrTimes.Active then qrTimes.Open;
  if not qrTimesMaisAcert.Active then qrTimesMaisAcert.Open;
  if not qrTimesMenosAcert.Active then qrTimesMenosAcert.Open;
  end;
  AtualizaGraficosTimes;
end;

procedure TEventosTimes.AoClicarTime(Column: TColumn);
begin
  AtualizaGraficosTimes;
end;

procedure TEventosTimes.DetectarEnterPesquisa(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  PesquisarTime(nil);
end;

procedure TEventosTimes.NovoTime(Sender: TObject);
var Time, Pais: String;
label NovoPais, DeterminarPais, Salvar;
begin
  with formPrincipal do
  if InputQuery('Novo Time','Digite CORRETAMENTE o nome do time:',Time) then
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'INSERT INTO Times (Time) VALUES (:time)';
    ParamByName('time').AsString := Time;
    ExecSQL;
    if InputQuery('Determinar País','Digite CORRETAMENTE o nome do país no qual' +
    'o time pertence:',Pais) then
    begin
      SQL.Text := 'SELECT FROM Países WHERE País = :pais';
      ParamByName('pais').AsString := 'pais';
      Open;
      if IsEmpty then
      if MessageDlg('País Não Encontrado','Não foi possível encontrar o país ' +
      'inserido, caso tenha digitado o nome corretamente, deseja inserí-lo ' +
      'no banco de dados agora?',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      goto NovoPais;

      DeterminarPais:

      if Active then Close;
      SQL.Text := 'UPDATE Times SET País = :pais WHERE ROWID = ' +
      '(SELECT MAX(ROWID) FROM Times)';
      ParamByName('pais').AsString := Pais;
      ExecSQL;
      goto Salvar;

      NovoPais:

      Close;
      SQL.Text := 'INSERT INTO Países(País) VALUES {:pais)';
      ParamByName('pais').AsString := Pais;
      ExecSQL;
      goto DeterminarPais;

      Salvar:
      transactionBancoDados.CommitRetaining;
      qrTimes.Refresh;
      qrTimes.Locate('Time',Time,[]);
    end;
    Free;
  except
    on E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        Free;
        MessageDlg('Erro','Ocorreu um erro, tente novamente. Se o problema persistir ' +
        'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak + sLineBreak
        + E.Message, mtError, [mbOk], 0);
      end;
  end;
end;

procedure TEventosTimes.RemoverTime(Sender: TObject);
begin
  with formPrincipal do
  if MessageDlg('Remover Time','Tem certeza que deseja remover o ' +
  'time selecionado?' ,mtConfirmation,[mbYes, mbNo],0) = mrYes then
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'SELECT * FROM Times WHERE Time = :time AND Time = (SELECT ' +
    'Mandante, Visitante FROM Jogo WHERE Mandante = :time OR Visitante = :time)';
    ParamByname('time').AsString := qrTimes.FieldByName('Time').AsString;
    Open;
    if not IsEmpty then
    raise Exception.Create('O time está sendo usado em uma ou mais apostas, ' +
    'remova a(s) aposta(s) referente(s) e tente novamente.');
    Close;
    SQL.Text := 'DELETE FROM Times WHERE Time = :time';
    ParamByname('time').AsString := qrTimes.FieldByName('Time').AsString;
    ExecSQL;
    transactionBancoDados.CommitRetaining;
    qrTimes.Refresh;
    Free;
  except
    on E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        writeln('Erro no SQL: ' + SQL.Text);
        Free;
        MessageDlg('Erro','Ocorreu um erro, tente novamente. Se o problema persistir ' +
        'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak +
        sLineBreak + E.Message, mtError, [mbOk], 0);
      end;
  end;
end;

end.
