unit untMain;

{$mode objfpc}{$H+}
{$linklib fcl}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  Iphttpbroker, DateUtils, Math;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    btnNovaAposta: TButton;
    btnSalvarBancaInicial: TButton;
    btnFiltrarAp: TButton;
    Button1: TButton;
    btnNovaEstrategia: TButton;
    btnRemoverEstrategia: TButton;
    btnNovoTime: TButton;
    btnRemoverTime: TButton;
    chrtLucroAno: TChart;
    chrtLucroAnoLineSeries1: TLineSeries;
    chrtLucroMes: TChart;
    chrtEstrategias: TChart;
    chrtLucroMesLineSeries1: TLineSeries;
    cbMandante: TDBCheckBox;
    cbVisitante: TDBCheckBox;
    cbAno: TComboBox;
    cbMes: TComboBox;
    cbPerfil: TComboBox;
    DBComboBox1: TDBComboBox;
    DBComboBox2: TDBComboBox;
    DBDateEdit1: TDBDateEdit;
    DBDateEdit2: TDBDateEdit;
    edtBancaInicial: TEdit;
    linkAtualizacoes: TIpHttpDataProvider;
    JSONPropStorage1: TJSONPropStorage;
    Label4: TLabel;
    Label5: TLabel;
    qrBancaInicialMoedaStake: TStringField;
    qrBancaInicialStake: TBCDField;
    qrPerfisPerfil: TStringField;
    qrSelecionarPerfilPerfilSelecionado: TStringField;
    dsSelecionarPerfil: TDataSource;
    dsPerfis: TDataSource;
    dbGraficoLucroAno: TDbChartSource;
    dbGraficoLucroMes: TDbChartSource;
    dsGraficoLucroAno: TDataSource;
    dsGraficoLucroMes: TDataSource;
    edtRemoverAposta: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbUnidade: TLabel;
    lbPerfil: TLabel;
    lbFiltroDataInicial: TLabel;
    lbFiltroDataFinal: TLabel;
    lbLucro: TLabel;
    pnFiltroAp: TPanel;
    qrBancaInicialValor_Inicial: TBCDField;
    qrGraficoLucroMes: TSQLQuery;
    qrGraficoLucroAno: TSQLQuery;
    qrPerfis: TSQLQuery;
    qrSelecionarPerfil: TSQLQuery;

    dsUnidades: TDataSource;
    dsSituacao: TDataSource;
    dsCompeticoes: TDataSource;
    DBGrid3: TDBGrid;
    dsBancaInicial: TDataSource;
    dsBancaAtual: TDataSource;
    dbOutros: TDbChartSource;
    dbBackFavorito: TDbChartSource;
    dbCantos: TDbChartSource;
    dbBilhetePersonalizado: TDbChartSource;
    dbApostaMultipla: TDbChartSource;
    dbHandicapAsiatico: TDbChartSource;
    dbHandicapEuropeu: TDbChartSource;
    dbCartoes: TDbChartSource;
    dbEmpateAnula: TDbChartSource;
    dbChanceDupla: TDbChartSource;
    grdApostas: TDBGrid;
    grdEstrategias: TDBGrid;
    grdTimesMaisLucrativos: TDBGrid;
    grdTimesMenosLucrativos: TDBGrid;
    grdTodosTimes: TDBGrid;
    lbAno: TLabel;
    lbBancaAtual: TLabel;
    lbBancaInicial: TLabel;
    lbListaTimes: TLabel;
    lbMes: TLabel;
    lbTimesMaisLucrativos: TLabel;
    lbTimesMenosLucrativos: TLabel;
    lnApostaMultipla: TLineSeries;
    lnBackFavorito: TLineSeries;
    lnBilhetePersonalizado: TLineSeries;
    lnCantos: TLineSeries;
    lnCartoes: TLineSeries;
    lnChanceDupla: TLineSeries;
    lnEmpateAnula: TLineSeries;
    lnHandicapAsiatico: TLineSeries;
    lnHandicapEuropeu: TLineSeries;
    lnOutros: TLineSeries;
    lnOver15: TLineSeries;
    lnOver25: TLineSeries;
    lnTotGolsEquipe: TLineSeries;
    lnUnder25: TLineSeries;
    lnUnder35: TLineSeries;
    lnZebraFavorito: TLineSeries;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    qrBancaAtualAno: TLongintField;
    qrBancaAtualLucro_: TBCDField;
    qrBancaAtualLucro_R: TBCDField;
    qrBancaAtualMoeadaBancaInicial: TStringField;
    qrBancaAtualMoedaBancaAtual: TStringField;
    qrBancaAtualMoedaLucro: TStringField;
    qrBancaAtualMs: TLongintField;
    qrBancaAtualPorCentoLucro: TStringField;
    qrBancaAtualValor_Final: TBCDField;
    qrBancaAtualValor_Inicial: TBCDField;
    qrBancaInicial: TSQLQuery;
    qrBancaInicialAno: TLongintField;
    qrBancaInicialMs: TLongintField;
    dbUnder25: TDbChartSource;
    dbOver25: TDbChartSource;
    dbTotGolsEquipe: TDbChartSource;
    dbUnder35: TDbChartSource;
    dbZebraFavorito: TDbChartSource;
    dsOutros: TDataSource;
    dsBilhetePersonalizado: TDataSource;
    dsApostaMultipla: TDataSource;
    dsHandicapEuropeu: TDataSource;
    dsCartoes: TDataSource;
    dsOver15: TDataSource;
    dbOver15: TDbChartSource;
    dsBackFavorito: TDataSource;
    dsCantos: TDataSource;
    dsHandicapAsiatico: TDataSource;
    dsEmpateAnula: TDataSource;
    dsChanceDupla: TDataSource;
    dsUnder25: TDataSource;
    dsOver25: TDataSource;
    dsTotGolsEquipe: TDataSource;
    dsUnder35: TDataSource;
    dsZebraFavorito: TDataSource;
    dbGraficoEstrategias: TDbChartSource;
    dsApostas: TDataSource;
    dsEstrategias: TDataSource;
    dsCampeonatos: TDataSource;
    dsTimesMaisLucrativos: TDataSource;
    dsTimesMenosLucrativos: TDataSource;
    dsTodosTimes: TDataSource;
    lbListaTimes1: TLabel;
    conectBancoDados: TSQLConnector;
    qrCompeticoes: TSQLQuery;
    qrOutros: TSQLQuery;
    qrCampeonatos: TSQLQuery;
    qrBilhetePersonalizado: TSQLQuery;
    qrApostaMultipla: TSQLQuery;
    qrEstrategias: TSQLQuery;
    qrEstrategiasEstratgia: TStringField;
    qrEstrategiasMercados_Estr: TLongintField;
    qrEstrategiasProfit_Estr: TFloatField;
    qrHandicapEuropeu: TSQLQuery;
    qrCartoes: TSQLQuery;
    qrOver15: TSQLQuery;
    qrBackFavorito: TSQLQuery;
    qrCantos: TSQLQuery;
    qrHandicapAsiatico: TSQLQuery;
    qrEmpateAnula: TSQLQuery;
    qrChanceDupla: TSQLQuery;
    qrUnder25: TSQLQuery;
    qrOver25: TSQLQuery;
    qrTotGolsEquipe: TSQLQuery;
    qrUnder35: TSQLQuery;
    qrUnidades: TSQLQuery;
    qrUnidadesUnidade: TStringField;
    qrZebraFavorito: TSQLQuery;
    qrTodosTimes: TSQLQuery;
    qrTimesMaisLucrativos: TSQLQuery;
    qrTimesMenosLucrativos: TSQLQuery;
    qrApostas: TSQLQuery;
    qrGrafLucroEstr: TSQLQuery;
    qrBancaAtual: TSQLQuery;
    qrSituacao: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    Graficos: TTabSheet;
    ResumodoMes: TTabSheet;
    ResumodoAno: TTabSheet;
    tsApostas: TTabSheet;
    tsCampeonatos: TTabSheet;
    tsEstrategias: TTabSheet;
    tsPainel: TTabSheet;
    tsTimes: TTabSheet;
    txtBancaAtual: TDBText;
    txtLucroMoeda: TDBText;
    txtUnidade: TDBText;
    txtLucroPorCento: TDBText;
    procedure btnFiltrarApClick(Sender: TObject);
    procedure btnNovaEstrategiaClick(Sender: TObject);
    procedure btnNovoTimeClick(Sender: TObject);
    procedure btnRemoverEstrategiaClick(Sender: TObject);
    procedure btnRemoverTimeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure grdApostasColExit(Sender: TObject);
    procedure grdApostasExit(Sender: TObject);
    procedure MudarCorLucro;
    procedure btnSalvarBancaInicialClick(Sender: TObject);
    procedure btnNovaApostaClick(Sender: TObject);
    procedure cbMesChange(Sender: TObject);
    procedure cbPerfilChange(Sender: TObject);
    procedure dsBancaInicialDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure grdApostasCellClick(Column: TColumn);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure qrApostasAfterInsert(DataSet: TDataSet);
    procedure qrApostasAfterOpen(DataSet: TDataSet);
    procedure qrApostasAfterRefresh(DataSet: TDataSet);
    procedure qrBancaAtualCalcFields(DataSet: TDataSet);
    procedure qrBancaInicialCalcFields(DataSet: TDataSet);
    procedure TabControl1Change(Sender: TObject);
    procedure ReiniciarTodosOsQueries;
   // procedure dsGraficoEstrategiaDataChange(Sender: TObject; Field: TField);
   // procedure FormCreate(Sender: TObject);
   //function VerificarAtualizacoes (currentVersion: string): string;
  private
      contadorCliques: Integer;
  public

  end;

