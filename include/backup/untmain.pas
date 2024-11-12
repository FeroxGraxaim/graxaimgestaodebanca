unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, BufDataset, fpcsvexport, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, DBGrids, DBCtrls, Menus, ActnList, Buttons,
  ExtCtrls, JSONPropStorage, EditBtn, TASources, TAGraph, TARadialSeries, Types,
  TASeries, TADbSource, TACustomSeries, TAMultiSeries, DateUtils, Math, Grids,
  ValEdit, TAChartAxisUtils, FileUtil, HTTPDefs, untSalvarDados;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    btnExcluirPais: TButton;
    btnExcluirTime: TButton;
    btnExcluirLinha: TButton;
    btnExcluirMetodo: TButton;
    btnLimparFiltroAp: TButton;
    btnFiltrarAp: TButton;
    btnNovaAposta: TButton;
    btnExcluirComp: TButton;
    btnNovoPais: TButton;
    btnNovoTime: TButton;
    btnNovaLinha: TButton;
    btnNovoMetodo: TButton;
    btnPesquisarPais: TSpeedButton;
    btnPesquisarComp: TSpeedButton;
    btnRemoverAposta: TButton;
    btnSalvarBancaInicial: TButton;
    btnTudoGreen: TButton;
    btnTudoRed: TButton;
    btnCashout: TButton;
    btnNovaComp: TButton;
    bufExportar: TBufDataset;
    btnEditAposta: TButton;
    cbAno: TComboBox;
    cbGraficos: TComboBox;
    cbMes: TComboBox;
    cbPerfil: TComboBox;
    chrtAcertAno: TChart;
    chrtAcertLinha: TChart;
    chrtAcertMes: TChart;
    chrtAcertMetodo: TChart;
    chrtAcertTime: TChart;
    chrtAcertPais: TChart;
    chrtAcertComp: TChart;
    chrtAcertTimePieSeries1: TPieSeries;
    chrtAcertTimePieSeries2: TPieSeries;
    chrtAcertTimePieSeries3: TPieSeries;
    chrtAcertTodosAnos: TChart;
    chrtLucratTime: TChart;
    chrtLucratPais: TChart;
    chrtLucratComp: TChart;
    chrtLucratTimePieSeries1: TPieSeries;
    chrtLucratTimePieSeries2: TPieSeries;
    chrtLucratTimePieSeries3: TPieSeries;
    chrtLucroAno: TChart;
    chrtLucroTodosAnos: TChart;
    chrtLucroLinha: TChart;
    chrtLucroMes: TChart;
    chrtLucroMetodo: TChart;
    conectBancoDados: TSQLite3Connection;
    dsMP: TDataSource;
    dsMT: TDataSource;
    dsMC: TDataSource;
    grbLinha: TGroupBox;
    grbMetComp: TGroupBox;
    grbMetodo: TGroupBox;
    grbMetPais: TGroupBox;
    grbMetTime: TGroupBox;
    grdLinhasMes: TDBGrid;
    grdMC: TDBGrid;
    grdMetodosMes: TDBGrid;
    ExportarDados: TCSVExporter;
    dsComp: TDataSource;
    dsCompMenosAcert: TDataSource;
    dsCompMaisAcert: TDataSource;
    dsPaisesMenosAcert: TDataSource;
    dsPaisesMaisAcert: TDataSource;
    dsPais: TDataSource;
    dsTimesMenosAcert: TDataSource;
    dsTimesMaisAcert: TDataSource;
    dsTimes: TDataSource;
    dsAno: TDataSource;
    dsLinhasMes: TDataSource;
    dsLinhasAno: TDataSource;
    dsMetodosAno: TDataSource;
    dsMetodosMes: TDataSource;
    edtPesquisarTime: TEdit;
    edtPesquisarPais: TEdit;
    edtPesquisarComp: TEdit;
    gbListaLinha: TGroupBox;
    gbListaMetodo: TGroupBox;
    grbTimes: TGroupBox;
    grbPaises: TGroupBox;
    grbComp: TGroupBox;
    grbPaisesMaisAcert: TGroupBox;
    grbCompMaisLucr: TGroupBox;
    grbTimesMenosLucr: TGroupBox;
    grbTimesMaisLucr: TGroupBox;
    grbPaisesMenosAcert: TGroupBox;
    grbCompMenosLucr: TGroupBox;
    grdDadosAp: TDBGrid;
    dsDadosAposta: TDataSource;
    dbGraficoAno: TDbChartSource;
    dbGraficoMes: TDbChartSource;
    deFiltroDataFinal: TDateEdit;
    deFiltroDataInicial: TDateEdit;
    dsApostas: TDataSource;
    dsBanca: TDataSource;
    dsCompeticoes: TDataSource;
    dsGraficoAno: TDataSource;
    dsGraficoMes: TDataSource;
    dsMes: TDataSource;
    dsPerfis: TDataSource;
    dsSelecionarPerfil: TDataSource;
    dsSituacao: TDataSource;
    dsUnidades: TDataSource;
    edtBancaInicial: TEdit;
    grbApostas: TGroupBox;
    grbDetalhesAp: TGroupBox;
    grdAno: TDBGrid;
    grdApostas: TDBGrid;
    grdMes: TDBGrid;
    grdMP: TDBGrid;
    grdMT: TDBGrid;
    grdTimes: TDBGrid;
    grdPaises: TDBGrid;
    grdComp: TDBGrid;
    grdPaisesMaisAcert: TDBGrid;
    grdCompMaisLucr: TDBGrid;
    grdTimesMenosAcert: TDBGrid;
    grdTimesMaisAcert: TDBGrid;
    grdPaisesMenosAcert: TDBGrid;
    grdCompMenosLucr: TDBGrid;
    grbMetodos: TGroupBox;
    grbLinhas: TGroupBox;
    JSONPropStorage1: TJSONPropStorage;
    lbAcertosLin: TLabel;
    lbAcertosMet: TLabel;
    lbDataFim: TLabel;
    lbDataInicio: TLabel;
    lbErrosLin: TLabel;
    lbErrosMet: TLabel;
    lbLucroLin: TLabel;
    lbLucroMet: TLabel;
    lbMeioAcertLin: TLabel;
    lbMeioAcertMet: TLabel;
    lbMeioErroLin: TLabel;
    lbMeioErroMet: TLabel;
    lbMercadosLin: TLabel;
    lbMercadosMet: TLabel;
    lbNuloLin: TLabel;
    lbNuloMet: TLabel;
    lbSelecioneAposta: TLabel;
    lbAno: TLabel;
    lbBancaAtual: TLabel;
    lbBancaInicial: TLabel;
    lbLucro: TLabel;
    lbMes: TLabel;
    lbPerfil: TLabel;
    lbUnidade: TLabel;
    lnGraficoLucroAno: TLineSeries;
    lnGraficoLucroAno1: TLineSeries;
    lnGraficoLucroMes: TLineSeries;
    lsbLinhas: TListBox;
    lsbMetodos: TListBox;
    miExibirBoasVindas: TMenuItem;
    MenuPrincipal: TMainMenu;
    MenuOpcoes: TMenuItem;
    MenuAjuda: TMenuItem;
    miImportar: TMenuItem;
    miExportar: TMenuItem;
    MenuComoUsar: TMenuItem;
    MenuSobre: TMenuItem;
    MenuApoie: TMenuItem;
    pcMesMetodos: TPageControl;
    pcPrincipal: TPageControl;
    pcResumo: TPageControl;
    pizzaLinha: TPieSeries;
    pizzaMetodo: TPieSeries;
    pizzaMetodo1: TPieSeries;
    pizzaMetodo2: TPieSeries;
    pnGraficos: TPanel;
    pnGraficosMetodos: TPanel;
    pnTabelas: TPanel;
    popupLinhas: TPopupMenu;
    progStatus: TProgressBar;
    psGraficoGreensReds: TPieSeries;
    psGraficoGreensReds1: TPieSeries;
    psGraficoGreensReds2: TPieSeries;
    qrAno: TSQLQuery;
    qrAnoAno: TLargeintField;
    qrAnoLucroAnualReais: TFloatField;
    qrAnoLucroTotalPorCento: TFloatField;
    qrAnoMesGreen: TLargeintField;
    qrAnoMesRed: TLargeintField;
    qrAnoMs: TLargeintField;
    qrAnoTotalBancas: TFloatField;
    qrApostas: TSQLQuery;
    qrApostasBanca_Final: TBCDField;
    qrApostasCashout: TBooleanField;
    qrApostasCod_Aposta: TLongintField;
    qrApostasData: TDateField;
    qrApostasJogo: TStringField;
    qrApostasLucro: TBCDField;
    qrApostasMltipla: TBooleanField;
    qrApostasOdd: TBCDField;
    qrApostasRetorno: TBCDField;
    qrApostasRSBancaFinal: TStringField;
    qrApostasRSLucro: TStringField;
    qrApostasRSRetorno: TStringField;
    qrApostasSelecao: TBooleanField;
    qrApostasStatus: TStringField;
    qrApostasValor_Aposta: TBCDField;
    qrBanca: TSQLQuery;
    qrBancaAno: TLargeintField;
    qrBancaAno1: TLongintField;
    qrBancaBancaFinalCalc: TStringField;
    qrBancaInicialMoedaStake1: TStringField;
    qrBancaLucro: TFloatField;
    qrBancaLucroCalc: TStringField;
    qrBancaLucroPrCntCalculado1: TStringField;
    qrBancaLucroRCalc: TStringField;
    qrBancaLucroRSCalculado1: TStringField;
    qrBancaLucro_: TFloatField;
    qrBancaLucro_1: TBCDField;
    qrBancaLucro_R1: TBCDField;
    qrBancaMs: TLargeintField;
    qrBancaMs1: TLongintField;
    qrBancaStake: TBCDField;
    qrBancaStake1: TBCDField;
    qrBancaStakeCalc: TStringField;
    qrBancaValorCalculado1: TStringField;
    qrBancaValorFinalCalculado1: TStringField;
    qrBancaValor_Final: TFloatField;
    qrBancaValor_Final1: TBCDField;
    qrBancaValor_Inicial: TBCDField;
    qrBancaValor_Inicial1: TBCDField;
    qrLinhasAno: TSQLQuery;
    qrMes: TSQLQuery;
    qrMesDia: TStringField;
    qrMesesGreenRed: TSQLQuery;
    qrMesGreen: TLargeintField;
    qrMesNeutro: TLargeintField;
    qrMesNumGreen: TLargeintField;
    qrMesNumRed: TLargeintField;
    qrMesPorCentoLucro: TFloatField;
    qrMesRed: TLargeintField;
    qrMesSomaLucro: TFloatField;
    qrMetodosAno: TSQLQuery;
    qrMetodosMesCod_Metodo1: TLargeintField;
    qrMetodosMesGreens1: TLargeintField;
    qrMetodosMesMtodo1: TStringField;
    qrMetodosMesPcentAcertos1: TFloatField;
    qrMetodosMesReds1: TLargeintField;
    qrMetodosMesTotalApostas1: TLargeintField;
    qrPerfis: TSQLQuery;
    qrPerfisPerfil: TStringField;
    qrPerfisPerfil1: TStringField;
    qrSelecionarPerfil: TSQLQuery;
    qrSelecionarPerfilPerfilSelecionado: TStringField;
    qrSelecionarPerfilPerfilSelecionado1: TStringField;
    qrSituacao: TSQLQuery;
    qrUnidades: TSQLQuery;
    qrUnidadesUnidade: TStringField;
    qrUnidadesUnidade1: TStringField;
    rbGestPcent: TRadioButton;
    rbGestUn: TRadioButton;
    scriptRemoverAposta: TSQLScript;
    qrDadosAposta: TSQLQuery;
    qrMetodosMes: TSQLQuery;
    qrLinhasMes: TSQLQuery;
    scriptSalvarDados: TSQLScript;
    btnPesquisarTime: TSpeedButton;
    qrTimes: TSQLQuery;
    qrTimesMaisAcert: TSQLQuery;
    qrTimesMenosAcert: TSQLQuery;
    qrPais: TSQLQuery;
    qrPaisesMaisAcert: TSQLQuery;
    qrPaisesMenosAcert: TSQLQuery;
    qrComp: TSQLQuery;
    qrCompMaisAcert: TSQLQuery;
    qrCompMenosAcert: TSQLQuery;
    qrMP: TSQLQuery;
    qrMT: TSQLQuery;
    qrMC: TSQLQuery;
    BarraStatus: TStatusBar;
    tsContrTimes: TTabSheet;
    tsContrPaises: TTabSheet;
    tsContrComp: TTabSheet;
    transactionBancoDAdos: TSQLTransaction;
    cloneMultipla, cloneInfoMult: TPanel;
    tsApostas: TTabSheet;
    tsControleMetodos: TTabSheet;
    tsDadosMesMetodos: TTabSheet;
    tsGraficos: TTabSheet;
    tsGraficosMesMetodos: TTabSheet;
    tsPainel: TTabSheet;
    tsResumoLista: TTabSheet;
    txtBancaAtual: TDBText;
    txtLucroMoeda: TDBText;
    txtLucroPorCento: TDBText;
    txtStake: TDBText;
    procedure dsBancaDataChange(Sender: TObject; Field: TField);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure grdApostasEditingDone(Sender: TObject);
    procedure grdDadosApCellClick(Column: TColumn);
    procedure grdDadosApEditingDone(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure miExibirBoasVindasClick(Sender: TObject);
    procedure qrApostasAfterOpen(DataSet: TDataSet);
    procedure qrApostasAfterRefresh(DataSet: TDataSet);
    procedure qrApostasBeforeRefresh(DataSet: TDataSet);
    procedure ReiniciarTodosOsQueries;
    procedure MudarCorLucro;
    procedure PerfilDoInvestidor;
    procedure SalvarDadosBD(Sender: TObject);
    procedure ImportarDadosBD(Sender: TObject);
    procedure GestaoUnidadePcent(Sender: TObject);
    procedure DefinirStake;
  private

  public
    GestaoUnidade: boolean;
    procedure PosAtualizacao;
    procedure ExcecaoGlobal(Sender: TObject; E: Exception);
    procedure CarregaConfig;
  end;

var
  ColunaAtual: TColumn;
  Arquivo: TFileStream;
  Linha: string;
  ExibirBoasVindas: boolean;

var
  formPrincipal: TformPrincipal;
  estrategia, perfilInvestidor: string;
  stakeAposta, valorInicial: double;
  contMult: integer;
  mesSelecionado: integer;
  anoSelecionado: integer;
  GestaoPcent: boolean;

implementation

uses
  untUpdate, untApostas, untPainel, untSplash, untDatabase, untMultipla, untSobre,
  untControleMetodos, untControleTimes, untPaises, untContrComp,
  fpjson, fphttpclient, jsonparser, LCLIntf, untBoasVindas;

var
  BoasVindas: TformBoasVindas;

procedure TformPrincipal.CarregaConfig;
begin
  writeln('Carregando configurações');
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    SQL.Text := 'SELECT * FROM ConfigPrograma';
    Open;
    writeln('Query aberto');
    if FieldByName('ExibirTelaBoasVindas').AsBoolean = True then
      ExibirBoasVindas := True
    else
      ExibirBoasVindas := False;
  finally
    Free;
  end;
end;

procedure TformPrincipal.DefinirStake;
var
  query: TSQLQuery;
begin
  with formPrincipal do
  begin
    query := TSQLQuery.Create(nil);
    query.DataBase := formPrincipal.conectBancoDados;
    try
      if not query.Active then query.Close;
      query.SQL.Text :=
        'UPDATE Banca SET "Stake" = :stake WHERE Mês = :mesSelec AND Ano = :anoSelec';
      PerfilDoInvestidor;
      query.ParamByName('stake').AsFloat := stakeAposta;
      query.ParamByName('mesSelec').AsInteger := mesSelecionado;
      query.ParamByName('anoSelec').AsInteger := anoSelecionado;
      query.ExecSQL;
      transactionBancoDados.CommitRetaining;
    except
      on E: Exception do
      begin
        writeln('Erro: ' + E.Message + ' Abortado');
        transactionBancoDados.RollbackRetaining;
      end;
    end;
    query.Free;
  end;
  if qrBanca.Active then qrBanca.Refresh
  else
    qrBanca.Open;
end;

{$R *.lfm}

{ TformPrincipal }

procedure TformPrincipal.FormCreate(Sender: TObject);
var
  TelaSplash: TformSplash;
  LocalPrograma: string;
begin
  {$IFDEF MSWINDOWS}
  LocalPrograma := ExtractFilePath(Application.ExeName);
  AssignFile(Output, LocalPrograma + 'debug.txt');
  //AssignFile(Output, 'debug.txt');
  Rewrite(Output);
  {$ENDIF}

  mesSelecionado := MonthOf(Now);
  anoSelecionado := YearOf(Now);

  Application.OnException := @ExcecaoGlobal;

  writeln('Exibindo tela splash');
  TelaSplash := TformSplash.Create(nil);
  TelaSplash.ShowModal;
  TelaSplash.Free;
  CarregaConfig;
end;

procedure TformPrincipal.dsBancaDataChange(Sender: TObject; Field: TField);
begin

end;

procedure TformPrincipal.FormActivate(Sender: TObject);
var
  BoasVindas: TformBoasVindas;
begin
  tsPainel.Show;
  if ExibirBoasVindas then
  begin
    BoasVindas := TformBoasVindas.Create(nil);
    BoasVindas.ShowModal;
    BoasVindas.Free;
  end;
end;

procedure TformPrincipal.FormResize(Sender: TObject);
const
  AspectRatio = 0.5;
var
  larguraTotal, alturaTotal, larguraObjeto, alturaObjeto, metadeLargura,
  larguraPizza, larguraLinhas, larguraGrafico, alturaGrafico: integer;
begin

  {*******************************PAINEL PRINCIPAL*******************************}

  //Gráficos
  larguraTotal := pnGraficos.ClientWidth;
  alturaTotal := pnGraficos.ClientHeight;
  metadeLargura := larguraTotal div 2;
  alturaObjeto := alturaTotal div 3;
  larguraPizza := alturaObjeto;
  larguraLinhas := larguraTotal - larguraPizza;
  chrtLucroMes.SetBounds(0, 0, larguraLinhas, alturaObjeto);
  chrtAcertMes.SetBounds(larguraLinhas, 0, larguraPizza, alturaObjeto);
  chrtLucroAno.SetBounds(0, larguraLinhas, larguraLinhas, alturaObjeto);
  chrtAcertAno.SetBounds(larguraLinhas, alturaObjeto, larguraPizza,
    alturaObjeto);
  chrtLucroTodosAnos.SetBounds(0, alturaObjeto * 2, larguraLinhas, alturaObjeto);
  chrtAcertTodosAnos.SetBounds(larguraLinhas, alturaObjeto * 2, larguraPizza,
    alturaObjeto);

  //Tabelas
  larguraTotal := pnTabelas.ClientWidth;
  alturaTotal := pnTabelas.ClientHeight;
  larguraObjeto := larguraTotal div 2;
  grdMes.SetBounds(0, 0, larguraObjeto, alturaTotal);
  grdAno.SetBounds(larguraObjeto, 0, larguraObjeto, alturaTotal);

  {******************************************************************************}

  {******************************CONTROLE DE MÉTODOS*****************************}

  //Largura e altura total da aba
  larguraTotal := tsGraficosMesMetodos.ClientWidth;
  alturaTotal := tsGraficosMesMetodos.ClientHeight;
  alturaObjeto := alturaTotal div 2;


  //Proporções das listas de método e linha da aba de gráficos
  larguraObjeto := gbListaMetodo.Width;
  gbListaMetodo.SetBounds(0, 0, larguraObjeto, alturaObjeto);
  gbListaLinha.SetBounds(0, alturaObjeto, larguraObjeto, alturaObjeto);

  //proporção dos gráficos
  larguraObjeto := larguraTotal div 3;
  larguraGrafico := pnGraficosMetodos.ClientWidth div 2;
  alturaGrafico := pnGraficosMetodos.ClientHeight div 2;
  chrtLucroMetodo.SetBounds(0, 0, larguraGrafico, alturaGrafico);
  chrtAcertMetodo.SetBounds(larguraGrafico, 0, larguraGrafico, alturaGrafico);
  chrtLucroLinha.SetBounds(0, alturaGrafico, larguraGrafico, alturaGrafico);
  chrtAcertLinha.SetBounds(larguraGrafico, alturaGrafico, larguraGrafico,
    alturaGrafico);

  //Proporção dos grids de método por PTC
  larguraTotal := tsDadosMesMetodos.ClientWidth;
  alturaTotal := tsDadosMesMetodos.ClientHeight;

  larguraObjeto := larguraTotal div 2;
  alturaObjeto := alturaTotal div 3;

  grbMetPais.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
  grbMetTime.SetBounds(larguraObjeto, alturaObjeto, larguraObjeto, alturaObjeto);
  grbMetComp.SetBounds(larguraObjeto, alturaObjeto * 2, larguraObjeto, alturaObjeto);

  //Grids dos métodos/linhas

  larguraTotal := tsDadosMesMetodos.ClientWidth;
  alturaTotal := tsDadosMesMetodos.ClientHeight;

  alturaObjeto := alturaTotal div 2;

  grbMetodos.SetBounds(0, 0, larguraObjeto, alturaObjeto);
  grbLinhas.SetBounds(0, alturaObjeto, larguraObjeto, alturaObjeto);

  {******************************************************************************}

  {*******************************CONTROLE DE TIMES******************************}
  larguraTotal := tsContrTimes.ClientWidth;
  alturaTotal := tsContrTimes.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto := trunc(alturaTotal * AspectRatio);

  grbTimes.SetBounds(0, 0, larguraObjeto, alturaTotal);
  chrtAcertTime.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
  chrtLucratTime.SetBounds(larguraObjeto, alturaObjeto, larguraObjeto,
    alturaObjeto);
  grbTimesMaisLucr.SetBounds((larguraObjeto * 2), 0, larguraObjeto,
    alturaObjeto);
  grbTimesMenosLucr.SetBounds((larguraObjeto * 2), alturaObjeto, larguraObjeto,
    alturaObjeto);

  {******************************************************************************}

  {*******************************CONTROLE DE PAÍSES*****************************}
  larguraTotal := tsContrPaises.ClientWidth;
  alturaTotal := tsContrPaises.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto := trunc(alturaTotal * AspectRatio);

  grbPaises.SetBounds(0, 0, larguraObjeto, alturaTotal);
  chrtAcertPais.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
  chrtLucratPais.SetBounds(larguraObjeto, alturaObjeto, larguraObjeto,
    alturaObjeto);
  grbPaisesMaisAcert.SetBounds(larguraObjeto * 2, 0, larguraObjeto,
    alturaObjeto);
  grbPaisesMenosAcert.SetBounds(larguraObjeto * 2, alturaObjeto, larguraObjeto,
    alturaObjeto);

  {****************************CONTROLE DE COMPETIçÕES***************************}
  larguraTotal := tsContrComp.ClientWidth;
  alturaTotal := tsContrComp.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto := trunc(alturaTotal * AspectRatio);

  grbComp.SetBounds(0, 0, larguraObjeto, alturaTotal);
  chrtAcertComp.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
  chrtLucratComp.SetBounds(larguraObjeto, alturaObjeto, larguraObjeto,
    alturaObjeto);
  grbCompMaisLucr.SetBounds((larguraObjeto * 2), 0, larguraObjeto, alturaObjeto);
  grbCompMenosLucr.SetBounds((larguraObjeto * 2), alturaObjeto, larguraObjeto,
    alturaObjeto);

  {******************************************************************************}

end;

procedure TformPrincipal.AtualizaMetodoLinha(Sender: TObject);
var
  SelectedItem: TMenuItem;
begin
  SelectedItem := TMenuItem(Sender);
  if Assigned(ColunaAtual) and Assigned(SelectedItem) then
  begin
    qrDadosAposta.Edit;
    qrDadosAposta.FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
    writeln('Item selecionado: ', SelectedItem.Caption);
    qrDadosAposta.Post;
    qrDadosAposta.ApplyUpdates;
    qrDadosAPosta.Refresh;
    CalculaDadosAposta;
  end;
end;

procedure TformPrincipal.grdApostasEditingDone(Sender: TObject);
begin
  if (qrApostas.State in [dsInsert, dsEdit]) then
  begin
    try
      writeln('Postando');
      qrApostas.Post;
      writeln('Aplicando');
      qrApostas.ApplyUpdates;
      writeln('Salvando');
      transactionBancoDados.CommitRetaining;
      CalculaDadosAposta;
    except
      on E: Exception do
        writeln('Erro: ' + E.Message);
    end;
  end;
end;

procedure TformPrincipal.MudarCorLucro;
var
  lucro: double;
begin
  lucro := qrBanca.FieldByName('Lucro').AsFloat;

  if lucro > 0 then
  begin
    txtBancaAtual.Font.Color := clGreen;
    txtLucroMoeda.Font.Color := clGreen;
    txtLucroPorcento.Font.Color := clGreen;
  end
  else if lucro < 0 then
  begin
    txtBancaAtual.Font.Color := clRed;
    txtLucroMoeda.Font.Color := clRed;
    txtLucroPorcento.Font.Color := clRed;
  end
  else
  begin
    txtBancaAtual.Font.Color := clDefault;
    txtLucroMoeda.Font.Color := clDefault;
    txtLucroPorcento.Font.Color := clDefault;
  end;
end;

procedure TformPrincipal.PerfilDoInvestidor;
begin
  if perfilInvestidor = 'Conservador' then
  begin
    if GestaoUnidade then
      stakeAposta := RoundTo(valorInicial / 100, -2)
    else
      stakeAposta := RoundTo(1 * valorInicial / 100, -2);
  end
  else
  if perfilInvestidor = 'Moderado' then
  begin
    if GestaoUnidade then
      stakeAposta := RoundTo(valorInicial / 70, -2)
    else
      stakeAposta := RoundTo(3 * valorInicial / 100, -2);
  end
  else
  if perfilInvestidor = 'Agressivo' then
  begin
    if GestaoUnidade then
      stakeAposta := RoundTo(valorInicial / 40, -2)
    else
      stakeAposta := RoundTo(5 * valorInicial / 100, -2);
  end;
end;

procedure TformPrincipal.ExcecaoGlobal(Sender: TObject; E: Exception);
begin
  writeln('Erro: ' + E.Message);
  Application.ProcessMessages;
  Application.ProcessMessages;
end;


procedure TformPrincipal.SalvarDadosBD(Sender: TObject);
var
  formSalvarDados: TformSalvarDados;
begin
  formSalvarDados := TformSalvarDados.Create(nil);
  formSalvarDados.ShowModal;
  formSalvarDados.Free;
end;


procedure TformPrincipal.ImportarDadosBD(Sender: TObject);
var
  Script: TStringList;
  i: integer;
begin
  Script := TStringList.Create;
  try
    with TOpenDialog.Create(nil) do
    try
      Filter :=
        'Todos os Arquivos Suportados (*.sql, *.csv) | *.sql; *.csv | ' +
        'Arquivo SQL (*.sql)|*.sql| Arquivo CSV (*.csv)|*.csv| ' +
        'Todos os Arquivos (*.*)|*.*';
      DefaultExt := 'sql; csv';
      if Execute then
      begin
        Script.LoadFromFile(FileName);

        with TSQLQuery.Create(nil) do
        try
          try
            DataBase := conectBancoDados;

            for i := 0 to Script.Count - 1 do
            begin
              SQL.Text := Script[i];
              ExecSQL;
            end;
            transactionBancoDados.CommitRetaining;
            ReiniciarTodosOsQueries;
            if not qrApostas.IsEmpty then grdApostas.Enabled := True;
            ShowMessage('Dados importados com sucesso!');
          except
            On E: Exception do
            begin
              Cancel;
              transactionBancoDados.RollbackRetaining;
              raise Exception.Create(E.Message + sLineBreak +
                sLineBreak + 'Linha SQL: ' + sLineBreak + SQL.Text);
            end;
          end;
        finally
          Free;
        end;
      end;
    finally
      Free;
      Script.Free;
    end;
  except
    On E: Exception do
    begin
      MessageDlg('Erro', 'Ocorreu um erro ao importar os dados: ' + E.Message,
        mtError, [mbOK], 0);
    end;
  end;
end;

procedure TformPrincipal.GestaoUnidadePcent(Sender: TObject);
begin
  with TSQLQuery.Create(nil) do
  try
    DataBase := conectBancoDados;
    if (Sender = rbGestPcent) then
    begin
      SQL.Text := 'UPDATE "Selecionar Perfil" SET GestaoPcent = 1';
      GestaoUnidade := False;
      ExecSQL;
      writeln('Gestão como porcentagem!');
    end;
    if (Sender = rbGestUn) then
    begin
      SQL.Text := 'UPDATE "Selecionar Perfil" SET GestaoPcent = 0';
      GestaoUnidade := True;
      ExecSQL;
      writeln('Gestão como unidade!');
    end;
    transactionBancoDados.CommitRetaining;
  finally
    Free;
  end;
  DefinirStake;
end;

procedure TformPrincipal.ReiniciarTodosOsQueries;
var
  qrPraReiniciar: TList;
  I: integer;
  EventosMetodos: TEventosMetodos;
begin
  qrPraReiniciar := TList.Create;
  try
    qrPraReiniciar.Add(qrApostas);
    qrPraReiniciar.Add(qrBanca);
    qrPraReiniciar.Add(qrSituacao);
    qrPraReiniciar.Add(qrUnidades);
    qrPraReiniciar.Add(qrPerfis);
    qrPraReiniciar.Add(qrSelecionarPerfil);
    qrPraReiniciar.Add(qrMes);
    qrPraReiniciar.Add(qrAno);
    qrPraReiniciar.Add(qrMesesGreenRed);
    qrPraReiniciar.Add(qrMetodosMes);
    qrPraReiniciar.Add(qrTimes);
    qrPraReiniciar.Add(qrTimesMaisAcert);
    qrPraReiniciar.Add(qrTimesMenosAcert);
    qrPraReiniciar.Add(qrComp);
    qrPraReiniciar.Add(qrCompMaisAcert);
    qrPraReiniciar.Add(qrCompMenosAcert);
    qrPraReiniciar.Add(qrMP);
    qrPraReiniciar.Add(qrMT);
    qrPraReiniciar.Add(qrMC);

    //qrApostas.ParamByName('mesSelecionado').AsInteger := MonthOf(Now);
    //qrApostas.ParamByName('anoSelecionado').AsInteger := YearOf(Now);

    for I := 0 to qrPraReiniciar.Count - 1 do
    try
      if TSQLQuery(qrPraReiniciar[I]).Active then
        TSQLQuery(qrPraReiniciar[I]).Refresh;
    except
      On E: Exception do
      writeln('Erro ao reiniciar o query ',TComponent(qrPraReiniciar[I]).Name,
      ', ' + E.Message);
    end;
    EventosMetodos.CarregaMetodos;
  finally
    qrPraReiniciar.Free;
  end;
end;

procedure TformPrincipal.grdDadosApCellClick(Column: TColumn);
var
  P: TPoint;
  Query: TSQLQuery;
  Item: TMenuItem;
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
        Item.OnClick := @AtualizaMetodoLinha;
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
        qrDadosAposta.FieldByName('Método').AsString;
      Query.Open;
      while not Query.EOF do
      begin
        Item := TMenuItem.Create(popupLinhas);
        Item.Caption := Query.FieldByName('Nome').AsString;
        Item.OnClick := @AtualizaMetodoLinha;
        popupLinhas.Items.Add(Item);
        Query.Next;
      end;
    end;
    'Status':
    begin
      popupLinhas.Items.Clear;
      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Pré-live';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Green';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Red';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Anulada';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Green';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);

      Item := TMenuItem.Create(popupLinhas);
      Item.Caption := 'Meio Red';
      Item.OnClick := @AtualizaMetodoLinha;
      popupLinhas.Items.Add(Item);
    end;
  end;

  P := Mouse.CursorPos;
  popupLinhas.PopUp(P.X, P.Y);
  Screen.Cursor := crDefault;
  Query.Free;
  qrDadosAposta.Edit;
end;

procedure TformPrincipal.grdDadosApEditingDone(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  with qrDadosAposta do
  begin
    Edit;
    Post;
    ApplyUpdates;
    transactionBancoDados.CommitRetaining;
    CalculaDadosAposta;
  end;
end;

procedure TformPrincipal.MenuItem7Click(Sender: TObject);
begin
  formSobre.ShowModal;
end;

procedure TformPrincipal.MenuItem8Click(Sender: TObject);
begin
  openurl('https://link.mercadopago.com.br/graxaimgestaodebanca');
end;

procedure TformPrincipal.miExibirBoasVindasClick(Sender: TObject);
begin
  BoasVindas := TformBoasVindas.Create(nil);
  BoasVindas.ShowModal;
  BoasVindas.Free;
end;

procedure TformPrincipal.qrApostasAfterOpen(DataSet: TDataSet);
begin
  qrApostas.Last;
end;

procedure TformPrincipal.qrApostasAfterRefresh(DataSet: TDataSet);
begin
  qrApostas.Last;
end;

procedure TformPrincipal.qrApostasBeforeRefresh(DataSet: TDataSet);
begin
  conectBancoDados.ExecuteDirect('UPDATE Apostas SET Status = Status');
end;

procedure TformPrincipal.PosAtualizacao;
var
  NaoExcluir: TStringList;
  programAtualizado: boolean = False;
  SourceFile, DestFile: string;
begin
  if not JaAtualizado then
  begin
    NaoExcluir := TStringList.Create;
    try
      {$IFDEF MSWINDOWS}
      writeln('Sistema Windows detectado!');
      NaoExcluir.SaveToFile('%APPDATA%\GraxaimBanca\NaoExcluir');
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
end;

initialization

end.
