unit untApostas;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
DB, Forms, Controls, Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls,
Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, Types,
TASeries, TACustomSource,
TADbSource, TACustomSeries, TAMultiSeries,
Iphttpbroker, DateUtils, Math, Grids, untMain;

type
{ TEventosApostas }

TEventosApostas = class(TformPrincipal)
public

  procedure tsApostasShow(Sender: TObject);
  procedure grdApostasColEnter(Sender: TObject);
  procedure grdApostasColExit(Sender: TObject);
  procedure grdApostasExit(Sender: TObject);
  procedure grdApostasCellClick(Column: TColumn);
  procedure btnRemoverApostaClick(Sender: TObject);
  procedure btnNovaApostaClick(Sender: TObject);
  procedure CorrigeBancaFinalApostas;
  procedure grdApostasDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: integer; Column: TColumn; State: TGridDrawState);
  procedure grdApostasEditingDone(Sender: TObject);
  procedure SalvarEdicaoGrid;
  procedure btnAtualizaApostasClick(Sender: TObject);
end;

implementation

uses untNA;

procedure TEventosApostas.tsApostasShow(Sender: TObject);
var
  Estrategias: TStringList;
  Situacao: TStringList;
  Competicao: TStringList;
  Time: TStringList;
  Unidade: TStringList;
  i: integer;
begin
  with formPrincipal do
    begin
    if not qrApostas.Active then qrApostas.Open;
    qrApostas.EnableControls;

    writeln('Exibida aba Apostas!');
    if not qrApostas.Active then
      begin
      writeln('Abrindo o query...');
      qrApostas.Open;
      end;
    if qrApostas.IsEmpty then
      begin
      writeln('Grid está vazio, desabilitando...');
      grdApostas.Enabled := False;
      end
    else
      begin
      writeln('Habilitando o grid...');
      grdApostas.Enabled := True;
      end;

    //Criando as StringLists
    Estrategias := TStringList.Create;
    Situacao := TStringList.Create;
    Competicao := TStringList.Create;
    Time    := TStringList.Create;
    Unidade := TStringList.Create;

    //Criando lista de estratégias da coluna "Estratégias"
    while not qrEstrategias.EOF do
      begin
      Estrategias.Add(qrEstrategias.FieldByName('Estratégia').AsString);
      qrEstrategias.Next;
      end;
    //Criando lista de times das colunas "Mandante" e "Visitante"
    while not qrTodosTimes.EOF do
      begin
      Time.Add(qrTodosTimes.FieldByName('Time').AsString);
      qrTodosTimes.Next;
      end;
    //Criando lista de situações da coluna "Situação"
    while not qrSituacao.EOF do
      begin
      Situacao.Add(qrSituacao.FieldByName('Status').AsString);
      qrSituacao.Next;
      end;
    //Criando lista de competições da coluna "Competição"
    while not qrCompeticoes.EOF do
      begin
      Competicao.Add(qrCompeticoes.FieldByName('Competição').AsString);
      qrCompeticoes.Next;
      end;
    //Criando lista de unidades da coluna "unidade"
    while not qrUnidades.EOF do
      begin
      Unidade.Add(qrUnidades.FieldByName('Unidade').AsString);
      qrUnidades.Next;
      end;

    //Listando opções nas colunas
    for i := 0 to grdApostas.Columns.Count - 1 do
      begin
      case grdApostas.Columns[i].FieldName of
        'Estratégia_Escolhida':
          grdApostas.Columns[i].PickList.Assign(Estrategias);
        'Status':
          grdApostas.Columns[i].PickList.Assign(Situacao);
        'Mandante', 'Visitante':
          grdApostas.Columns[i].PickList.Assign(Time);
        'Competição_AP':
          grdApostas.Columns[i].PickList.Assign(Competicao);
        'Unidade':
          grdApostas.Columns[i].PickList.Assign(Unidade);
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasCellClick(Column: TColumn);
begin
  with formPrincipal do
    begin
    writeln('Detectado lique em célula do grdApostas!');
    if not (qrApostas.State in [dsEdit, dsInsert]) then
      begin
      writeln('Colocando query em estado de edição...');
      qrApostas.Edit;
      end;

    if Column.Field is TBooleanField then
      begin
      writeln('Detectada coluna booleana!');
      SalvarEdicaoGrid;
      end;
    end;
end;

procedure TEventosApostas.grdApostasColEnter(Sender: TObject);
begin
  with formPrincipal do
    begin
    writeln('Entrado na coluna!');
    qrApostas.Edit;
    end;
end;

procedure TEventosApostas.grdApostasColExit(Sender: TObject);
begin
  writeln('Saindo da coluna');
end;

procedure TEventosApostas.grdApostasExit(Sender: TObject);
begin
  writeln('Saindo do grid');
end;

