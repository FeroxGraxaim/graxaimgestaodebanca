unit untSplash;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
StdCtrls;

type

{ TformSplash }

TformSplash = class(TForm)
  Image1:    TImage;
  Label1:    TLabel;
  Label2:    TLabel;
  lbProgresso: TLabel;
  progresso: TProgressBar;
  procedure FormActivate(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure FormShow(Sender: TObject);
private

public

end;

var
formSplash: TformSplash;

implementation

uses untMain, untUpdate, untApostas, untPainel, untDatabase, untMultipla,
untControleMetodos;

{$R *.lfm}

{ TformSplash }



procedure TformSplash.FormCreate(Sender: TObject);
begin
  Update;
end;

procedure TformSplash.FormActivate(Sender: TObject);
var
  EventosPainel:  TEventosPainel;
  BancoDados:     TBancoDados;
  EventosApostas: TEventosApostas;
  EventosMultiplas: TEventosMultiplas;
  EventosMetodos: TEventosMetodos;
begin
  with formPrincipal do
    begin
    Application.ProcessMessages;
    Show;
    Screen.Cursor := crHourGlass;
    progresso.Position := 0;
    lbProgresso.Caption := '';
    Application.ProcessMessages;
    progresso.Invalidate;
    sleep(50);

    //formPrincipal.PosAtualizacao;

    //Definindo eventos do painel
    writeln('Iniciando o programa');
    writeln('Criando eventos do tsPainel...');
    formPrincipal.tsPainel.OnShow     := @EventosPainel.tsPainelShow;
    formPrincipal.btnSalvarBancaInicial.OnClick :=
      @EventosPainel.btnSalvarBancaInicialClick;
    formPrincipal.cbPerfil.OnChange   := @EventosPainel.cbPerfilChange;
    formPrincipal.edtBancaInicial.OnKeyPress := @EventosPainel.edtBancaInicialKeyPress;
    formPrincipal.cbMes.OnChange      := @EventosPainel.cbMesChange;
    formPrincipal.cbAno.OnChange      := @EventosPainel.cbAnoChange;
    formPrincipal.cbGraficos.OnChange := @EventosPainel.cbGraficosChange;

    progresso.Position := 14;
    lbProgresso.Caption := 'Atribuindo eventos de apostas';
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

    //Definindo eventos das Apostas

    writeln('Criando eventos do tsApostas...');
    formPrincipal.tsApostas.OnShow      := @EventosApostas.tsApostasShow;
    formPrincipal.btnRemoverAposta.OnClick := @EventosApostas.btnRemoverApostaClick;
    formPrincipal.btnNovaAposta.OnClick := @EventosApostas.btnNovaApostaClick;
    //formPrincipal.btnAtualizaApostas.OnClick := @EventosApostas.btnAtualizaApostasClick;
    grdDadosAp.OnDrawColumnCell := @EventosAPostas.grdDadosApDrawColumnCell;
    grdApostas.OnCellClick := @EventosApostas.grdApostascellClick;
    btnCashout.OnClick := @EventosApostas.btnCashoutClick;
    qrApostas.OnCalcFields := @EventosApostas.qrApostasCalcFields;
    btnFiltrarAp.OnClick := @EventosApostas.FiltrarAposta;
    btnLimparFiltroAp.OnClick := @EventosApostas.LimparFiltros;

    //Definindo eventos do controle de métodos

    lsbMetodos.OnClick := @EventosMetodos.lsbMetodosClick;
    lsbLinhas.OnClick := @EventosMetodos.lsbLinhasClick;
    btnNovoMetodo.OnClick := @EventosMetodos.NovoMetodo;
    btnExcluirMetodo.OnClick := @EventosMetodos.RemoverMetodo;
    tsDadosMesMetodos.OnShow := @EventosMetodos.GridMesMetodos;
    grdMetodosMes.OnClick := @EventosMetodos.GridMesLinhas;
    tsDadosAnoMetodos.OnShow := @EventosMetodos.GridAnoMetodos;
    grdMetodosAno.OnClick := @EventosMetodos.GridAnoLinhas;
    btnNovaLinha.OnClick := @EventosMetodos.NovaLinha;
    btnExcluirLinha.OnClick := @EventosMetodos.RemoverLinha;

    //Definindo eventos do do Banco de Dados e Múltiplas


    progresso.Position := 28;
    lbProgresso.Caption := 'Atribuindo eventos de múltiplas';
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

    writeln('Criando eventos do banco de dados...');
    formPrincipal.qrBanca.OnCalcFields := @BancoDados.qrBancaCalcFields;

    progresso.Position := 42;
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

    if conectBancoDados.Connected then conectBancoDados.Close;

    // Quando for compilar a release, descomentar a linha abaixo

    @BancoDados.LocalizarBancoDeDados;
    formPrincipal.conectBancoDados.Open;

    // Definindo a variável perfilInvestidor

    progresso.Position := 57;
    lbProgresso.Caption := 'Definindo variáveis';
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

    perfilInvestidor := formPrincipal.qrSelecionarPerfil.FieldByName(
      'Perfil Selecionado').AsString;
    DefinirStake;

    //Procedimentos do Painel Principal

    progresso.Position := 71;
    lbProgresso.Caption := 'Atribuindo procedimentos do painel principal';
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

      @EventosPainel.PreencherComboBox;
      lbProgresso.Caption := 'Preenchidos ComboBoxes';
      Application.ProcessMessages;
      @EventosPainel.AtualizaMesEAno;
      lbProgresso.Caption := 'Atualizados mês e ano';
      Application.ProcessMessages;
      @EventosPainel.PreencherBancaInicial;
      lbProgresso.Caption := 'Preenchida banca inicial';
      Application.ProcessMessages;
      @EventosPainel.PerfilDoInvestidor;
      lbProgresso.Caption := 'Executado procedimento de perfil do investidor';
      Application.ProcessMessages;
      DefinirStake;
      lbProgresso.Caption := 'Definida stake';
      Application.ProcessMessages;

      lbProgresso.Caption := 'Iniciando os queries';
      Application.ProcessMessages;

      qrBanca.Open;
      qrPerfis.Open;
      qrSelecionarPerfil.Open;

    //Procedimentos das apostas

    progresso.Position := 85;
    lbProgresso.Caption := 'Atribuindo procedimentos de apostas';
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;
    @EventosApostas.AtualizaApostas;

    //Procedimentos de métodos

    @EventosMetodos.CarregaMetodos;

    //Procedimentos das múltiplas

    progresso.Position := 100;
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;

    if not conectBancoDados.Connected then conectBancoDados.Connected := True;
      begin
      @EventosMultiplas.CarregaContadorNovaMultipla;
      end;

    writeln('Iniciados todos os queries');
    progresso.Position := 100;
    lbProgresso.Caption := 'Carregamento concluído, iniciando o programa';
    writeln('Movida barra de progresso');
    Application.ProcessMessages;
    sleep(50);
    progresso.Invalidate;
    end;
  Screen.Cursor := crDefault;
  lbProgresso.Caption := 'Verificando se há atualizações';
  Application.ProcessMessages;
  VerificarAtualizacoes(currentVersion);
  Close;
end;

procedure TformSplash.FormShow(Sender: TObject);
begin
  Update;
end;

end.
