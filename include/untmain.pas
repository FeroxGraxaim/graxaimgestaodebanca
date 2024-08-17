unit untMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  DBExtCtrls, Menus, ActnList, CheckLst, Buttons, ExtCtrls, JSONPropStorage,
  EditBtn, TASources, TAGraph, TARadialSeries, Types, TASeries, TACustomSource,
  TADbSource, TACustomSeries, TAChartLiveView, TAChartCombos, TAMultiSeries,
  DateUtils, Math, Grids, ValEdit, TAChartAxisUtils, FileUtil, HTTPDefs;

type

  { TformPrincipal }

  TformPrincipal = class(TForm)
    btnExcluirLinha: TButton;
    btnExcluirLinha1: TButton;
    btnExcluirMetodo1: TButton;
    btnLimparFiltroAp: TButton;
    btnFiltrarAp: TButton;
    btnNovaAposta: TButton;
    btnExcluirMetodo: TButton;
    btnNovaLinha: TButton;
    btnNovaLinha1: TButton;
    btnNovoMetodo1: TButton;
    btnRemoverAposta: TButton;
    btnSalvarBancaInicial: TButton;
    btnTudoGreen: TButton;
    btnTudoRed: TButton;
    btnCashout: TButton;
    btnNovoMetodo: TButton;
    cbAno: TComboBox;
    cbGraficos: TComboBox;
    cbMes: TComboBox;
    cbPerfil: TComboBox;
    chrtAcertAno: TChart;
    chrtAcertLinha: TChart;
    chrtAcertLinha1: TChart;
    chrtAcertMes: TChart;
    chrtAcertMetodo: TChart;
    chrtAcertMetodo1: TChart;
    chrtLucroAno: TChart;
    chrtLucroLinha: TChart;
    chrtLucroLinha1: TChart;
    chrtLucroMes: TChart;
    chrtLucroMetodo: TChart;
    chrtLucroMetodo1: TChart;
    conectBancoDados: TSQLite3Connection;
    dsLinhasMes: TDataSource;
    dsLinhasAno: TDataSource;
    dsMetodosAno: TDataSource;
    gbListaLinha1: TGroupBox;
    gbListaMetodo1: TGroupBox;
    grdLinhasAno: TDBGrid;
    grdMetodosMes: TDBGrid;
    grdLinhasMes: TDBGrid;
    dsMetodosMes: TDataSource;
    gbListaLinha: TGroupBox;
    gbListaMetodo: TGroupBox;
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
    gbTimes: TGroupBox;
    grbApostas: TGroupBox;
    grbDetalhesAp: TGroupBox;
    grdAno: TDBGrid;
    grdApostas: TDBGrid;
    grdMes: TDBGrid;
    grdMetodosAno: TDBGrid;
    JSONPropStorage1: TJSONPropStorage;
    lbDataFim: TLabel;
    lbDataInicio: TLabel;
    lbSelecioneAposta: TLabel;
    lbAno: TLabel;
    lbBancaAtual: TLabel;
    lbBancaInicial: TLabel;
    lbLucro: TLabel;
    lbMes: TLabel;
    lbPerfil: TLabel;
    lbUnidade: TLabel;
    lnGraficoLucroAno: TLineSeries;
    lnGraficoLucroMes: TLineSeries;
    lsbLinhas: TListBox;
    lsbLinhas1: TListBox;
    lsbMetodos: TListBox;
    lsbMetodos1: TListBox;
    lsbTimes: TDBListBox;
    MenuPrincipal: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    miImportar: TMenuItem;
    miExportar: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    pcAnoMetodos: TPageControl;
    pizzaLinha1: TPieSeries;
    pizzaMetodo3: TPieSeries;
    pizzaMetodo4: TPieSeries;
    pizzaMetodo5: TPieSeries;
    pnGraficosMetodos: TPanel;
    pcMesMetodos: TPageControl;
    PageControl3: TPageControl;
    pcMesAnoMetodos: TPageControl;
    pcPrincipal: TPageControl;
    pcResumo: TPageControl;
    pizzaLinha: TPieSeries;
    pizzaMetodo: TPieSeries;
    pizzaMetodo1: TPieSeries;
    pizzaMetodo2: TPieSeries;
    pnGraficos: TPanel;
    pnGraficosMetodos1: TPanel;
    pnTabelas: TPanel;
    popupLinhas: TPopupMenu;
    psGraficoGreensReds: TPieSeries;
    psGraficoGreensReds1: TPieSeries;
    qrAno: TSQLQuery;
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
    qrCompeticoes: TSQLQuery;
    qrLinhasAno: TSQLQuery;
    qrMes: TSQLQuery;
    qrMesesGreenRed: TSQLQuery;
    qrMetodosAno: TSQLQuery;
    qrMetodosMesCod_Metodo: TLargeintField;
    qrMetodosMesCod_Metodo1: TLargeintField;
    qrMetodosMesGreens: TLargeintField;
    qrMetodosMesGreens1: TLargeintField;
    qrMetodosMesMtodo: TStringField;
    qrMetodosMesMtodo1: TStringField;
    qrMetodosMesPcentAcertos: TFloatField;
    qrMetodosMesPcentAcertos1: TFloatField;
    qrMetodosMesReds: TLargeintField;
    qrMetodosMesReds1: TLargeintField;
    qrMetodosMesTotalApostas: TLargeintField;
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
    scriptRemoverAposta: TSQLScript;
    qrDadosAposta: TSQLQuery;
    qrMetodosMes: TSQLQuery;
    qrLinhasMes: TSQLQuery;
    scriptSalvarDados: TSQLScript;
    StatusBar1: TStatusBar;
    tsDadosAnoMetodos: TTabSheet;
    tsGraficosMesMetodos: TTabSheet;
    tsDadosMesMetodos: TTabSheet;
    tsAnoMetodos: TTabSheet;
    tsContrTimes: TTabSheet;
    tsContrPaises: TTabSheet;
    tsContrComp: TTabSheet;
    transactionBancoDAdos: TSQLTransaction;
    cloneMultipla, cloneInfoMult: TPanel;
    tsApostas: TTabSheet;
    tsControleMetodos: TTabSheet;
    tsGraficos: TTabSheet;
    tsGraficosAnoMetodos: TTabSheet;
    tsMesMetodos: TTabSheet;
    tsPainel: TTabSheet;
    tsResumoLista: TTabSheet;
    tsSelecTime: TTabSheet;
    txtBancaAtual: TDBText;
    txtLucroMoeda: TDBText;
    txtLucroPorCento: TDBText;
    txtStake: TDBText;
    procedure DrawGrid1Click(Sender: TObject);
    procedure dsBancaDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure AtualizaMetodoLinha(Sender: TObject);
    procedure CriaMultipla(Contador: integer);
    procedure grdApostasEditingDone(Sender: TObject);
    procedure grdDadosApCellClick(Column: TColumn);
    procedure grdDadosApEditingDone(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure miExportarClick(Sender: TObject);
    procedure miImportarClick(Sender: TObject);
    procedure pcPrincipalChange(Sender: TObject);
    procedure qrApostasAfterOpen(DataSet: TDataSet);
    procedure qrApostasAfterPost(DataSet: TDataSet);
    procedure qrApostasAfterRefresh(DataSet: TDataSet);
    procedure qrApostasBeforeRefresh(DataSet: TDataSet);
    procedure ReiniciarTodosOsQueries;
    procedure MudarCorLucro;
    procedure PerfilDoInvestidor;
    procedure tsApostasContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
    procedure tsGrafMetContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
    procedure SalvarDadosBD(Sender: TObject);
    procedure ImportarDadosBD(Sender: TObject);
  private

  public
    procedure PosAtualizacao;
    procedure ExportTable(const TableName: string);
  end;

var
  ColunaAtual: TColumn;
  Arquivo: TFileStream;
  Linha: string;

procedure DefinirStake;

var
  formPrincipal: TformPrincipal;
  estrategia, perfilInvestidor: string;
  stakeAposta, valorInicial: double;
  contMult: integer;
  mesSelecionado: integer;
  anoSelecionado: integer;

implementation

uses
  untUpdate, untApostas, untPainel, untSplash, untDatabase, untMultipla, untSobre,
  untControleMetodos, fpjson, fphttpclient, jsonparser, LCLIntf;

procedure DefinirStake;
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
      formPrincipal.PerfilDoInvestidor;
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
end;

{$R *.lfm}

{ TformPrincipal }

procedure TformPrincipal.FormCreate(Sender: TObject);
var
  TelaSplash: TformSplash;
begin
  {$IFDEF MSWINDOWS}
  AssignFile(Output, GetEnvironmentVariable('PROGRAMFILES') +
    '\Graxaim Gestão de Banca\debug.txt');
  //AssignFile(Output, 'debug.txt');
  Rewrite(Output);
  {$ENDIF}

  mesSelecionado := MonthOf(Now);
  anoSelecionado := YearOf(Now);

  writeln('Exibindo tela splash');
  TelaSplash := TformSplash.Create(nil);
  TelaSplash.ShowModal;
  TelaSplash.Free;
end;

procedure TformPrincipal.DrawGrid1Click(Sender: TObject);
begin

end;

procedure TformPrincipal.dsBancaDataChange(Sender: TObject; Field: TField);
begin

end;

procedure TformPrincipal.FormResize(Sender: TObject);
const
  AspectRatio = 0.5;
var
  larguraTotal, alturaTotal, larguraGrafico, alturaGrafico: integer;
  larguraObjeto, alturaObjeto: integer;
begin

  //Gráficos do painel principal

  larguraTotal := pnGraficos.ClientWidth;
  alturaTotal := pnGraficos.ClientHeight;

  larguraGrafico := larguraTotal div 2;
  alturaGrafico := trunc(alturaTotal * AspectRatio);
  chrtLucroMes.SetBounds(0, 0, larguraGrafico, alturaGrafico);
  chrtAcertMes.SetBounds(larguraGrafico, 0, larguraGrafico, alturaGrafico);
  chrtLucroAno.SetBounds(0, alturaGrafico, larguraGrafico, alturaGrafico);
  chrtAcertAno.SetBounds(larguraGrafico, alturaGrafico, larguraGrafico, alturaGrafico);

  //Gráficos de métodos/linhas

  larguraTotal := pnGraficosMetodos.ClientWidth;
  alturaTotal := pnGraficosMetodos.ClientHeight;

  if larguraTotal < 2 then
    larguraGrafico := larguraTotal
  else
    larguraGrafico := larguraTotal div 2;

  alturaGrafico := trunc(alturaTotal * AspectRatio);

  chrtLucroMetodo.SetBounds(0, 0, larguraGrafico, alturaGrafico);
  chrtAcertMetodo.SetBounds(larguraGrafico, 0, larguraGrafico, alturaGrafico);
  chrtLucroLinha.SetBounds(0, alturaGrafico, larguraGrafico, alturaGrafico);
  chrtAcertLinha.SetBounds(larguraGrafico, alturaGrafico, larguraGrafico, alturaGrafico);

  alturaTotal := tsGraficosMesMetodos.ClientHeight;
  larguraObjeto := gbListaMetodo.ClientWidth;
  alturaObjeto := trunc(alturaTotal * AspectRatio);

  gbListaMetodo.SetBounds(0, 0, gbListaMetodo.ClientWidth, alturaObjeto);
  gbListaLinha.SetBounds(0, alturaObjeto, larguraObjeto, alturaObjeto);

  //Grids dos métodos/linhas

  larguraTotal := tsDadosMesMetodos.ClientWidth;
  alturaTotal := tsDadosMesMetodos.ClientHeight;

  larguraObjeto := larguraTotal div 2;
  alturaObjeto := alturaTotal;

  grdMetodosMes.SetBounds(0, 0, larguraObjeto, alturaObjeto);
  grdLinhasMes.SetBounds(larguraObjeto, 0, larguraObjeto, alturaObjeto);
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
    transactionBancoDados.CommitRetaining;
    AtualizaQRApostas;
  end;
end;

procedure TformPrincipal.CriaMultipla(Contador: integer);
begin

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
    AtualizaQRApostas;
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
    stakeAposta := RoundTo(valorInicial / 100, -2)
  else
  if perfilInvestidor = 'Moderado' then
    stakeAposta := RoundTo(valorInicial / 70, -2)
  else
  if perfilInvestidor = 'Agressivo' then
    stakeAposta := RoundTo(valorInicial / 40, -2);
end;

procedure TformPrincipal.tsApostasContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: boolean);
begin

