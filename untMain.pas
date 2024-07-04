unit untMain;

{$mode objfpc}{$H+}
{$linklib fcl}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  Iphttpbroker, DateUtils, Math, Grids;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    btnNovaAposta: TButton;
    btnSalvarBancaInicial: TButton;
    btnFiltrarAp: TButton;
    btnRemoverAposta: TButton;
    btnNovaEstrategia: TButton;
    btnRemoverEstrategia: TButton;
    btnNovoTime: TButton;
    btnRemoverTime: TButton;
    cbCompeticao: TComboBox;
    chrtLucroAno: TChart;
    chrtLucroAnoLineSeries1: TLineSeries;
    chrtLucroMes: TChart;
    chrtEstrategias: TChart;
    chrtLucroMesLineSeries1: TLineSeries;
    chbMandante: TDBCheckBox;
    chbVisitante: TDBCheckBox;
    cbAno: TComboBox;
    cbMes: TComboBox;
    cbPerfil: TComboBox;
    cbTime: TComboBox;
    deFiltroDataInicial: TDateEdit;
    deFiltroDataFinal: TDateEdit;
    edtBancaInicial: TEdit;
    linkAtualizacoes: TIpHttpDataProvider;
    JSONPropStorage1: TJSONPropStorage;
    Label4: TLabel;
    Label5: TLabel;
    qrBancaInicialMoedaStake: TStringField;
    qrBancaInicialStake: TBCDField;
    qrEstrategiasCod_Estratgia: TLongintField;
    qrEstrategiasSelec: TBooleanField;
    qrPerfisPerfil: TStringField;
    qrSelecionarPerfilPerfilSelecionado: TStringField;
    dsSelecionarPerfil: TDataSource;
    dsPerfis: TDataSource;
    dbGraficoLucroAno: TDbChartSource;
    dbGraficoLucroMes: TDbChartSource;
    dsGraficoLucroAno: TDataSource;
    dsGraficoLucroMes: TDataSource;
    Label1: TLabel;
    Label2: TLabel;
    lbUnidade: TLabel;
    lbPerfil: TLabel;
    lbLucro: TLabel;
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
    conectBancoDados: TSQLite3Connection;
    transactionBancoDAdos: TSQLTransaction;
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
    procedure btnRemoverApostaClick(Sender: TObject);
    procedure cbAnoChange(Sender: TObject);
    procedure dsTimesMaisLucrativosDataChange(Sender: TObject; Field: TField);
    procedure grdApostasColEnter(Sender: TObject);
    procedure grdApostasColExit(Sender: TObject);
    procedure grdApostasDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure grdApostasExit(Sender: TObject);
    procedure grdApostasUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure grdEstrategiasCellClick(Column: TColumn);
    procedure grdEstrategiasColEnter(Sender: TObject);
    procedure grdEstrategiasColExit(Sender: TObject);
    procedure grdEstrategiasDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure grdEstrategiasExit(Sender: TObject);
    procedure grdEstrategiasKeyPress(Sender: TObject; var Key: char);
    procedure grdEstrategiasSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure grdEstrategiasUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure grdTodosTimesCellClick(Column: TColumn);
    procedure grdTodosTimesColEnter(Sender: TObject);
    procedure grdTodosTimesColExit(Sender: TObject);
    procedure grdTodosTimesExit(Sender: TObject);
    procedure grdTodosTimesUserCheckboxState(Sender: TObject; Column: TColumn;
      var AState: TCheckboxState);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
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
    procedure LocalizarBancoDeDados;
    procedure tsApostasShow(Sender: TObject);
    procedure tsCampeonatosShow(Sender: TObject);
    procedure tsEstrategiasContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure tsEstrategiasShow(Sender: TObject);
    procedure tsPainelShow(Sender: TObject);
    procedure tsTimesShow(Sender: TObject);

   //Funções e procedimentos personalizados
   function VerificarAtualizacoes (currentVersion: string): string;
   function JaAtualizado: Boolean;
   procedure VerificarVersaoBancoDeDados;
   procedure FontesEditaveis;
   procedure AtualizarBancoDeDados;
   procedure CriarBancoDeDados;
   procedure ExecutarSQLDeArquivo(const VarArquivo: string);
   function FimDoTexto(const Ending, FullString: string): Boolean;
  private
      contadorCliques: Integer;
  public

  end;

