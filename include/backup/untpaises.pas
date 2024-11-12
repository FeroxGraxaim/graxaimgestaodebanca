unit untPaises;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  DateUtils, Math, Grids, ValEdit, TAChartAxisUtils, FileUtil, HTTPDefs, untMain;

procedure AtualizaGraficosPaises;

type

  { TEventosPaises }

  TEventosPaises = class(TformPrincipal)
  public
    procedure AoExibir(Sender: TObject);
    procedure AoClicarPais(Column: TColumn);
    procedure PesquisarPais(Sender: TObject);
    procedure DetectarEnterPesquisa(Sender: TObject; var Key: char);
    procedure NovoPais(Sender: TObject);
    procedure RemoverPais(Sender: TObject);
  end;

implementation

procedure AtualizaGraficosPaises;
begin
  with formPrincipal do
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text :=
    'SELECT                                                              ' +
    'p.País,                                                             ' +
    'SUM(CASE WHEN m.Status = ''Green'' OR m.Status = ''Meio Green''     ' +
    'THEN 1 ELSE 0 END) AS Acertos,                                      ' +
    'SUM(CASE WHEN m.Status = ''Red'' OR m.Status = ''Meio Red''         ' +
    'THEN 1 ELSE 0 END) AS Erros,                                        ' +
    'SUM(CASE WHEN m.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anuladas,' +
    'SUM(CASE WHEN a.Status = ''Green'' THEN 1 ELSE 0 END) AS Lucros,    ' +
    'SUM(CASE WHEN a.Status = ''Red'' THEN 1 ELSE 0 END) AS Prejuízos    ' +
    'FROM                                                                ' +
    'Países p                                                            ' +
    'LEFT JOIN                                                           ' +
    'Times t ON t.País = p.País                                          ' +
    'LEFT JOIN                                                           ' +
    'Jogo j ON t.Time = j.Mandante OR j.Visitante                        ' +
    'LEFT JOIN                                                           ' +
    'Mercados m ON j.Cod_Jogo = m.Cod_Jogo                               ' +
    'LEFT JOIN                                                           ' +
    'Apostas a ON m.Cod_Aposta = a.Cod_Aposta                            ' +
    'WHERE p.País = :Pais                                                ' +
    'GROUP BY                                                            ' +
    'p.País                                                              ' ;
    ParamByName('Pais').AsString :=
    qrPais.FieldByName('País').AsString;
    Open;

    (chrtAcertPais.Series[0] as TPieSeries).Clear;
    (chrtLucratPais.Series[0] as TPieSeries).Clear;

    if FieldByName('Acertos').AsInteger <> 0 then
    (chrtAcertPais.Series[0] as TPieSeries).AddPie(
    FieldByName('Acertos').AsInteger,
        'Acertos ', clGreen);

    if FieldByName('Erros').AsInteger <> 0 then
    (chrtAcertPais.Series[0] as TPieSeries).AddPie(
    FieldByName('Erros').AsInteger,
        'Erros ', clRed);

    if FieldByName('Lucros').AsInteger <> 0 then
    (chrtLucratPais.Series[0] as TPieSeries).AddPie(
    FieldByName('Lucros').AsInteger,
        'Lucros', clGreen);

    if FieldByName('Prejuízos').AsInteger <> 0 then
    (chrtLucratPais.Series[0] as TPieSeries).AddPie(
    FieldByName('Prejuízos').AsInteger,
        'Prejuízos', clRed);
  finally
    Free;
  end;
end;

{ TEventosPaises }

procedure TEventosPaises.AoExibir(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrPais do
      if not Active then Open;
    with qrPaisesMaisAcert do
      if not Active then Open;
    with qrPaisesMenosAcert do
      if not Active then Open;
    AtualizaGraficosPaises;
  end;
end;

procedure TEventosPaises.AoClicarPais(Column: TColumn);
begin
  AtualizaGraficosPaises;
end;

procedure TEventosPaises.PesquisarPais(Sender: TObject);
begin
  with formPrincipal do
  qrPais.Locate('País', edtPesquisarPais.Text, []);
end;

procedure TEventosPaises.DetectarEnterPesquisa(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  PesquisarPais(nil);
end;

procedure TEventosPaises.NovoPais(Sender: TObject);
var Pais: string;
begin
  with formPrincipal do
  begin
    if InputQuery('Novo País','Digite CORRETAMENTE o nome do país:',Pais) then
    with TSQLQuery.Create(nil) do
    try
      DataBase := conectBancoDados;
      SQL.Text := 'INSERT INTO Países (País) VALUES (:pais)';
      ParamByName('pais').AsString := Pais;
      ExecSQL;
      transactionBancoDados.CommitRetaining;
      qrPais.Refresh;
      qrPais.Locate('País', Pais, []);
      Free;
    except
      on E: Exception do
      begin
        Cancel;
        Free;
        MessageDlg('Erro','Ocorreu um erro, tente novamente. Se o problema persistir ' +
        'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak + sLineBreak
        + E.Message, mtError, [mbOk], 0);
      end;
    end;
  end;
end;

procedure TEventosPaises.RemoverPais(Sender: TObject);
begin
  with formPrincipal do
  if MessageDlg('Remover País','Tem certeza que deseja remover o país selecionado?'
  ,mtConfirmation,[mbYes, mbNo],0) = mrYes then
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'SELECT P.País, C.Competicao, T.Time FROM Países P ' +
    'LEFT JOIN Competicoes C ON C.País = P.País ' +
    'LEFT JOIN Times T ON T.País = P.País ' +
    'WHERE P.País = :pais';
    ParamByname('pais').AsString := qrPais.FieldByName('País').AsString;
    Open;
    if not IsEmpty then
    raise Exception.Create('País selecionado já está registrado em uma competição ' +
    'ou em um time. Favor remover time(s)/competição(ões) referente(s) e tente novamente');

    Close;
    SQL.Text := 'DELETE FROM Países WHERE País = :pais';
    ParamByname('pais').AsString := qrPais.FieldByName('País').AsString;
    ExecSQL;
    transactionBancoDados.CommitRetaining;
    qrPais.Refresh;
    Free;
  except
    on E: Exception do
      begin
        Cancel;
        transactionBancoDados.RollbackRetaining;
        writeln('Erro: ' + E.Message + ' SQL: ' + SQL.Text);
        Free;
        MessageDlg('Erro','Ocorreu um erro, tente novamente. Se o problema persistir ' +
        'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak + sLineBreak
        + E.Message, mtError, [mbOk], 0);
      end;
  end;
end;

end.