end;

procedure TformPrincipal.tsGrafMetContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: boolean);
begin

end;

procedure TformPrincipal.ExportTable(const TableName: string);
var
  i: integer;
  Linha: string;
begin
{  with TSQLQuery.Create(nil) do
  try
    DataBase := formPrincipal.conectBancoDados;
    SQL.Text := Format('SELECT * FROM %s', [TableName]);
    Open;

    Arquivo.Write(Pointer(Linha)^, Length(Linha) * SizeOf(char));

    First;
    while not EOF do
    begin
      Linha := Format('INSERT INTO %s (', [TableName]);
      i := 0;
      while i < FieldCount do
      begin
        if i > 0 then
          Linha := Linha + ',';
        Linha := Linha + '"' + StringReplace(Fields[i].AsString, '"',
          '""', [rfReplaceAll]) + '"';
        Linha := Linha + Format('%s', [Fields[i].FieldName]);
        Inc(i);
      end;
      Linha := Linha + ') VALUES (';

      i := 0;
      while i < FieldCount do
      begin
        if i > 0 then
          Linha := Linha + ',';
        Linha := Linha + '"' + StringReplace(Fields[i].AsString, '"',
          '""', [rfReplaceAll]) + '"';
        Inc(i);
      end;
      Linha := Linha + ');' + sLineBreak;
      Arquivo.Write(Pointer(Linha)^, Length(Linha) * SizeOf(char));
      Next;
    end;

    Arquivo.Write(Pointer(sLineBreak)^, Length(sLineBreak) * SizeOf(char));
    Free;
  except
    on E: Exception do
    begin
      Free;
      MessageDlg('Erro', 'Erro ao salvar arquivo, tente novamente. Se o problema ' +
        'persistir favor informar no GitHub com a seguinte mensagem: ' +
        sLineBreak + E.Message, mtError, [mbOK], 0);
    end;
  end;   }
