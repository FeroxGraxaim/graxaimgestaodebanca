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
Iphttpbroker, DateUtils, Math, Grids, TAChartAxisUtils;

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
  dsGraficoAno: TDataSource;
  dbGraficoAno: TDbChartSource;
  dsGraficoMes: TDataSource;
  dbGraficoMes: TDbChartSource;
  lnGraficoLucroAno: TLineSeries;
  chrtLucroMes: TChart;
  chrtEstrategias: TChart;
  lnGraficoLucroMes: TLineSeries;
  chbMandante: TDBCheckBox;
  chbVisitante: TDBCheckBox;
  cbAno:      TComboBox;
  cbMes:      TComboBox;
  cbPerfil:   TComboBox;
  cbTime:     TComboBox;
  qrMes:      TSQLQuery;
  qrAno:      TSQLQuery;
  txtStake:   TDBText;
  deFiltroDataInicial: TDateEdit;
  deFiltroDataFinal: TDateEdit;
  edtBancaInicial: TEdit;
  linkAtualizacoes: TIpHttpDataProvider;
  JSONPropStorage1: TJSONPropStorage;
  Label4:     TLabel;
  Label5:     TLabel;
  qrBancaAno: TLongintField;
  qrBancaInicialMoedaStake: TStringField;
  qrBancaLucroPrCntCalculado: TStringField;
  qrBancaLucroRSCalculado: TStringField;
  qrBancaLucro_: TBCDField;
  qrBancaLucro_R: TBCDField;
  qrBancaMs:  TLongintField;
  qrBancaStake: TBCDField;
  qrBancaValorCalculado: TStringField;
  qrBancaValorFinalCalculado: TStringField;
  qrBancaValor_Final: TBCDField;
  qrBancaValor_Inicial: TBCDField;
  qrEstrategiasCod_Estratgia: TLongintField;
  qrEstrategiasSelec: TBooleanField;
  qrPerfisPerfil: TStringField;
  qrSelecionarPerfilPerfilSelecionado: TStringField;
  dsSelecionarPerfil: TDataSource;
  dsPerfis:   TDataSource;
  Label1:     TLabel;
  Label2:     TLabel;
  lbUnidade:  TLabel;
  lbPerfil:   TLabel;
  lbLucro:    TLabel;
  qrPerfis:   TSQLQuery;
  qrSelecionarPerfil: TSQLQuery;

  dsUnidades: TDataSource;
  dsSituacao: TDataSource;
  dsCompeticoes: TDataSource;
  DBGrid3:    TDBGrid;
  dsBanca:    TDataSource;
  grdApostas: TDBGrid;
  grdEstrategias: TDBGrid;
  grdTimesMaisLucrativos: TDBGrid;
  grdTimesMenosLucrativos: TDBGrid;
  grdTodosTimes: TDBGrid;
  lbAno:      TLabel;
  lbBancaAtual: TLabel;
  lbBancaInicial: TLabel;
  lbListaTimes: TLabel;
  lbMes:      TLabel;
  lbTimesMaisLucrativos: TLabel;
  lbTimesMenosLucrativos: TLabel;
  lnApostaMultipla: TLineSeries;
  lnBackFavorito: TLineSeries;
  lnBilhetePersonalizado: TLineSeries;
  lnCantos:   TLineSeries;
  lnCartoes:  TLineSeries;
  lnChanceDupla: TLineSeries;
  lnEmpateAnula: TLineSeries;
  lnHandicapAsiatico: TLineSeries;
  lnHandicapEuropeu: TLineSeries;
  lnOutros:   TLineSeries;
  lnOver15:   TLineSeries;
  lnOver25:   TLineSeries;
  lnTotGolsEquipe: TLineSeries;
  lnUnder25:  TLineSeries;
  lnUnder35:  TLineSeries;
  lnZebraFavorito: TLineSeries;
  MainMenu1:  TMainMenu;
  MenuItem1:  TMenuItem;
  MenuItem2:  TMenuItem;
  MenuItem3:  TMenuItem;
  MenuItem4:  TMenuItem;
  MenuItem5:  TMenuItem;
  MenuItem6:  TMenuItem;
  MenuItem7:  TMenuItem;
  MenuItem8:  TMenuItem;
  PageControl1: TPageControl;
  PageControl2: TPageControl;
  qrBanca:    TSQLQuery;
  dbGraficoEstrategias: TDbChartSource;
  dsApostas:  TDataSource;
  dsEstrategias: TDataSource;
  dsCampeonatos: TDataSource;
  dsTimesMaisLucrativos: TDataSource;
  dsTimesMenosLucrativos: TDataSource;
  dsTodosTimes: TDataSource;
  lbListaTimes1: TLabel;
  qrCompeticoes: TSQLQuery;
  qrCampeonatos: TSQLQuery;
  qrEstrategias: TSQLQuery;
  qrEstrategiasEstratgia: TStringField;
  qrEstrategiasMercados_Estr: TLongintField;
  qrEstrategiasProfit_Estr: TFloatField;
  qrUnidades: TSQLQuery;
  qrUnidadesUnidade: TStringField;
  qrTodosTimes: TSQLQuery;
  qrTimesMaisLucrativos: TSQLQuery;
  qrTimesMenosLucrativos: TSQLQuery;
  qrApostas:  TSQLQuery;
  qrGrafLucroEstr: TSQLQuery;
  qrSituacao: TSQLQuery;
  conectBancoDados: TSQLite3Connection;
  transactionBancoDAdos: TSQLTransaction;
  Graficos:   TTabSheet;
  ResumodoMes: TTabSheet;
  ResumodoAno: TTabSheet;
  tsApostas:  TTabSheet;
  tsCampeonatos: TTabSheet;
  tsEstrategias: TTabSheet;
  tsPainel:   TTabSheet;
  tsTimes:    TTabSheet;
  txtBancaAtual: TDBText;
  txtLucroMoeda: TDBText;
  txtLucroPorCento: TDBText;
  procedure FormShow(Sender: TObject);
  procedure grdApostasDrawColumnCell(Sender: TObject; const Rect: TRect;
    DataCol: integer; Column: TColumn; State: TGridDrawState);
  procedure MenuItem8Click(Sender: TObject);
  procedure MenuItem9Click(Sender: TObject);
  procedure FormCreate(Sender: TObject);

  //Funções e procedimentos personalizados
  procedure ReiniciarTodosOsQueries;
  procedure MudarCorLucro;
  procedure PerfilDoInvestidor;