var
  currentVersion: String;
  formPrincipal: TformPrincipal;
  perfilInvestidor: String;
  stakeAposta: Double;
  valorInicial: Double;
  mesSelecionado, anoSelecionado: Integer;
  estrategia: String;
  versaoBDInstalada: Integer;
  versaoBDEsperada: Integer = 2;
  CriarBD: String;
  AtualizarBD: String;
  LocalizarBD: String;
implementation
uses
  untNA, fpjson, HTTPDefs, fphttpclient, httpsend, synautil, jsonparser, LCLIntf, IdSSLOpenSSLHeaders, ssl_openssl3;

{$R *.lfm}

{ TformPrincipal }
function CompareVersion(version1, version2: string): Integer;
var
  ver1, ver2: TStringDynArray;
  i: Integer;
begin
  // Dividir as versões em partes
  ver1 := version1.Split(['.']);
  ver2 := version2.Split(['.']);

  // Comparar cada parte da versão
  for i := Low(ver1) to High(ver1) do
  begin
    if i > High(ver2) then
      Exit(1); // ver1 tem mais partes que ver2

    if StrToInt(ver1[i]) < StrToInt(ver2[i]) then
      Exit(-1)
    else if StrToInt(ver1[i]) > StrToInt(ver2[i]) then
      Exit(1);
  end;

  // Se todas as partes comparadas forem iguais até aqui
  if Length(ver1) < Length(ver2) then
    Result := -1 // ver2 tem mais partes que ver1
  else
    Result := 0; // Versões são iguais até onde foram comparadas
end;

function TformPrincipal.VerificarAtualizacoes(currentVersion: string): string;
var
  response: TStringStream;
  apiUrl, latestVersion: string;
  json: TJSONObject;
  userResponse: Integer;
begin
  currentVersion := ('0.0.0.4');
  Result := '';
  apiUrl := 'https://api.github.com/repos/FeroxGraxaim/graxaimgestaodebanca/releases/latest';
  response := TStringStream.Create('');
  try
    if HttpGetBinary(apiUrl, response) then
    begin
      //ShowMessage('Requisição bem-sucedida. Resposta recebida: ' + response.DataString);
      json := TJSONObject(GetJSON(response.DataString));
      try
        latestVersion := json.Get('tag_name', '');
        if latestVersion <> '' then
        begin
          if CompareText(currentVersion, latestVersion) < 0 then
          begin
            userResponse := MessageDlg('Nova versão disponível: ' + latestVersion + sLineBreak +
                                       'Deseja instalar agora?', mtConfirmation, [mbYes, mbNo], 0);
            if userResponse = mrYes then
            begin
              OpenURL('https://github.com/FeroxGraxaim/graxaimgestaodebanca/releases/latest');
            end;
          end;
        end
        else
        begin
          ShowMessage('Versão não encontrada no JSON.');
        end;
      finally
        json.Free;
      end;
    end
    else
    begin
      ShowMessage('Falha ao obter informações de atualização. Resposta: ' + response.DataString);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Erro: ' + E.Message + sLineBreak + 'Resposta: ' + response.DataString);
    end;
  end;
  response.Free;
end;

function TformPrincipal.JaAtualizado: Boolean;
begin
  writeln('Verificando se o arquivo de marcação existe...');
  {$IFDEF MSWINDOWS}
   Result := FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
    'GraxaimBanca\NaoExcluir)';
  {$ENDIF}

  {$IFDEF LINUX}
   Result := FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
    '.GraxaimBanca/NaoExcluir');
  {$ENDIF}
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
  transactionBancoDAdos.Commit;

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

       if not conectBancoDados.Connected then
         conectBancoDados.Connected := True;


       qrBancaInicial.Close;
       qrBancaInicial.SQL.Text := 'SELECT "Mês", "Ano", "Valor_Inicial", "Stake" FROM "Banca" WHERE "Mês" = :mesSelecionado AND "Ano" = :anoSelecionado';
       qrBancaInicial.ParamByName('mesSelecionado').AsInteger := mes;
       qrBancaInicial.ParamByName('anoSelecionado').AsInteger := ano;
       qrBancaInicial.Open;

       if qrBancaInicial.RecordCount = 0 then
       begin

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
       transactionBancoDAdos.Commit;

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

         ShowMessage('Erro ao salvar: ' + E.Message);
         transactionBancoDAdos.Rollback;
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