var
  formPrincipal: TformPrincipal;
  perfilInvestidor: String;
  stakeAposta: Double;
  valorInicial: Double;
  mesSelecionado, anoSelecionado: Integer;
implementation
uses
  untNA; //fpjson, HTTPDefs, fphttpclient, httpsend, synautil, jsonparser;

{$R *.lfm}

{ TformPrincipal }
{function TformPrincipal.VerificarAtualizacoes(currentVersion: string): string;
var
  response: TStringList;
  apiUrl, latestVersion: String;
  json: TJSONObject;
begin
  Result := '';
  apiUrl := 'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
  response := TStringList.Create; // Create a TStringList to hold the response
  try
    if HttpGetText(apiUrl, response) then
    begin
      json := TJSONObject(GetJSON(response.Text)); // Convert TStringList to JSON
      try
        latestVersion := json.Get('tag_name', '');
        if latestVersion <> '' then
        begin
          if CompareStr(currentVersion, latestVersion) < 0 then
            Result := latestVersion;
        end;
      finally
        json.Free;
      end;
    end
    else
    begin
      ShowMessage('Falha ao coletar informações de atualização.');
    end;
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
  response.Free;
end;}


procedure TformPrincipal.btnNovaApostaClick(Sender: TObject);
  var
    formNovaAposta: TformNovaAposta; // Declare uma variável para o novo formulário
  begin
    formNovaAposta := TformNovaAposta.Create(Self); // Crie uma instância do novo formulário
    try
      qrApostas.Close;
      formNovaAposta.ShowModal; // Exiba o formulário como modal (bloqueando o formulário principal)
    finally
      formNovaAposta.Free; // Libere a memória ocupada pelo formulário após fechar
    end;