end;


procedure TformPrincipal.SalvarDadosBD(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  i: integer;
begin
{  SaveDialog := TSaveDialog.Create(nil);
  Arquivo := nil;
  try
    SaveDialog.Filter := 'Arquivo SQL (*.sql)|*.sql';
    SaveDialog.DefaultExt := 'sql';
    if SaveDialog.Execute then
    begin
      Arquivo := TFileStream.Create(SaveDialog.FileName, fmCreate);

      ExportTable('Banca');
      ExportTable('Países');
      ExportTable('Times');
      ExportTable('Competicoes');
      ExportTable('Métodos');
      ExportTable('Linhas');
      ExportTable('Jogo');
      ExportTable('Mercados');

      writeln('Dados salvos com sucesso');
    end;
    SaveDialog.Free;
    Arquivo.Free;
  except
    on E: Exception do
    begin
      writeln('Erro: ' + E.Message);
      SaveDialog.Free;
      Arquivo.Free;
    end;
  end;  }
end;


procedure TformPrincipal.ImportarDadosBD(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  Arquivo: TFileStream;
  Texto: TStringList;
  Linha: string;
begin
  OpenDialog := TOpenDialog.Create(nil);
  Texto := TStringList.Create;
  try
    with TSQLQuery.Create(nil) do
    begin
      try
        DataBase := conectBancoDados;
        SQL.Text := 'DELETE FROM Jogo';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Mercados';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Apostas';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Times';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Competicoes';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Países';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Linhas';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Métodos';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        SQL.Text := 'DELETE FROM Banca';
        writeln('SQL: ', SQL.Text);
        ExecSQL;
        transactionBancoDados.CommitRetaining;
        Free;
      except
        on E: Exception do
          try
            writeln('Erro: ' + E.Message + 'SQL: ' + SQL.Text);
            Cancel;
            raise Exception.Create('Não foi possível excluir dados obsoletos.');
          finally
            Free;
          end;
      end;
    end;
    OpenDialog.Filter := 'Arquivo SQL (*.sql)|*.sql';
    OpenDialog.DefaultExt := 'sql';
    if OpenDialog.Execute then
    begin
      Arquivo := TFileStream.Create(OpenDialog.FileName, fmOpenRead);
      Texto.LoadFromStream(Arquivo, TEncoding.UTF8);
      with TSQLQuery.Create(nil) do
      try
        DataBase := conectBancoDados;
        for Linha in Texto do
        begin
          if Trim(Linha) <> '' then
          begin
            SQL.Text := Linha;
            ExecSQL;
            writeln('Inserida linha ', Linha);
          end;
        end;
        transactionBancoDados.CommitRetaining;
        ShowMessage('Dados importados com sucesso!');
        Free;
      except
        on E: Exception do
          try
            raise Exception.Create('Erro ao inserir novos dados: ' +
              E.Message + sLineBreak + sLineBreak + 'Comando SQL: ' +
              sLineBreak + SQL.Text);
          finally
            Free;
          end;
      end;
    end;
  except
    on E: Exception do
    begin
      transactionBancoDados.RollbackRetaining;
      MessageDlg('Erro',
        'Erro ao importar os dados. Tente novamente. Se o problema persistir ' +
        'favor informar no GitHub com a seguinte mensagem: ' + sLineBreak +
        sLineBreak + E.Message, mtError, [mbOK], 0);
    end;
  end;
  OpenDialog.Free;
  Texto.Free;
  Arquivo.Free;
end;


procedure TformPrincipal.ReiniciarTodosOsQueries;
var
  qrPraReiniciar: TList;
  I: integer;
begin
  qrPraReiniciar := TList.Create;
  try
    qrPraReiniciar.Add(qrApostas);
    qrPraReiniciar.Add(qrBanca);
    qrPraReiniciar.Add(qrCompeticoes);
    qrPraReiniciar.Add(qrSituacao);
    qrPraReiniciar.Add(qrUnidades);
    qrPraReiniciar.Add(qrPerfis);
    qrPraReiniciar.Add(qrSelecionarPerfil);

    //qrApostas.ParamByName('mesSelecionado').AsInteger := MonthOf(Now);
    //qrApostas.ParamByName('anoSelecionado').AsInteger := YearOf(Now);

    for I := 0 to qrPraReiniciar.Count - 1 do
    begin
      if TSQLQuery(qrPraReiniciar[I]).Active then
        TSQLQuery(qrPraReiniciar[I]).Refresh;
      writeln('Reiniciado ', TComponent(qrPraReiniciar[I]).Name);
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
  end;
  AtualizaQRApostas;
  AtualizaOdd;
end;

procedure TformPrincipal.MenuItem7Click(Sender: TObject);
begin
  formSobre.ShowModal;
end;

procedure TformPrincipal.MenuItem8Click(Sender: TObject);
begin
  openurl('https://link.mercadopago.com.br/graxaimgestaodebanca');
end;

procedure TformPrincipal.miExportarClick(Sender: TObject);
begin

end;

procedure TformPrincipal.miImportarClick(Sender: TObject);
begin

end;

procedure TformPrincipal.pcPrincipalChange(Sender: TObject);
begin
end;

procedure TformPrincipal.qrApostasAfterOpen(DataSet: TDataSet);
begin
  qrApostas.Last;
end;

procedure TformPrincipal.qrApostasAfterPost(DataSet: TDataSet);
begin

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

end.