procedure TformPrincipal.btnNovaApostaClick(Sender: TObject);
begin
  try
    formNovaAposta.ShowModal;
  finally
    formNovaAposta.Free;
    ReiniciarTodosOsQueries;
    if qrApostas.IsEmpty then grdApostas.Enabled:=False
    else grdApostas.Enabled:=True;
  end;
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
  anoAtual: Integer;
begin
 VerificarAtualizacoes(currentVersion);
 LocalizarBancoDeDados;;
 MudarCorLucro;
 qrApostas.EnableControls;
 qrEstrategias.EnableControls;
 anoAtual := YearOf(Now);
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


  qrSelecionarPerfil.Open;
  try
    perfilInvestidor := qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString;
  finally
    qrSelecionarPerfil.Close;
  end;
  cbPerfil.Text := perfilInvestidor;

  cbMes.Clear;
  cbAno.Items.Add(IntToStr(qrBancaInicial.FieldByName('Ano').AsInteger));
  for i := 1 to 12 do
  cbMes.Items.Add(IntToStr(i));
  cbMes.ItemIndex := MonthOf(Now) - 1;
  if cbAno.Items.IndexOf(IntToStr(anoAtual)) = -1 then
     cbAno.Items.Add(IntToStr(anoAtual));
     cbAno.ItemIndex := cbAno.Items.IndexOf(IntToStr(anoAtual));

  Estrategias := TStringList.Create;
  Situacao := TStringList.Create;
  Competicao := TStringList.Create;
  Time := TStringList.Create;
  Unidade := TStringList.Create;
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
begin
  if not (qrApostas.State in [dsEdit, dsInsert]) then
    qrApostas.Edit;

  if Column.Field is TBooleanField then
  begin
    try
      qrApostas.Post;
      qrApostas.ApplyUpdates;
      transactionBancoDados.Commit;
      qrApostas.Open;
      grdApostas.Invalidate;
    except
      on E: EDatabaseError do
      begin
        MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        qrApostas.Cancel;
        transactionBancoDados.RollbackRetaining;
      end;
      on E: Exception do
      begin
        MessageDlg('Erro', 'Erro ao remover a aposta. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        transactionBancoDados.RollbackRetaining;
      end;
    end;
  end;
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
  ShowMessage('Opção em desenvolvimento!');
end;

procedure TformPrincipal.btnNovaEstrategiaClick(Sender: TObject);
begin
  qrEstrategias.Append;
  qrEstrategias.Insert;
  qrEstrategias.Edit;
end;

procedure TformPrincipal.btnNovoTimeClick(Sender: TObject);
begin
  qrTodosTimes.Append;
  qrTodosTimes.Edit;
end;

 procedure TformPrincipal.btnRemoverEstrategiaClick(Sender: TObject);
begin
  if not qrEstrategias.Active then
    qrEstrategias.Open;

  if dsEstrategias.DataSet.IsEmpty then
  begin
    ShowMessage('Não há estratégias para remover.');
    Exit;
  end;
  try
    qrEstrategias.Delete;
    qrEstrategias.ApplyUpdates;
    transactionBancoDados.CommitRetaining;
    ShowMessage('Estratégia(s) removida(s)!');
  except
  ShowMessage ('Selecione uma estratégia para remover!');
  end;
  qrEstrategias.Open;
  MudarCorLucro;
end;

procedure TformPrincipal.btnRemoverTimeClick(Sender: TObject);
begin
    if qrTodosTimes.IsEmpty then
  begin
    ShowMessage('Não há times para remover.');
    Exit;
  end;
    if MessageDlg('Tem certeza que deseja excluir o(s) time(s) selecionado(s)?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
         try
            qrTodosTimes.Delete;
            transactionBancoDados.CommitRetaining;
            qrTodosTimes.ApplyUpdates;
            ShowMessage('Time(s) Removido(s)!');
         except
         on E: Exception do
            begin
              MessageDlg('Erro', 'Erro ao remover time(s). Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
              transactionBancoDados.RollbackRetaining;
            end;
         end;
    end;
  qrApostas.Open;
end;

procedure TFormPrincipal.btnRemoverApostaClick(Sender: TObject);
begin
  if not dsApostas.DataSet.Active then
    dsApostas.DataSet.Open;

  if dsApostas.DataSet.IsEmpty then
  begin
    ShowMessage('Não há apostas para remover.');
    Exit;
  end;

  try
    dsApostas.DataSet.Delete;
    qrApostas.ApplyUpdates;
    transactionBancoDados.Commit;
    qrApostas.Open;
    dsApostas.DataSet.Refresh;
    grdApostas.Invalidate;
    ShowMessage('Aposta(s) Removida(s)!');
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      transactionBancoDados.RollbackRetaining;
    end;
    on E: Exception do
    begin
      MessageDlg('Erro', 'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      transactionBancoDados.RollbackRetaining;
    end;
  end;
  if qrApostas.IsEmpty then grdApostas.Enabled:=False
  else grdApostas.Enabled:=True;
  MudarCorLucro;
end;

procedure TformPrincipal.cbAnoChange(Sender: TObject);
begin

end;

procedure TformPrincipal.dsTimesMaisLucrativosDataChange(Sender: TObject;
  Field: TField);
begin

end;

procedure TformPrincipal.grdApostasColEnter(Sender: TObject);
begin
  if not (qrApostas.State in [dsEdit, dsInsert]) then
    qrApostas.Edit;

  if (Sender is TDBGrid) and (TDBGrid(Sender).SelectedField is TBooleanField) then
  begin
    try
      qrApostas.Post;
      qrApostas.ApplyUpdates;
      transactionBancoDados.Commit;
      qrApostas.Open;
      grdApostas.Invalidate;
    except
      on E: EDatabaseError do
      begin
        MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        qrApostas.Cancel;
        transactionBancoDados.RollbackRetaining;
      end;
      on E: Exception do
      begin
        MessageDlg('Erro', 'Ocorreu um erro, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        transactionBancoDados.RollbackRetaining;
      end;
    end;
  end;
end;

procedure TformPrincipal.grdApostasColExit(Sender: TObject);
begin
  if qrApostas.State in [dsEdit, dsInsert] then
    qrApostas.Post;

  try
    qrApostas.ApplyUpdates;
    transactionBancoDados.Commit;
    qrApostas.Open;
    MudarCorLucro;
    qrApostas.Edit;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      qrApostas.Cancel;
      transactionBancoDados.RollbackRetaining;
    end;
    on E: Exception do
    begin
      MessageDlg('Erro', 'Erro ao salvar dados, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      transactionBancoDados.RollbackRetaining;
    end;
  end;
end;

procedure TformPrincipal.grdApostasDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin

end;

procedure TformPrincipal.grdApostasExit(Sender: TObject);
begin
  try
    if qrApostas.State in [dsEdit, dsInsert] then
      qrApostas.Post;

    qrApostas.ApplyUpdates;
    transactionBancoDados.Commit;
    qrApostas.Open;
    MudarCorLucro;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      qrApostas.Cancel;
      transactionBancoDados.RollbackRetaining;
    end;
    on E: Exception do
    begin
      MessageDlg('Erro', 'Erro ao salvar os dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      transactionBancoDados.RollbackRetaining;
    end;
  end;
end;

procedure TformPrincipal.grdApostasUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin

end;

procedure TformPrincipal.grdEstrategiasCellClick(Column: TColumn);
begin
  if not qrEstrategias.Active then
    qrEstrategias.Open;

  if not (qrEstrategias.State in [dsEdit, dsInsert]) then
    qrEstrategias.Edit;

  if Column.Field is TBooleanField then
  begin
    try
      qrEstrategias.Post;
      grdEstrategias.Invalidate;
    except
      on E: EDatabaseError do
      begin
        MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        qrEstrategias.Cancel;
        transactionBancoDados.RollbackRetaining;
      end;
      on E: Exception do
      begin
        MessageDlg('Erro', 'Erro ao selecionar estratégia, tente novamente. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        transactionBancoDados.RollbackRetaining;
      end;
    end;
  end;
end;

procedure TformPrincipal.grdEstrategiasColEnter(Sender: TObject);
begin
  if not qrEstrategias.Active then
    qrEstrategias.Open;

  if not (qrEstrategias.State in [dsEdit, dsInsert]) then
    qrEstrategias.Edit;

  if (Sender is TDBGrid) and (TDBGrid(Sender).SelectedField is TBooleanField) then
  begin
    try
      qrEstrategias.Post;
      grdEstrategias.Invalidate;
    except
      on E: EDatabaseError do
      begin
        MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        qrEstrategias.Cancel;
        transactionBancoDados.RollbackRetaining;
      end;
      on E: Exception do
      begin
        MessageDlg('Erro', 'Erro ao selecionar estratégia. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
        transactionBancoDados.RollbackRetaining;
      end;
    end;
  end;
end;

procedure TformPrincipal.grdEstrategiasColExit(Sender: TObject);
begin
  try
    if qrEstrategias.State in [dsEdit, dsInsert] then
      qrEstrategias.Post;

    qrEstrategias.Close;
    qrEstrategias.Open;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      qrEstrategias.Cancel;
    end;
  end;
end;


procedure TformPrincipal.grdEstrategiasDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin

end;

procedure TformPrincipal.grdEstrategiasExit(Sender: TObject);
begin
  try
    if qrEstrategias.State in [dsEdit, dsInsert] then
      qrEstrategias.Post;

    qrEstrategias.Close;
    qrEstrategias.Open;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      qrEstrategias.Cancel;
    end;
  end;
end;


procedure TformPrincipal.grdEstrategiasKeyPress(Sender: TObject; var Key: char);
begin
//  if grdEstrategias.Columns[ColIndex].ReadOnly then Key := 0;
end;

procedure TformPrincipal.grdEstrategiasSelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin

end;

procedure TformPrincipal.grdEstrategiasUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin

end;

procedure TformPrincipal.grdTodosTimesCellClick(Column: TColumn);
begin
  try
     qrTodosTImes.Edit;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
      qrEstrategias.Cancel;
    end;
  end;
      if Column.Field is TBooleanField then
  begin
    qrTodosTimes.Edit;
    qrTodosTimes.Post;
    qrTodosTimes.ApplyUpdates;
    transactionBancoDados.CommitRetaining;
    grdTodosTimes.Invalidate;
  end;
end;

procedure TformPrincipal.grdTodosTimesColEnter(Sender: TObject);
begin
  try
     qrEstrategias.Edit;
  except
    on E: EDatabaseError do
    begin
      MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);;
      qrEstrategias.Cancel;
    end;
  end;
end;

procedure TformPrincipal.grdTodosTimesColExit(Sender: TObject);
begin
  try
     qrTodosTimes.Edit;
     qrTodosTimes.Post;
     qrTodosTimes.ApplyUpdates;
     transactionBancoDAdos.Commit;
     qrTodosTimes.Edit;
   except
     on E: EDatabaseError do
     begin
       MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
       qrTodosTimes.Cancel;
     end;
   end;
end;

procedure TformPrincipal.grdTodosTimesExit(Sender: TObject);
begin
  try
     qrTodosTimes.Edit;
     qrTodosTimes.Post;
     qrTodosTimes.ApplyUpdates;
     transactionBancoDAdos.Commit;
   except
     on E: EDatabaseError do
     begin
       MessageDlg('Erro', 'Erro de banco dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
       qrTodosTimes.Cancel;
     end;
   end;
  qrTodosTimes.Open;
end;

procedure TformPrincipal.grdTodosTimesUserCheckboxState(Sender: TObject;
  Column: TColumn; var AState: TCheckboxState);
begin

end;

procedure TformPrincipal.MenuItem8Click(Sender: TObject);
begin
    VerificarAtualizacoes(currentVersion);
end;

procedure TformPrincipal.MenuItem9Click(Sender: TObject);
begin

end;

procedure TformPrincipal.ReiniciarTodosOsQueries;
begin
  transactionBancoDAdos.Commit;
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

procedure TFormPrincipal.FontesEditaveis;
begin

end;

procedure TformPrincipal.tsApostasShow(Sender: TObject);
begin
  if not qrApostas.Active then
  qrApostas.Open;
  if qrApostas.IsEmpty then grdApostas.Enabled:=False
  else grdApostas.Enabled:=True;
end;

procedure TformPrincipal.tsCampeonatosShow(Sender: TObject);
begin
  if not qrCompeticoes.Active then
  qrCompeticoes.Open;
end;

procedure TformPrincipal.tsEstrategiasContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TformPrincipal.tsEstrategiasShow(Sender: TObject);
begin
  if not qrEstrategias.Active then
  qrEstrategias.Open;
end;

procedure TformPrincipal.tsPainelShow(Sender: TObject);
begin
  if not qrBancaInicial.Active then qrBancaInicial.Open;
  if not qrBancaAtual.Active then qrBancaAtual.Open;
end;

procedure TformPrincipal.tsTimesShow(Sender: TObject);
begin
  if not qrTodosTimes.Active then
  qrTodosTimes.Open;
  if not qrTimesMaisLucrativos.Active then
  qrTimesMaisLucrativos.Open;
  if not qrTimesMenosLucrativos.Active then
  qrTimesMenosLucrativos.Open;
end;

procedure TformPrincipal.AtualizarBancoDeDados;
begin
  try
    if FileExists(AtualizarBD) then ExecutarSQLDeArquivo(AtualizarBD)
    else
      begin
        MessageDlg('Erro', 'Não foi possível atualizar o banco de dados, o arquivo de atualização não existe. Favor executar o arquivo de instalação do programa para reparar.', mtError, [mbOK], 0);
        Close;
      end;
   finally
     writeln ('Banco de dados atualizado com sucesso! Excluindo script...');
     DeleteFile(AtualizarBD);
   end;
end;

procedure TformPrincipal.CriarBancoDeDados;

begin
 try
    writeln('Banco de dados não existe, criando...');
   try
     if FileExists(CriarBD) then
     begin
      try
       ExecutarSQLDeArquivo(CriarBD);
      except
        On E: Exception do
        begin
          writeln ('Erro ao executar script SQL: ' + E.message);
        end;
      end;
     end
     else begin
       writeln ('Erro: arquivo de criação do banco de dados não existe. Abortado.');
       Close;
     end;
   except
     on E: Exception do
     begin
       writeln ('Erro ao criar banco de dados: ' + E.message);
       MessageDlg('Erro', 'Não foi possível criar o banco de dados. Tente reinstalar o programa. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
     end;
   end;
 finally
   writeln ('Banco de dados atualizado com sucesso! Excluindo script...');
   DeleteFile(CriarBD);
 end;
end;

procedure TformPrincipal.VerificarVersaoBancoDeDados;
var qrVersaoBD: TSQLQuery;
begin
 qrVersaoBD := TSQLQuery.Create(nil);
 writeln ('Verificando se o banco de dados está atualizado...');
    try
      qrVersaoBD.Database := conectBancoDados;
      qrVersaoBD.SQL.Text := 'SELECT Versao FROM ControleVersao';
      qrVersaoBD.Open;

      if not qrVersaoBD.IsEmpty then
      begin
        if qrVersaoBD.FieldByName('Versao').AsInteger < versaoBDEsperada then
        begin
          writeln('Banco de dados está desatualizado, fazendo atualização...');
          AtualizarBancoDeDados;
        end;
      end
      else
      begin
        writeln('A tabela ControleVersao está vazia, fazendo a atualização...');
        AtualizarBancoDeDados;
      end;
    except
    on E: Exception do
    begin
      writeln('A tabela ControleVersao não existe no banco de dados, fazendo a atualização...');
      if Pos('no such table', LowerCase(E.Message)) > 0 then
       AtualizarBancoDeDados;
    end;
    end;
end;

procedure TformPrincipal.LocalizarBancoDeDados;
begin
  try
    writeln('Verificando se o banco de dados existe...');
    conectBancoDados.DatabaseName := (LocalizarBD);
     if not FileExists (LocalizarBD) then
     begin
       CriarBancoDeDados;
       conectBancoDados.DatabaseName := (LocalizarBD);
     end
     else VerificarVersaoBancoDeDados;
   try
    if not conectBancoDados.Connected then
    begin
     writeln('Conectando com o banco de dados...');
      conectBancoDados.Connected := True;
    end;
   except
     on E: Exception do
     begin
       MessageDlg('Erro', 'Não foi possível conectar com o banco de dados. Se o problema persistir favor informar no Github com a seguinte mensagem: ' + E.Message, mtError, [mbOK], 0);
       Close;
     end;
   end;
  except
    on E: Exception do
      MessageDlg('Erro', 'Ocorreu um erro. Tente reiniciar o programa. Se o erro persistir, favor informar no GitHub incluindo a seguinte mensagem de erro: ' + E.Message, mtError, [mbOK], 0);
  end;
end;

//Procedimento para executar SQL de um arquivo
procedure TformPrincipal.ExecutarSQLDeArquivo(const VarArquivo: string);
var
  Arquivo: TStringList;
  ScriptSQL: TStringBuilder;
  I: Integer;
  LinhaSQL: string;
  DentroDeTrigger: Boolean;
begin
  Arquivo := TStringList.Create;
  ScriptSQL := TStringBuilder.Create;
  try
    Arquivo.LoadFromFile(VarArquivo);
    DentroDeTrigger := False;

    for I := 0 to Arquivo.Count - 1 do
    begin
      LinhaSQL := Trim(Arquivo[I]);

      if (LinhaSQL <> '') and (not LinhaSQL.StartsWith('--')) then
      begin
        ScriptSQL.Append(LinhaSQL);
        ScriptSQL.Append(' ');

        if LinhaSQL.StartsWith('CREATE TRIGGER', True) then
          DentroDeTrigger := True;

        if (not DentroDeTrigger and FimDoTexto(';', LinhaSQL)) or
           (DentroDeTrigger and FimDoTexto('END;', LinhaSQL)) then
        begin
          try
            if not conectBancoDados.Connected then
              conectBancoDados.Connected := True;

            if not transactionBancoDados.Active then
              transactionBancoDados.StartTransaction;

            conectBancoDados.ExecuteDirect(ScriptSQL.ToString);

            if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
              writeln('Gatilho criado.')
            else if LinhaSQL.StartsWith('CREATE TABLE IF NOT EXISTS', True) then
              writeln('Tabela criada caso não exista.')
            else if LinhaSQL.StartsWith('INSERT INTO', True) then
              writeln('Dados padrão inseridos na tabela.');

            transactionBancoDados.Commit;
          except
            on E: Exception do
            begin
              if transactionBancoDados.Active then
                transactionBancoDados.Rollback;
              writeln('Erro ao executar comando SQL: ' + E.Message + ' Comando: ' + ScriptSQL.ToString);
            end;
          end;

          ScriptSQL.Clear;
          if DentroDeTrigger and FimDoTexto('END;', LinhaSQL) then
            DentroDeTrigger := False;
        end;
      end;
    end;
  finally
    Arquivo.Free;
    ScriptSQL.Free;
  end;
end;

function TformPrincipal.FimDoTexto(const Ending, FullString: string): Boolean;
var
  LenEnding, LenFullString: Integer;
begin
  LenEnding := Length(Ending);
  LenFullString := Length(FullString);

  if LenEnding > LenFullString then
    Result := False
  else
    Result := SameText(Ending, Copy(FullString, LenFullString - LenEnding + 1, LenEnding));
end;

//Procedimento que criei para futuramente colocar comandos personalizados para serem executados só uma vez.
{procedure TformPrincipal.PosAtualizacao;
var
  NaoExcluir: TStringList;
  programAtualizado: Boolean = False;
begin
    if not JaAtualizado then
    begin
      NaoExcluir := TStringList.Create;
      try
        {$IFDEF MSWINDOWS}
        writeln('Sistema Windows detectado!');
        NaoExcluir.SaveToFile(IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
          'GraxaimBanca\NaoExcluir');
        writeln('Criado arquivo de marcação em %APPDATA%\GraxaimBanca\');
        {$ENDIF}

        {$IFDEF LINUX}
        writeln('Sistema Linux detectado!');
        NaoExcluir.SaveToFile(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
          '.GraxaimBanca/NaoExcluir');
        writeln('Criado arquivo de marcação em $HOME/.GraxaimBanca/');
        {$ENDIF}
      finally
        NaoExcluir.Free;
      end;
      programAtualizado := True;
    end;
end;}
initialization

{$IFDEF MSWINDOWS}
  CriarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
  'GraxaimBanca\criarbd.sql');
  CriarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
  'GraxaimBanca/criarbd.sql');
  AtualizarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA')) +
  'GraxaimBanca/atualizarbd.sql');
 {$ENDIF}

 {$IFDEF LINUX}
  CriarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
  '.GraxaimBanca/criarbd.sql');
  AtualizarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
  '.GraxaimBanca/atualizarbd.sql');
  LocalizarBD := (IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
  '.GraxaimBanca/database.db');
 {$ENDIF}
end.