end;

procedure TformPrincipal.cbMesChange(Sender: TObject);
begin

end;

procedure TformPrincipal.cbPerfilChange(Sender: TObject);
begin
  qrSelecionarPerfil.Close;
  qrSelecionarPerfil.SQL.Text := 'UPDATE "Selecionar Perfil" SET "Perfil Selecionado" = :perfilInvestidor WHERE "Perfil Selecionado" = :perfilSelecionado';
  perfilInvestidor := cbPerfil.Text;
  qrSelecionarPerfil.ExecSQL;
  SQLTransaction1.Commit;

  if perfilInvestidor = 'Conservador' then
     stakeAposta := RoundTo(valorInicial / 100, -2)
  else
      if perfilInvestidor = 'Moderado' then
      stakeAposta := RoundTo(valorInicial / 70, -2)
  else
      if perfilInvestidor = 'Agressivo' then
      stakeAposta := RoundTo(valorInicial / 40, -2);

end;

procedure TformPrincipal.dsBancaInicialDataChange(Sender: TObject; Field: TField
  );
begin

end;

procedure TformPrincipal.btnSalvarBancaInicialClick(Sender: TObject);
  var
    mes, ano: Integer;
    novoValor: Double;
    query: TSQLQuery;
 begin
  novoValor := StrToFloat(edtBancaInicial.Text);
  //cbPerfil.Items.Add(qrPerfis.FieldByName('Perfil').AsString);
  //qrPerfis.Next;
  //cbPerfil.Text := (qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString);

  // Verifica se o mês e o ano são válidos
  if TryStrToInt(cbMes.Text, mes) and TryStrToInt(cbAno.Text, ano) then
  begin
    try
       // Abre a conexão com o banco de dados, se ainda não estiver aberta
       if not conectBancoDados.Connected then
         conectBancoDados.Connected := True;

       // Verifica se já existe um registro com o mês e ano fornecidos
       qrBancaInicial.Close;
       qrBancaInicial.SQL.Text := 'SELECT "Mês", "Ano", "Valor_Inicial", "Stake" FROM "Banca" WHERE "Mês" = :mesSelecionado AND "Ano" = :anoSelecionado';
       qrBancaInicial.ParamByName('mesSelecionado').AsInteger := mes;
       qrBancaInicial.ParamByName('anoSelecionado').AsInteger := ano;
       qrBancaInicial.Open;

       if qrBancaInicial.RecordCount = 0 then
       begin
         // Insere um novo registro se não existir
         qrBancaInicial.Close;
         qrBancaInicial.SQL.Text := 'INSERT INTO "Banca" ("Mês", "Ano", "Valor_Inicial", "Stake") VALUES (:mes, :ano, :valorInicial, :stake)';
         qrBancaInicial.ParamByName('mes').AsInteger := mes;
         qrBancaInicial.ParamByName('ano').AsInteger := ano;
         qrBancaInicial.ParamByName('valorInicial').AsFloat := novoValor; // ou qualquer valor inicial apropriado
         qrBancaInicial.ParamByName('stake').AsFloat := stakeAposta;
         qrBancaInicial.ExecSQL;
       end
       else
       begin
         // Atualiza o valor correspondente ao mês e ano selecionados
         if TryStrToFloat(edtBancaInicial.Text, novoValor) then
         begin
           qrBancaInicial.Close;
           qrBancaInicial.SQL.Text := 'UPDATE "Banca" SET "Valor_Inicial" = :novoValor, "Stake" = :stake WHERE "Mês" = :mesSelecionado AND "Ano" = :anoSelecionado';
           qrBancaInicial.ParamByName('novoValor').AsFloat := novoValor;
           qrBancaInicial.ParamByName('stake').AsFloat := stakeAposta;
           qrBancaInicial.ParamByName('mesSelecionado').AsInteger := mes;
           qrBancaInicial.ParamByName('anoSelecionado').AsInteger := ano;
           qrBancaInicial.ExecSQL;
         end;
       end;

       valorInicial := novoValor;
       SQLTransaction1.Commit;
       // Define o valor de stakeAposta com base no perfil selecionado
       if perfilInvestidor = 'Conservador' then
          stakeAposta := RoundTo(valorInicial / 100, -2)
          else
          if perfilInvestidor = 'Moderado' then
             stakeAposta := RoundTo(valorInicial / 70, -2)
             else
             if perfilInvestidor = 'Agressivo' then
                stakeAposta := RoundTo(valorInicial / 40, -2);

       ShowMessage('Valor de banca salvo com sucesso!');
     except
       on E: Exception do
       begin
         // Em caso de erro, mostra uma mensagem de erro
         ShowMessage('Erro ao salvar: ' + E.Message);
         SQLTransaction1.Rollback; // Desfaz as alterações no banco de dados
       end;
     end;
   end
   else
   begin
     ShowMessage('Informe um mês e um ano válidos!');
   end;
  query := TSQLQuery.Create(nil);
  try
    query.DataBase := conectBancoDados;
    query.Close;
    query.SQL.Text := 'select Valor_Inicial from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
    query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
    query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
    query.Open;
    finally
    query.Free;
    end;
    txtUnidade.DataField := qrBancaInicial.FieldByName('R$Stake').AsString;
  MudarCorLucro;