private

public
  procedure EventosCreate;
  procedure CriarEventosTSApostas;
  procedure CriarEventosTSEstrategias;
  procedure CriarEventosTSTimes;
  procedure CriarEventosTSPainel;
  procedure CriarEventosBancoDados;
end;

//Procedimentos da unit
procedure DefinirStake;


var
formPrincipal: TformPrincipal;
estrategia, perfilInvestidor: string;
stakeAposta, valorInicial: double;
mesSelecionado, anoSelecionado: integer;

implementation

uses
untNA, untUpdate, untCampeonatos, untEstrategias, untApostas,
untTimes, untPainel, untDatabase;

{$R *.lfm}

{ TformPrincipal }


procedure TformPrincipal.FormCreate(Sender: TObject);
var
  EventosTimes:   TEventosTimes;
  EventosPainel:  TEventosPainel;
  BancoDados:     TBancoDados;
  EventosEstrategias: TEventosEstrategias;
  EventosCampeonatos: TEventosCampeonatos;
  EventosApostas: TEventosApostas;
begin
  writeln('Criando formulário principal...');

  // Chamando procedimentos dos eventos
  writeln('Criando eventos do tsTimes...');
  tsTimes.OnShow      := @EventosTimes.tsTimesShow;
  grdTodosTimes.OnCellClick := @EventosTimes.grdTodosTimesCellClick;
  grdTodosTimes.OnColEnter := @EventosTimes.grdTodosTimesColEnter;
  grdTodosTimes.OnColExit := @EventosTimes.grdTodosTimesColExit;
  grdTodosTimes.OnExit := @EventosTimes.grdTodosTimesExit;
  btnNovoTime.OnClick := @EventosTimes.btnNovoTimeClick;
  btnRemoverTime.OnClick := @EventosTimes.btnRemoverTimeClick;

  writeln('Criando eventos do tsPainel...');
  tsPainel.OnShow   := @EventosPainel.tsPainelShow;
  btnSalvarBancaInicial.OnClick := @EventosPainel.btnSalvarBancaInicialClick;
  cbPerfil.OnChange := @EventosPainel.cbPerfilChange;
  edtBancaInicial.OnKeyPress := @EventosPainel.edtBancaInicialKeyPress;
  cbMes.OnChange    := @EventosPainel.cbMesChange;
  cbAno.OnChange    := @EventosPainel.cbAnoChange;

  writeln('Criando eventos do tsApostas...');
  tsApostas.OnShow      := @EventosApostas.tsApostasShow;
  grdApostas.OnColEnter := @EventosApostas.grdApostasColEnter;
  grdApostas.OnColExit  := @EventosApostas.grdApostasColExit;
  grdApostas.OnExit     := @EventosApostas.grdApostasExit;
  grdApostas.OnCellClick := @EventosApostas.grdApostasCellClick;
  btnRemoverAposta.OnClick := @EventosApostas.btnRemoverApostaClick;
  btnNovaAposta.OnClick := @EventosApostas.btnNovaApostaClick;
  grdApostas.OnDrawColumnCell := @EventosApostas.MudarCoresDasCelulas;

  writeln('Criando eventos do tsEstrategias...');
  tsEstrategias.OnShow      := @EventosEstrategias.tsEstrategiasShow;
  grdEstrategias.OnColEnter := @EventosEstrategias.grdEstrategiasColEnter;
  grdEstrategias.OnColExit  := @EventosEstrategias.grdEstrategiasColExit;
  grdEstrategias.OnCellClick := @EventosEstrategias.grdEstrategiasCellClick;
  btnNovaEstrategia.OnClick := @EventosEstrategias.btnNovaEstrategiaClick;
  btnRemoverEstrategia.OnClick := @EventosEstrategias.btnRemoverEstrategiaClick;

  writeln('Criando eventos do banco de dados...');
  qrBanca.OnCalcFields := @BancoDados.qrBancaCalcFields;

  VerificarAtualizacoes(currentVersion);

  // Quando for compilar a release, descomentar a linha abaixo:
  @BancoDados.LocalizarBancoDeDados;
  // if not conectBancoDados.Connected then
  // conectBancoDados.Open;

  // Definindo a variável perfilInvestidor
  perfilInvestidor := qrSelecionarPerfil.FieldByName('Perfil Selecionado').AsString;
  DefinirStake;
