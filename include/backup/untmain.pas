unit untMain;

{$mode objfpc}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, BufDataset, fpcsvexport, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, DBGrids, DBCtrls, Menus, ActnList, Buttons,
  ExtCtrls, JSONPropStorage, EditBtn, TAGraph, TARadialSeries,
  TASeries, TADbSource, TACustomSeries, TAMultiSeries, DateUtils, Math,
  FileUtil, HTTPDefs, untSalvarDados;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    btnCashout: TBitBtn;
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
    btnSalvarAnotacao: TButton;
    btnSalvarBancaInicial: TButton;
    btnTudoGreen: TButton;
    btnTudoRed: TButton;
    btnNovaComp: TButton;
    bufExportar: TBufDataset;
    btnEditAposta: TButton;
    btnAporte: TButton;
    btnRetirar: TButton;
    cbAno:     TComboBox;
    cbGraficos: TComboBox;
    cbMes:     TComboBox;
    cbPerfil:  TComboBox;
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
    chbGestaoVariavel: TDBCheckBox;
    dsConfig:  TDataSource;
    dsMP:      TDataSource;
    dsMT:      TDataSource;
    dsMC:      TDataSource;
    grbLinha:  TGroupBox;
    grbMetComp: TGroupBox;
    grbMetodo: TGroupBox;
    grbMetPais: TGroupBox;
    grbMetTime: TGroupBox;
    grdLinhasMes: TDBGrid;
    grdMC:     TDBGrid;
    grdMetodosMes: TDBGrid;
    ExportarDados: TCSVExporter;
    dsComp:    TDataSource;
    dsCompMenosAcert: TDataSource;
    dsCompMaisAcert: TDataSource;
    dsPaisesMenosAcert: TDataSource;
    dsPaisesMaisAcert: TDataSource;
    dsPais:    TDataSource;
    dsTimesMenosAcert: TDataSource;
    dsTimesMaisAcert: TDataSource;
    dsTimes:   TDataSource;
    dsAno:     TDataSource;
    dsLinhasMes: TDataSource;
    dsLinhasAno: TDataSource;
    dsMetodosAno: TDataSource;
    dsMetodosMes: TDataSource;
    edtPesquisarTime: TEdit;
    edtPesquisarPais: TEdit;
    edtPesquisarComp: TEdit;
    gbListaLinha: TGroupBox;
    gbListaMetodo: TGroupBox;
    grbTimes:  TGroupBox;
    grbPaises: TGroupBox;
    grbComp:   TGroupBox;
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
    dsBanca:   TDataSource;
    dsCompeticoes: TDataSource;
    dsGraficoAno: TDataSource;
    dsGraficoMes: TDataSource;
    dsMes:     TDataSource;
    dsPerfis:  TDataSource;
    dsSelecionarPerfil: TDataSource;
    dsSituacao: TDataSource;
    dsUnidades: TDataSource;
    grbApostas: TGroupBox;
    grbDetalhesAp: TGroupBox;
    grdAno:    TDBGrid;
    grdApostas: TDBGrid;
    grdMes:    TDBGrid;
    grdMP:     TDBGrid;
    grdMT:     TDBGrid;
    grdTimes:  TDBGrid;
    grdPaises: TDBGrid;
    grdComp:   TDBGrid;
    grdPaisesMaisAcert: TDBGrid;
    grdCompMaisLucr: TDBGrid;
    grdTimesMenosAcert: TDBGrid;
    grdTimesMaisAcert: TDBGrid;
    grdPaisesMenosAcert: TDBGrid;
    grdCompMenosLucr: TDBGrid;
    grbMetodos: TGroupBox;
    grbLinhas: TGroupBox;
    grbAnotacoes: TGroupBox;
    JSONPropStorage1: TJSONPropStorage;
    lbLucroPcent: TLabel;
    lbLucroDinheiro: TLabel;
    lbBancaFinal: TLabel;
    lbValAporte: TLabel;
    lbValBancaTotal: TLabel;
    lbBancaTotal: TLabel;
    lbStake:   TLabel;
    lbValorBanca: TLabel;
    lbAcertosLin: TLabel;
    lbAcertosMet: TLabel;
    lbAporte:  TLabel;
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
    lbAno:     TLabel;
    lbBancaFinalTitulo: TLabel;
    lbBancaInicial: TLabel;
    lbLucro:   TLabel;
    lbMes:     TLabel;
    lbPerfil:  TLabel;
    lbUnidade: TLabel;
    lsbJogos:  TListBox;
    lnGraficoLucroAno: TLineSeries;
    lnGraficoLucroAno1: TLineSeries;
    lnGraficoLucroMes: TLineSeries;
    lsbLinhas: TListBox;
    lsbMetodos: TListBox;
    miConfig:  TMenuItem;
    mmAnotAposta: TMemo;
    miExibirBoasVindas: TMenuItem;
    MenuPrincipal: TMainMenu;
    MenuOpcoes: TMenuItem;
    MenuAjuda: TMenuItem;
    miImportar: TMenuItem;
    miExportar: TMenuItem;
    miComoUsar: TMenuItem;
    miSobre:   TMenuItem;
    miApoie:   TMenuItem;
    pcMesMetodos: TPageControl;
    pcPrincipal: TPageControl;
    pcResumo:  TPageControl;
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
    qrAno:     TSQLQuery;
    qrAnoAno:  TLargeintField;
    qrAnoLucroAnualReais: TFloatField;
    qrAnoLucroTotalPorCento: TFloatField;
    qrAnoMesGreen: TLargeintField;
    qrAnoMesRed: TLargeintField;
    qrAnoMs:   TLargeintField;
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
    qrBanca:   TSQLQuery;
    qrBancaAno1: TLongintField;
    qrBancaInicialMoedaStake1: TStringField;
    qrBancaLucroPrCntCalculado1: TStringField;
    qrBancaLucroRSCalculado1: TStringField;
    qrBancaLucro_1: TBCDField;
    qrBancaLucro_R1: TBCDField;
    qrBancaMs1: TLongintField;
    qrBancaStake1: TBCDField;
    qrBancaValorCalculado1: TStringField;
    qrBancaValorFinalCalculado1: TStringField;
    qrBancaValor_Final1: TBCDField;
    qrBancaValor_Inicial1: TBCDField;
    qrConfigExibirTelaBoasVindas: TBooleanField;
    qrConfigGestaoPcent: TBooleanField;
    qrConfigGestaoVariavel: TBooleanField;
    qrConfigPreRelease: TBooleanField;
    qrDadosApostaAnotacoes: TStringField;
    qrDadosApostaCod_Aposta: TLargeintField;
    qrDadosApostaCompetio: TStringField;
    qrDadosApostaJogo: TStringField;
    qrDadosApostaLinha: TStringField;
    qrDadosApostaMtodo: TStringField;
    qrDadosApostaOdd: TBCDField;
    qrDadosApostaROWID: TLargeintField;
    qrDadosApostaStatus: TStringField;
    qrLinhasAno: TSQLQuery;
    qrMes:     TSQLQuery;
    qrMesDia:  TStringField;
    qrMesesGreenRed: TSQLQuery;
    qrMesGreen: TLargeintField;
    qrMesNeutro: TLargeintField;
    qrMesNumGreen: TLargeintField;
    qrMesNumRed: TLargeintField;
    qrMesPorCentoLucro: TFloatField;
    qrMesRed:  TLargeintField;
    qrMesSomaLucro: TFloatField;
    qrMetodosAno: TSQLQuery;
    qrMetodosMesCod_Metodo1: TLargeintField;
    qrMetodosMesGreens1: TLargeintField;
    qrMetodosMesMtodo1: TStringField;
    qrMetodosMesPcentAcertos1: TFloatField;
    qrMetodosMesReds1: TLargeintField;
    qrMetodosMesTotalApostas1: TLargeintField;
    qrPerfis:  TSQLQuery;
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
    rbGestUn:  TRadioButton;
    scriptRemoverAposta: TSQLScript;
    qrDadosAposta: TSQLQuery;
    qrMetodosMes: TSQLQuery;
    qrLinhasMes: TSQLQuery;
    scriptSalvarDados: TSQLScript;
    btnPesquisarTime: TSpeedButton;
    qrTimes:   TSQLQuery;
    qrTimesMaisAcert: TSQLQuery;
    qrTimesMenosAcert: TSQLQuery;
    qrPais:    TSQLQuery;
    qrPaisesMaisAcert: TSQLQuery;
    qrPaisesMenosAcert: TSQLQuery;
    qrComp:    TSQLQuery;
    qrCompMaisAcert: TSQLQuery;
    qrCompMenosAcert: TSQLQuery;
    qrMP:      TSQLQuery;
    qrMT:      TSQLQuery;
    qrMC:      TSQLQuery;
    BarraStatus: TStatusBar;
    qrConfig:  TSQLQuery;
    qrLucroAno: TSQLQuery;
    qrTodosAnos: TSQLQuery;
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
    tsPainel:  TTabSheet;
    tsResumoLista: TTabSheet;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure qrApostasBeforeRefresh(DataSet: TDataSet);
    procedure ReiniciarTodosOsQueries;
    procedure MudarCorLucro;
    procedure PerfilDoInvestidor;
    procedure SalvarDadosBD(Sender: TObject);
    procedure ImportarDadosBD;
    procedure GestaoUnidadePcent(Sender: TObject);
    procedure ItemMenu(Sender: TObject);
  private

  public
    GestaoVariavel: boolean;
    GestaoUnidade:  boolean;
    procedure PosAtualizacao;
    procedure ExcecaoGlobal(Sender: TObject; E: Exception);
    procedure CarregaConfig;
  end;