procedure TEventosApostas.btnRemoverApostaClick(Sender: TObject);
begin
  with formPrincipal do
    begin
    if not dsApostas.DataSet.Active then
      begin
      writeln('Abrindo o query...');
      dsApostas.DataSet.Open;
      end;

    if dsApostas.DataSet.IsEmpty then
      begin
      ShowMessage('Não há apostas para remover.');
      Exit;
      end;

      try
      writeln('Removendo aposta...');
      qrApostas.Delete;
      writeln('Aplicando alteações no query...');
      qrApostas.ApplyUpdates;
      writeln('Salvando alterações no banco de dados...');
      transactionBancoDados.Commit;
      writeln('Reabrindo o query...');
      qrApostas.Open;
      writeln('Atualizando o dataset...');
      qrApostas.Refresh;
      writeln('Atualizando o grid...');
      grdApostas.Invalidate;
      ShowMessage('Aposta(s) Removida(s)!');
      except
      on E: EDatabaseError do
        begin
        MessageDlg('Erro',
          'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      on E: Exception do
        begin
        MessageDlg('Erro',
          'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: '
          + E.Message, mtError, [mbOK], 0);
        writeln('Ocorreu um erro: ' + E.Message + ' Desfazendo alterações...');
        transactionBancoDados.RollbackRetaining;
        end;
      end;
    if qrApostas.IsEmpty then
      begin
      writeln('Desabilitando o grid...');
      grdApostas.Enabled := False;
      end
    else
      begin
      writeln('Habilitando o grid...');
      grdApostas.Enabled := True;
      end;
    MudarCorLucro;
    end;
end;

procedure TEventosApostas.btnNovaApostaClick(Sender: TObject);
var
  novaApostaForm: TformNovaAposta;
begin
  with formPrincipal do
    begin
    writeln('Criando formulário...');
    novaApostaForm := TformNovaAposta.Create(nil);
      try
      writeln('Exibindo o formulário...');
      novaApostaForm.ShowModal;
      finally
      writeln('Destruindo o formulário...');
      novaApostaForm.Free;
      ReiniciarTodosOsQueries;
      if qrApostas.IsEmpty then
        begin
        writeln('Desabilitando o TDBGrid...');
        grdApostas.Enabled := False;
        end
      else
        begin
        writeln('Habilitando o TDBGrid...');
        grdApostas.Enabled := True;
        end;
      end;
    end;
end;

procedure TEventosApostas.grdApostasDrawColumnCell(Sender: TObject;
const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
var
  Status: string;
begin
  with formPrincipal do
    begin
    //Mudar cores das células
    Status := qrApostas.FieldByName('Status').AsString;
    case Column.FieldName of
      'Status': case Status of
          'Red': grdApostas.Canvas.Font.Color      := clRed;
          'Green': grdApostas.Canvas.Font.Color    := clGreen;
          'Anulada': grdApostas.Canvas.Font.Color  := clYellow;
          'Cashout': grdApostas.Canvas.Font.Color  := clSkyBlue;
          'Pré-live': grdApostas.Canvas.Font.Color := clDefault;
          'Meio Green': grdApostas.Canvas.Font.Color := $0000FFB4;
          'Meio Red': grdApostas.Canvas.Font.Color := $000084FF;
          end;
      'Retorno', 'Profit_L': case Status of
          'Red': grdApostas.Canvas.Font.Color      := clRed;
          'Green': grdApostas.Canvas.Font.Color    := clGreen;
          'Anulada': grdApostas.Canvas.Font.Color  := clYellow;
          'Cashout': grdApostas.Canvas.Font.Color  := clSkyBlue;
          'Pré-live': grdApostas.Canvas.Font.Color := clDefault;
          'Meio Green': grdApostas.Canvas.Font.Color := $0000FFB4;
          'Meio Red': grdApostas.Canvas.Font.Color := $000084FF;
          end;
      end;
    grdApostas.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
end;


procedure TEventosApostas.grdApostasEditingDone(Sender: TObject);
begin
  SalvarEdicaoGrid;
end;

procedure TEventosApostas.SalvarEdicaoGrid;
begin
  with formPrincipal do
    begin

    //Salvar alterações
    if (qrApostas.State in [dsEdit, dsInsert]) then
      begin
        try
        writeln('Postando alterações...');
        qrApostas.Post;
        qrApostas.ApplyUpdates;
        transactionBancoDados.CommitRetaining;
        qrApostas.Close;
        qrApostas.Open;
        grdApostas.Invalidate;
        except
        on E: EDatabaseError do
          begin
          MessageDlg('Erro',
            'Erro de banco de dados. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          qrApostas.Cancel;
          writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
          transactionBancoDados.RollbackRetaining;
          end;
        on E: Exception do
          begin
          MessageDlg('Erro',
            'Erro ao salvar dados, tente novamente. Se o problema persistir, favor informar no Github com a seguinte mensagem: '
            + E.Message, mtError, [mbOK], 0);
          writeln('Ocorreu um erro: ' + E.Message + '. Revertendo alterações...');
          transactionBancoDados.RollbackRetaining;
          end;
        end;
      end;
    end;
end;

procedure TEventosApostas.CorrigeBancaFinalApostas;
var
  Query: TSQLQuery;
begin
  with formPrincipal do
    begin
      try
      Query := TSQLQuery.Create(nil);
      Query.Database := conectBancoDados;
      Query.SQL.Text := 'UPDATE Apostas SET Retorno = :Retorno';
      Query.ExecSQL;
      transactionBancoDados.CommitRetaining;
      writeln('Corrigido valores');
      if not qrApostas.Active then qrApostas.Open
      else
        begin
        qrApostas.Close;
        qrApostas.Open;
        end;
      except
      On E: Exception do
        begin
        writeln('Erro ao corrigir banca final: ' + E.Message);
        transactionBancoDados.Rollback;
        if not qrApostas.Active then qrApostas.Open
        else
          begin
          qrApostas.Close;
          qrApostas.Open;
          end;
        end;
      end;
    Query.Free;
    end;
end;

procedure TEventosApostas.btnAtualizaApostasClick(Sender: TObject);
begin
  CorrigeBancaFinalApostas;
  formPrincipal.ReiniciarTodosOsQueries;
end;

end.