end;

procedure TformPrincipal.FormCreate(Sender: TObject);
var
  i: Integer;
  Estrategias: TStringList;
  Situacao: TStringList;
  Competicao: TStringList;
  Time: TStringList;
  Unidade: TStringList;
  query: TSQLQuery;
begin
 MudarCorLucro;
 // Carrega os perfis disponíveis no ComboBox
  qrPerfis.Open;
  try
    while not qrPerfis.EOF do
    begin
      cbPerfil.Items.Add(qrPerfis.FieldByName('Perfil').AsString);
      qrPerfis.Next;
    end;
  finally
    qrPerfis.Close;
  end;

  // Define o perfil selecionado no ComboBox
  qrSelecionarPerfil.Open;
  try
    perfilInvestidor := qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString;
  finally
    qrSelecionarPerfil.Close;
  end;
  cbPerfil.Text := perfilInvestidor;
  // Configura o combobox do mês com os meses de 1 a 12
  cbMes.Clear;
  cbAno.Items.Add(IntToStr(qrBancaInicial.FieldByName('Ano').AsInteger));
  for i := 1 to 12 do
  cbMes.Items.Add(IntToStr(i));
  cbMes.ItemIndex := MonthOf(Now) - 1;
  cbAno.Text := IntToStr(YearOf(Now));

  Estrategias := TStringList.Create;
  Situacao := TStringList.Create;
  Competicao := TStringList.Create;
  Time := TStringList.Create;
  Unidade := TStringList.Create;

  // Mostra o valor da Banca Inicial da data selecionada
  mesSelecionado := StrToInt(cbMes.Text);
  anoSelecionado := StrToInt(cbAno.Text);

  query := TSQLQuery.Create(nil);
  try
    query.DataBase := conectBancoDados;
    query.SQL.Text := 'select Valor_Inicial from Banca where Mês = :MesSelecionado and Ano = :AnoSelecionado';
    query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
    query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
    query.Open;

    if not query.IsEmpty then
      valorInicial := query.FieldByName('Valor_Inicial').AsFloat
    else
      valorInicial := 0;
    edtBancaInicial.Text := FloatToStr(valorInicial);
  finally
    query.Free;
  end;

  // Define a stake
  if perfilInvestidor = 'Conservador' then
     stakeAposta := RoundTo(valorInicial / 100, -2)
  else
      if perfilInvestidor = 'Moderado' then
      stakeAposta := RoundTo(valorInicial / 70, -2)
  else
      if perfilInvestidor = 'Agressivo' then
      stakeAposta := RoundTo(valorInicial / 40, -2);

  try
    qrEstrategias.Open;
    qrTodosTimes.Open;
    qrSituacao.Open;
    qrCompeticoes.Open;
    qrUnidades.Open;
    qrEstrategias.First;

    while not qrEstrategias.EOF do
    begin
      Estrategias.Add(qrEstrategias.FieldByName('Estratégia').AsString);
      qrEstrategias.Next;
    end;

    while not qrTodosTimes.EOF do
    begin
      Time.Add(qrTodosTimes.FieldByName('Time').AsString);
      qrTodosTimes.Next;
    end;

    while not qrSituacao.EOF do
    begin
      Situacao.Add(qrSituacao.FieldByName('Status').AsString);
      qrSituacao.Next;
    end;

    while not qrCompeticoes.EOF do
    begin
      Competicao.Add(qrCompeticoes.FieldByName('Competição').AsString);
      qrCompeticoes.Next;
    end;

    while not qrUnidades.EOF do
    begin
      Unidade.Add(qrUnidades.FieldByName('Unidade').AsString);
      qrUnidades.Next;
    end;
  finally
    qrEstrategias.Close;
    qrTodosTimes.Close;
    qrSituacao.Close;
    qrCompeticoes.Close;
    qrUnidades.Close;
  end;

    //Listar opções nos PickLists das colunas
    try
    for i := 0 to grdApostas.Columns.Count - 1 do
    begin
      if grdApostas.Columns[i].FieldName = 'Estratégia_Escolhida' then
      begin
        grdApostas.Columns[i].PickList.Assign(Estrategias);
        Break;
      end
      else if grdApostas.Columns[i].FieldName = 'Status' then
      begin
        grdApostas.Columns[i].PickList.Assign(Situacao);
        Break;
      end
      else if grdApostas.Columns[i].FieldName = 'Mandante' then
      begin
        grdApostas.Columns[i].PickList.Assign(Time);
      end
      else if grdApostas.Columns[i].FieldName = 'Visitante' then
      begin
        grdApostas.Columns[i].PickList.Assign(Time);
      end
      else if grdApostas.Columns[i].FieldName = 'Unidade' then
      begin
        grdApostas.Columns[i].PickList.Assign(Unidade);
      end
      else if grdApostas.Columns[i].FieldName = 'Competição_AP' then
      begin
        grdApostas.Columns[i].PickList.Assign(Competicao);
      end
      else if grdApostas.Columns[i].FieldName = 'Unidade' then
      begin
        grdApostas.Columns[i].PickList.Assign(Unidade);
      end;
    end;
  finally
    Estrategias.Free;
  end;
 end;