var
  ColunaAtual: TColumn;
  Arquivo: TFileStream;
  Linha: string;
  ExibirBoasVindas, PreRelease: boolean;

var
  formPrincipal: TformPrincipal;
  estrategia, perfilInvestidor: string;
  stakeAposta, valorInicial, Aporte: double;
  contMult:      integer;
  mesSelecionado: integer;
  anoSelecionado: integer;
  GestaoPcent:   boolean;

implementation

uses
  untUpdate, untApostas, untSplash, untDatabase, untSobre, untControleMetodos,
  fpjson, jsonparser, LCLIntf, untBoasVindas, untConfig;

procedure TformPrincipal.CarregaConfig;
begin
  writeln('Carregando configurações');
  GestaoVariavel   := False;
  GestaoUnidade    := True;
  ExibirBoasVindas := True;
  with qrConfig do
  try
    if not Active then Open;
    if not IsEmpty then begin
      GestaoVariavel   := FieldByName('GestaoVariavel').AsBoolean;
      GestaoUnidade    := not Fields[3].AsBoolean;
      ExibirBoasVindas := FieldByName('ExibirTelaBoasVindas').AsBoolean;
    end;
  except
    Exit;
  end;
end;

{$R *.lfm}

{ TformPrincipal }

procedure TformPrincipal.FormCreate(Sender: TObject);
var
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
  try
    formSplash := TformSplash.Create(nil);
    formSplash.ShowModal;
  finally
    formSplash.Free;
  end;