end;


procedure TformPrincipal.MudarCorLucro;
var
  query: TSQLQuery;
  Lucro: double;
begin
  writeln('Alterando a cor do lucro...');
  query := TSQLQuery.Create(nil);
    try
    query.DataBase := conectBancoDados;
    query.SQL.Text :=
      'SELECT "Lucro_R$" FROM Banca WHERE "Mês" = :MesSelecionado AND "Ano" = :AnoSelecionado';
    query.ParamByName('MesSelecionado').AsInteger := mesSelecionado;
    query.ParamByName('AnoSelecionado').AsInteger := anoSelecionado;
    query.Open;

    if not query.FieldByName('Lucro_R$').IsNull then
      begin
      Lucro := query.FieldByName('Lucro_R$').AsFloat;
      writeln('Detectado valor ', Lucro, ' na coluna!');
      end
    else
      begin
      Lucro := 0;
      writeln('Valor do lucro é ', Lucro);
      end;
    finally
    query.Free;
    end;

  if Lucro < 0 then
    begin
    txtBancaAtual.Font.Color    := clRed;
    txtLucroMoeda.Font.Color    := clRed;
    txtLucroPorCento.Font.Color := clRed;
    writeln('Lucro é negativo! Alterada cor do lucro para vermelha.');
    end
  else if Lucro > 0 then
      begin
      txtBancaAtual.Font.Color    := clGreen;
      txtLucroMoeda.Font.Color    := clGreen;
      txtLucroPorCento.Font.Color := clGreen;
      writeln('Lucro é positivo! Alterada cor do lucro para verde.');
      end
    else
      begin
      txtBancaAtual.Font.Color    := clDefault;
      txtLucroMoeda.Font.Color    := clDefault;
      txtLucroPorCento.Font.Color := clDefault;
      writeln('Lucro é igual a zero! Alterada cor do lucro para padrão.');
      end;
end;


procedure TformPrincipal.MenuItem8Click(Sender: TObject);
begin
  VerificarAtualizacoes(currentVersion);
end;

procedure TformPrincipal.grdApostasDrawColumnCell(Sender: TObject;
const Rect: TRect; DataCol: integer; Column: TColumn; State: TGridDrawState);
begin

end;