procedure TformPrincipal.grdApostasCellClick(Column: TColumn);
{var
ARect: TRect;
cbStatusLeft, cbStatusTop: Integer;}
begin
  {if (grdApostas.SelectedIndex = 8) then
  begin
    cbStatusLeft := grdApostas.Left + grdApostas.Columns[grdApostas.SelectedIndex].Width;
    cbStatusTop := grdApostas.Top + grdApostas.HowHeights * grdApostas.DefaultRowHeight;

    ARect := grdApostas.CellRect(Column.Index, grdApostas.Row);
    ARect.Left := cbStatusLeft;
    ARect.Right := cbStatusLeft + 80;

    cbCelulaStatus.Left := cbStatusLeft;
    cbCelulaStatus.Top := cbStatusTop;
    cbCelulaStatus.Width := 80;
    cbCelulaStatus.Visible := True;
  end
  else
  begin
    cbCelulaStatus.Visible := False;
  end;}
end;

procedure TformPrincipal.MenuItem1Click(Sender: TObject);
begin

end;

procedure TformPrincipal.MenuItem6Click(Sender: TObject);
begin

end;

procedure TformPrincipal.qrApostasAfterInsert(DataSet: TDataSet);
begin
  MudarCorLucro;
end;

procedure TformPrincipal.qrApostasAfterOpen(DataSet: TDataSet);
begin
  MudarCorLucro;