end;

procedure TformPrincipal.FormActivate(Sender: TObject);
begin
  tsPainel.Show;
  if ExibirBoasVindas then
    formBoasVindas.ShowModal;
end;

procedure TformPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  with transactionBancoDados do
    if Active then Commit;
end;

procedure TformPrincipal.FormResize(Sender: TObject);
const
  AspectRatio = 0.5;
var
  larguraTotal, alturaTotal, larguraObjeto, alturaObjeto, metadeLargura,
  larguraPizza, larguraLinhas, larguraGrafico, alturaGrafico,
  larguraGridDados, larguraAnotacoes: integer;
begin

{*******************************PAINEL PRINCIPAL*******************************}

  //Gráficos
  larguraTotal  := pnGraficos.ClientWidth;
  alturaTotal   := pnGraficos.ClientHeight;
  metadeLargura := larguraTotal div 2;
  alturaObjeto  := alturaTotal div 3;
  larguraPizza  := alturaObjeto;
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
  larguraTotal  := pnTabelas.ClientWidth;
  alturaTotal   := pnTabelas.ClientHeight;
  larguraObjeto := larguraTotal div 2;
  grdMes.SetBounds(0, 0, larguraObjeto, alturaTotal);
  grdAno.SetBounds(larguraObjeto, 0, larguraObjeto, alturaTotal);

