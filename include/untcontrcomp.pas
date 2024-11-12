unit untContrComp;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  DateUtils, Math, Grids, ValEdit, TAChartAxisUtils, FileUtil, HTTPDefs, untMain;

type

  { TEventosComp }

  TEventosComp = class(TformPrincipal)
  public
    procedure AoExibir(Sender: TObject);
    procedure PesquisarCompeticao(Sender: TObject);
    procedure AoClicarComp(Column: TColumn);
    procedure AtualizarGraficosComp;
    procedure DetectarEnterPesquisa(Sender: TObject; var Key: char);
    procedure NovaComp(Sender: TObject);
    procedure RemoverComp(Sender: TObject);
  end;

implementation

{ TEventosComp }

procedure TEventosComp.AoExibir(Sender: TObject);
begin
  with formPrincipal do
  begin
    with qrComp do
    if not Active then Open;
    with qrCompmaisAcert do
    if not Active then Open;
    with qrCompMenosAcert do
    if not Active then Open;
    AtualizarGraficosComp;
  end;
end;

procedure TEventosComp.PesquisarCompeticao(Sender: TObject);
var pesquisa: string;
begin
  with formPrincipal do
  with TSQLQuery.Create(nil) do
  try
  DataBase := conectBancoDados;
  SQL.Text := 'SELECT Competicao FROM Competicoes WHERE Competicao LIKE :comp';
  ParamByName('comp').AsString := edtPesquisarComp.Text + '%';
  Open;
  pesquisa := FieldByName('Competicao').AsString;
  qrComp.Locate('Competicao', pesquisa, []);
  finally
    Free;
  end;
end;

procedure TEventosComp.AoClicarComp(Column: TColumn);
begin
  AtualizarGraficosComp;
end;

procedure TEventosComp.AtualizarGraficosComp;
begin
  with formPrincipal do
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text :=
             'SELECT                                                               ' +
             'c.Competicao, p.País,                                                ' +
             'SUM(CASE WHEN m.Status = ''Green'' OR m.Status = ''Meio Green''      ' +
             'THEN 1 ELSE 0 END) AS Acertos,                                       ' +
             'SUM(CASE WHEN m.Status = ''Red'' OR m.Status = ''Meio Red''          ' +
             'THEN 1 ELSE 0 END) AS Erros,                                         ' +
             'SUM(CASE WHEN m.Status = ''Anulada'' THEN 1 ELSE 0 END) AS Anuladas, ' +
             'SUM(CASE WHEN a.Status = ''Green'' THEN 1 ELSE 0 END) AS Lucros,     ' +
             'SUM(CASE WHEN a.Status = ''Red'' THEN 1 ELSE 0 END) AS Prejuízos     ' +
             'FROM                                                                 ' +
             'Competicoes c                                                        ' +
             'LEFT JOIN                                                            ' +
             'Países p ON c.País = p.País                                          ' +
             'LEFT JOIN                                                            ' +
             'Jogo j ON c.Cod_Comp = j.Cod_Comp                                    ' +
             'LEFT JOIN                                                            ' +
             'Mercados m ON j.Cod_Jogo = m.Cod_Jogo                                ' +
             'LEFT JOIN                                                            ' +
             'Apostas a ON m.Cod_Aposta = a.Cod_Aposta                             ' +
             'WHERE Competicao = :comp                                             ' +
             'GROUP BY                                                             ' +
             'c.Competicao                                                         ' ;
    ParamByName('comp').AsString :=
    qrComp.FieldByName('Competicao').AsString;
    Open;

    (chrtAcertComp.Series[0] as TPieSeries).Clear;
    (chrtLucratComp.Series[0] as TPieSeries).Clear;

    if FieldByName('Acertos').AsInteger <> 0 then
    (chrtAcertComp.Series[0] as TPieSeries).AddPie(
    FieldByName('Acertos').AsInteger,
        'Acertos ', clGreen);

    if FieldByName('Erros').AsInteger <> 0 then
    (chrtAcertComp.Series[0] as TPieSeries).AddPie(
    FieldByName('Erros').AsInteger,
        'Erros ', clRed);

    if FieldByName('Lucros').AsInteger <> 0 then
    (chrtLucratComp.Series[0] as TPieSeries).AddPie(
    FieldByName('Lucros').AsInteger,
        'Lucros', clGreen);

    if FieldByName('Prejuízos').AsInteger <> 0 then
    (chrtLucratComp.Series[0] as TPieSeries).AddPie(
    FieldByName('Prejuízos').AsInteger,
        'Prejuízos', clRed);
  finally
    Free;
  end;
end;

procedure TEventosComp.DetectarEnterPesquisa(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  PesquisarCompeticao(nil);
end;

procedure TEventosComp.NovaComp(Sender: TObject);
var Comp, Pais: String;
label NovoPais, DeterminarPais, Salvar;
begin
  with formPrincipal do
  if InputQuery('Nova Competição','Digite CORRETAMENTE o nome da competição:',Comp) then
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'INSERT INTO Competicoes (Competicao) VALUES (:comp)';
    ParamByName('comp').AsString := Comp;
    ExecSQL;
    if InputQuery('Determinar País','Digite CORRETAMENTE o nome do país no qual' +
    'a competição pertence:',Pais) then
    begin
      SQL.Text := 'SELECT País FROM Países WHERE País = :pais';
      ParamByName('pais').AsString := 'pais';
      Open;
      if IsEmpty then
      if MessageDlg('País Não Encontrado','Não foi possível encontrar o país ' +
      'inserido, caso tenha digitado o nome corretamente, deseja inserí-lo ' +
      'no banco de dados agora?',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      goto NovoPais;

      DeterminarPais:

      if Active then Close;
      SQL.Text := 'UPDATE Competicoes SET País = :pais WHERE ROWID = ' +
      '(SELECT MAX(ROWID) FROM Competicoes)';
      ParamByName('pais').AsString := Pais;
      ExecSQL;
      goto Salvar;

      NovoPais:

      Close;
      SQL.Text := 'INSERT INTO Países(País) VALUES (:pais)';
      ParamByName('pais').AsString := Pais;
      ExecSQL;
      goto DeterminarPais;

      Salvar:
      transactionBancoDados.CommitRetaining;
      qrComp.Refresh;
      qrComp.Locate('Competicao',Comp,[]);
    end;
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

procedure TEventosComp.RemoverComp(Sender: TObject);
begin
  with formPrincipal do
  if MessageDlg('Remover Competição','Tem certeza que deseja remover a ' +
  'competição selecionada?' ,mtConfirmation,[mbYes, mbNo],0) = mrYes then
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'SELECT Jogo.Cod_Comp, C.Competicao FROM Jogo ' +
    'LEFT JOIN Competicoes C ON C.Cod_Comp = Jogo.Cod_Comp ' +
    'WHERE C.Competicao = :comp';
    ParamByname('comp').AsString := qrComp.FieldByName('Competicao').AsString;
    Open;
    if not IsEmpty then
    raise Exception.Create('Competição selecionada já está sendo usada por uma ' +
    'ou mais apostas. Remova a(s) aposta(s) referente(s) e tente novamente.');

    Close;
    SQL.Text := 'DELETE FROM Competicoes WHERE Competicao = :comp';
    ParamByname('comp').AsString := qrComp.FieldByName('Competicao').AsString;
    ExecSQL;
    transactionBancoDados.CommitRetaining;
    qrComp.Refresh;
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

end.