end;

procedure TformPrincipal.qrApostasAfterRefresh(DataSet: TDataSet);
begin
  MudarCorLucro;
end;

procedure TformPrincipal.qrBancaAtualCalcFields(DataSet: TDataSet);
begin
  DataSet.FieldByName('R$BancaInicial').AsString :=
  'R$ ' + FormatFLoat ('0.00', DataSet.FieldByName('Valor_inicial').AsFloat);
  DataSet.FieldByName('R$Lucro').AsString :=
  'R$ ' + FormatFLoat ('0.00', DataSet.FieldByName('Lucro_R$').AsFloat);
  DataSet.FieldByName('%Lucro').AsString :=
  FormatFloat('0.00%', DataSet.FieldByName('Lucro_%').AsFloat);
  DataSet.FieldByName('R$BancaAtual').AsString :=
  'R$ ' + FormatFLoat ('0.00', DataSet.FieldByName('Valor_Final').AsFloat);
end;

procedure TformPrincipal.qrBancaInicialCalcFields(DataSet: TDataSet);
begin
    DataSet.FieldByName('R$Stake').AsString :=
    'R$ ' + FormatFloat ('0.00', DataSet.FieldByName('Stake').AsFloat);
end;

procedure TformPrincipal.TabControl1Change(Sender: TObject);
begin

end;

procedure TFormPrincipal.MudarCorLucro;
var
  query: TSQLQuery;
  Lucro: Double;
begin
  query := TSQLQuery.Create(nil);
  try
    query.DataBase := conectBancoDados;
    query.SQL.Text := 'SELECT "Lucro_R$" FROM Banca WHERE "Mês" = :MesSelecionado AND "Ano" = :AnoSelecionado';
    query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
    query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
    query.Open;

    if not query.FieldByName('Lucro_R$').IsNull then
      Lucro := query.FieldByName('Lucro_R$').AsFloat
    else
      Lucro := 0; // Handle case when no lucro value is found
  finally
    query.Free;
  end;

  if Lucro < 0 then
  begin
    txtBancaAtual.Font.Color := clRed;
    txtLucroMoeda.Font.Color := clRed;
    txtLucroPorCento.Font.Color := clRed;
  end
  else if Lucro > 0 then
  begin
    txtBancaAtual.Font.Color := clGreen;
    txtLucroMoeda.Font.Color := clGreen;
    txtLucroPorCento.Font.Color := clGreen;
  end
  else
  begin
    txtBancaAtual.Font.Color := clDefault;
    txtLucroMoeda.Font.Color := clDefault;
    txtLucroPorCento.Font.Color := clDefault;
  end;