{******************************************************************************}

{*******************************DADOS DAS APOSTAS******************************}

  larguraTotal     := lbSelecioneAposta.ClientWidth;
  alturaTotal      := lbSelecioneAposta.ClientHeight;
  larguraObjeto    := larguraTotal div 3;
  larguraGridDados := larguraObjeto + (larguraObjeto div 8);
  larguraAnotacoes := larguraObjeto - (larguraObjeto div 8);

  lsbJogos.SetBounds(0, 0, larguraObjeto, alturaTotal);
  grdDadosAp.SetBounds(larguraObjeto, 0, larguraGridDados, alturaTotal);
  grbAnotacoes.SetBounds(larguraObjeto + larguraGridDados, 0, larguraAnotacoes,
    alturaObjeto);


{******************************************************************************}

{******************************CONTROLE DE MÉTODOS*****************************}

  //Largura e altura total da aba
  larguraTotal  := tsGraficosMesMetodos.ClientWidth;
  alturaTotal   := tsGraficosMesMetodos.ClientHeight;
  larguraObjeto := larguraTotal div 2;
  alturaObjeto  := alturaTotal div 2;


  //Proporções das listas de método e linha da aba de gráficos
  larguraObjeto := gbListaMetodo.Width;
  gbListaMetodo.SetBounds(0, 0, larguraObjeto, alturaObjeto);
  gbListaLinha.SetBounds(0, alturaObjeto, larguraObjeto, alturaObjeto);

  //proporção dos gráficos
  larguraObjeto  := larguraTotal div 3;
  larguraGrafico := pnGraficosMetodos.ClientWidth div 2;
  alturaGrafico  := pnGraficosMetodos.ClientHeight div 2;
  chrtLucroMetodo.SetBounds(0, 0, larguraGrafico, alturaGrafico);
  chrtAcertMetodo.SetBounds(larguraGrafico, 0, larguraGrafico, alturaGrafico);
  chrtLucroLinha.SetBounds(0, alturaGrafico, larguraGrafico, alturaGrafico);
  chrtAcertLinha.SetBounds(larguraGrafico, alturaGrafico, larguraGrafico,
    alturaGrafico);

  //Proporção dos grids de método por PTC
  larguraTotal := tsDadosMesMetodos.ClientWidth;
  alturaTotal  := tsDadosMesMetodos.ClientHeight;

  larguraObjeto := larguraTotal div 2;
  alturaObjeto  := alturaTotal div 3;

  grbMetPais.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
  grbMetTime.SetBounds(larguraObjeto, alturaObjeto, larguraObjeto, alturaObjeto);
  grbMetComp.SetBounds(larguraObjeto, alturaObjeto * 2, larguraObjeto, alturaObjeto);

  //Grids dos métodos/linhas

  larguraTotal := tsDadosMesMetodos.ClientWidth;
  alturaTotal  := tsDadosMesMetodos.ClientHeight;

  alturaObjeto := alturaTotal div 2;

  grbMetodos.SetBounds(0, 0, larguraObjeto, alturaObjeto);
  grbLinhas.SetBounds(0, alturaObjeto, larguraObjeto, alturaObjeto);

{******************************************************************************}

{*******************************CONTROLE DE TIMES******************************}
  larguraTotal := tsContrTimes.ClientWidth;
  alturaTotal  := tsContrTimes.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto  := trunc(alturaTotal * AspectRatio);

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
  alturaTotal  := tsContrPaises.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto  := trunc(alturaTotal * AspectRatio);

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
  alturaTotal  := tsContrComp.ClientHeight;

  larguraObjeto := larguraTotal div 3;
  alturaObjeto  := trunc(alturaTotal * AspectRatio);

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
    with qrDadosAposta do
    begin
      Edit;
      FieldByName(ColunaAtual.FieldName).AsString := SelectedItem.Caption;
      writeln('Item selecionado: ', SelectedItem.Caption);
      Post;
      ApplyUpdates;
      CalculaDadosAposta;
    end;