procedure TformPrincipal.FormShow(Sender: TObject);
var
  EventosTimes:   TEventosTimes;
  EventosPainel:  TEventosPainel;
  BancoDados:     TBancoDados;
  EventosEstrategias: TEventosEstrategias;
  EventosCampeonatos: TEventosCampeonatos;
  EventosApostas: TEventosApostas;
begin
  //Preenchendo os itens dos ComboBoxes do painel
  @EventosPainel.PreencherComboBox;

  //Atualizar o mês e ano
  @EventosPainel.AtualizaMesEAno;

  //Preenchendo o TEdit da Banca Inicial
  @EventosPainel.PreencherBancaInicial;

  //Chamando procedimento de calcular a stake
  PerfilDoInvestidor;

  //Definindo a stake
  DefinirStake;

  ReiniciarTodosOsQueries;

  //Chamando procedimento de mudar a cor do lucro
  MudarCorLucro;
end;

procedure TformPrincipal.MenuItem9Click(Sender: TObject);
begin

end;

procedure TformPrincipal.ReiniciarTodosOsQueries;
var
  qrPraReiniciar: TList;
  I: integer;
begin
  qrPraReiniciar := TList.Create;
    try
    qrPraReiniciar.Add(qrApostas);
    qrPraReiniciar.Add(qrTodosTimes);
    qrPraReiniciar.Add(qrTimesMaisLucrativos);
    qrPraReiniciar.Add(qrTimesMenosLucrativos);
    qrPraReiniciar.Add(qrCampeonatos);
    qrPraReiniciar.Add(qrEstrategias);
    qrPraReiniciar.Add(qrBanca);
    qrPraReiniciar.Add(qrCompeticoes);
    qrPraReiniciar.Add(qrSituacao);
    qrPraReiniciar.Add(qrUnidades);
    qrPraReiniciar.Add(qrPerfis);
    qrPraReiniciar.Add(qrSelecionarPerfil);

    for I := 0 to qrPraReiniciar.Count - 1 do
      begin
      if not TSQLQuery(qrPraReiniciar[I]).Active then
        begin
        writeln('Iniciando  ', TComponent(qrPraReiniciar[I]).Name);
        TSQLQuery(qrPraReiniciar[I]).Open;
        end
      else
        begin
        writeln('Reiniciando ', TComponent(qrPraReiniciar[I]).Name);
        TSQLQuery(qrPraReiniciar[I]).Refresh;
        end;
      end;
    except
    on E: Exception do
      begin
      writeln('Erro ao reiniciar os queries.' + E.Message);
      MessageDlg('Erro',
        'Ocorreu um erro. Se o problema persistir favor informar no Github com a seguinte mensagem: '
        + E.Message, mtError, [mbOK], 0);
      end;
    end;
  qrPraReiniciar.Free;
end;

procedure TformPrincipal.CriarEventosTSTimes;
begin
  writeln('Criando eventos do tsTimes...');
end;

procedure TformPrincipal.CriarEventosTSPainel;
begin

end;

procedure TformPrincipal.CriarEventosBancoDados;
begin

end;

procedure TformPrincipal.PerfilDoInvestidor;
var
  query: TSQLQuery;
begin

  if perfilInvestidor = 'Conservador' then
    stakeAposta := RoundTo(valorInicial / 100, -2)
  else
    if perfilInvestidor = 'Moderado' then
      stakeAposta := RoundTo(valorInicial / 70, -2)
    else
      if perfilInvestidor = 'Agressivo' then
        stakeAposta := RoundTo(valorInicial / 40, -2);

end;

procedure TformPrincipal.EventosCreate;
begin
end;

procedure TformPrincipal.CriarEventosTSApostas;
begin

end;

procedure TformPrincipal.CriarEventosTSEstrategias;
begin

end;

procedure DefinirStake;
var
  query: TSQLQuery;
begin
  query := TSQLQuery.Create(nil);
  query.DataBase := formPrincipal.conectBancoDados;
    try
    if not query.Active then query.Close;
    query.SQL.Text := 'UPDATE Banca SET "Stake" = :stake';
    formPrincipal.PerfilDoInvestidor;
    query.ParamByName('stake').AsFloat := stakeAposta;
    query.ExecSQL;
    formPrincipal.transactionBancoDados.Commit;
    except
    on E: Exception do
      begin
      writeln('Erro: ' + E.Message + ' Abortado');
      formPrincipal.transactionBancoDados.Rollback;
      end;
    end;
  query.Free;
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

end.