end;

procedure TformPrincipal.btnFiltrarApClick(Sender: TObject);
begin
  Inc(contadorCliques);
  case contadorCliques mod 2 of
  1:
    begin
      pnFiltroAp.Visible := True;
    end;
  0:
    begin
      pnFiltroAp.Visible := False;
    end;
  end;
end;

procedure TformPrincipal.btnNovaEstrategiaClick(Sender: TObject);
begin
  ShowMessage ('Opção em desenvolvimento!');
end;

procedure TformPrincipal.btnNovoTimeClick(Sender: TObject);
begin
  ShowMessage ('Opção em desenvolvimento!');
end;

procedure TformPrincipal.btnRemoverEstrategiaClick(Sender: TObject);
begin
  ShowMessage ('Opção em desenvolvimento!');
end;

procedure TformPrincipal.btnRemoverTimeClick(Sender: TObject);
begin
  ShowMessage ('Opção em desenvolvimento!');
end;

procedure TformPrincipal.Button1Click(Sender: TObject);
var codAposta: Integer;
begin
  codAposta := StrToInt(edtRemoverAposta.Text);
  qrApostas.ParamByName('Cod_Aposta').AsInteger := codAposta;
  try
     qrApostas.Post;
     qrApostas.ApplyUpdates;
     SQLTransaction1.Commit;
     SQLTransaction1.StartTransaction;
     ShowMessage ('Aposta Removida!');
  except
    on E: Exception do
    begin
      MessageDlg('Erro', 'Erro ao salvar os dados: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
  MudarCorLucro;
end;

procedure TformPrincipal.grdApostasColExit(Sender: TObject);
begin
  try
    qrApostas.Post;
    qrApostas.ApplyUpdates;
    SQLTransaction1.Commit;
    MudarCorLucro;
  except
    On E: Exception do
    begin
      MessageDlg('Erro', 'Erro ao salvar os dados: ' + E.Message, mtError, [mbOK], 0);
    end;

    On E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados: ' + E.Message, mtError, [mbOK], 0);
    end;

  end;
end;

procedure TformPrincipal.grdApostasExit(Sender: TObject);
begin
   MudarCorLucro;
end;

procedure TformPrincipal.ReiniciarTodosOsQueries;
begin
  SQLTransaction1.Commit;
      qrApostas.Open;
      qrTodosTimes.Close;
      qrTodosTimes.Open;
      qrTimesMaisLucrativos.Close;
      qrTimesMenosLucrativos.Open;
      qrCampeonatos.Close;
      qrCampeonatos.Open;
      qrEstrategias.Close;
      qrEstrategias.Open;
      qrApostas.Close;
      qrApostas.Open;
      qrOver15.Close;
      qrOver15.Open;
      qrBackFavorito.Close;
      qrBackfavorito.Open;
      qrZebraFavorito.Close;
      qrZebraFavorito.Open;
      qrCantos.Close;
      qrCantos.Open;
      qrHandicapAsiatico.Close;
      qrHandicapAsiatico.Open;
      qrHandicapEuropeu.Close;
      qrHandicapEuropeu.Open;
      qrCartoes.Close;
      qrCartoes.Open;
      qrBilhetePersonalizado.Close;
      qrBilhetePersonalizado.Open;
      qrOver25.Close;
      qrOver25.Open;
      qrUnder25.Close;
      qrUnder25.Open;
      qrUnder35.Close;
      qrUnder35.Open;
      qrTotGolsEquipe.Close;
      qrTotGolsEquipe.Open;
      qrEmpateAnula.Close;
      qrEmpateAnula.Open;
      qrChanceDupla.Close;
      qrChanceDupla.Open;
      qrApostaMultipla.Close;
      qrApostaMultipla.Open;
      qrOutros.Close;
      qrOutros.Open;
      qrBancaAtual.Close;
      qrBancaAtual.Open;
      qrBancaInicial.Close;
      qrBancaInicial.Open;
end;

end.