end;

procedure TformPrincipal.MudarCorLucro;
var
  lucro: double;
begin
  lucro := qrBanca.FieldByName('LucroR$').AsFloat;

  if lucro > 0 then
  begin
    lbBancaFinal.Font.Color    := clGreen;
    lbLucroDinheiro.Font.Color := clGreen;
    lbLucroPcent.Font.Color    := clGreen;
  end
  else if lucro < 0 then
  begin
    lbBancaFinal.Font.Color    := clRed;
    lbLucroDinheiro.Font.Color := clRed;
    lbLucroPcent.Font.Color    := clRed;
  end
  else
  begin
    lbBancaFinal.Font.Color    := clDefault;
    lbLucroDinheiro.Font.Color := clDefault;
    lbLucroPcent.Font.Color    := clDefault;
  end;
end;

procedure TformPrincipal.PerfilDoInvestidor;
var
  Banca: double;
  Campo: TField;
begin
  writeln('Definindo perfil do investidor');
  with formPrincipal do
  begin
    with qrBanca do
    try
      Banca := 0;
      if not Active then Open;
      if not IsEmpty then
        if not GestaoVariavel then
          Campo := FieldByName('BancaTotal')
        else
        begin
          Campo := FieldByName('Valor_Final');
          if not Campo.IsNull and (Trim(Campo.AsString) <> '') then
            Banca := Campo.AsFloat
          else
            Banca := 0;
        end;
    except
      Banca := 0;
    end;

    case perfilInvestidor of
      'Conservador':
        stakeAposta := RoundTo(Banca / 100, -2);
      'Moderado':
        if GestaoUnidade then
          stakeAposta := RoundTo(Banca / 70, -2)
        else
          stakeAposta := RoundTo(3 * Banca / 100, -2);
      'Agressivo':
        if GestaoUnidade then
          stakeAposta := RoundTo(Banca / 40, -2)
        else
          stakeAposta := RoundTo(5 * Banca / 100, -2);
    end;
    qrBanca.Refresh;
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

procedure TformPrincipal.ImportarDadosBD;
var
  Script: TStringList;
  i:      integer;
begin
  Script := TStringList.Create;
  try
    with TOpenDialog.Create(nil) do
    try
      Filter     :=
        'Todos os Arquivos Suportados (*.sql, *.csv) | *.sql; *.csv | ' +
        'Arquivo SQL (*.sql)|*.sql| Arquivo CSV (*.csv)|*.csv| ' +
        'Todos os Arquivos (*.*)|*.*';
      DefaultExt := 'sql; csv';
      if Execute then
      begin
        Script.LoadFromFile(FileName);

        with TSQLQuery.Create(nil) do
        begin
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
  writeln('Alternando gestão entre unidade e porcentagem');
  with transactionBancoDados do
    with qrConfig do
    try
      if not Active then Open;
      if not IsEmpty then
      begin
        Edit;
        Fields[3].AsBoolean := rbGestPcent.Checked;
        Post;
        ApplyUpdates;
        CommitRetaining;
        CarregaConfig;
      end;
    except
      on E: Exception do
      begin
        Cancel;
        RollbackRetaining;
        writeln('Erro ao definir gestão entre unidade e porcentagem: ' + E.Message);
      end;
    end;
  PerfilDoInvestidor;
end;

procedure TformPrincipal.ItemMenu(Sender: TObject);
var
  Item: TMenuItem;
begin
  Item := TMenuItem(Sender);
  case Item.Name of
    'miExibirBoasVindas': formBoasVindas.ShowModal;
    'miImportar': ImportarDadosBD;
    'miExportar': formSalvarDados.ShowModal;
    'miConfig': FormConfig.ShowModal;
    'miApoie': openurl('https://link.mercadopago.com.br/graxaimgestaodebanca');
    'miSobre': formSobre.ShowModal;
  end;
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
        writeln('Erro ao reiniciar o query ', TComponent(qrPraReiniciar[I]).Name,
          ', ' + E.Message);
    end;
    EventosMetodos.CarregaMetodos;
  finally
    qrPraReiniciar.Free;
  end;
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
