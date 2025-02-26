unit untTutorial;

{$mode ObjFPC}
{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection, PQConnection, MSSQLConn, SQLite3Conn,
  DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, DBGrids, DBCtrls,
  Menus, ActnList, Buttons, ExtCtrls, TAGraph, TARadialSeries, TASeries, TADbSource,
  TACustomSeries, TAMultiSeries, DateUtils, untMain, fgl, Math;
  procedure IniciarTutorial;
type
  TTutorial = class(TformPrincipal)
  public
    procedure PassosTurorial;
    procedure FinalizarTutorial;
    function Abas(Numero: integer): TTabSheet;
    procedure CliqueBotao(Sender: TObject);
    procedure Retangulo(Sender: TObject);
  end;

var
  Tutorial:   TTutorial;
  PassoAtual: integer = 1;

implementation

uses untNA;

procedure IniciarTutorial;
begin
  if MessageDlg('Iniciar Tutorial', 'Parece que é a primeira vez utilizando o ' +
    'programa, deseja iniciar um tutorial de como usá-lo?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
    with formPrincipal do
    begin
      pnTutorial.Show;
      pbTutorial.Show;
      pbTutorial.Visible := True;
      Tutorial.PassosTurorial;
    end
  else
    MessageDlg('Informação', 'O tutorial pode ser iniciado a qualquer ' +
      'momento em Ajuda > Como Usar o Programa.', mtInformation, [mbOK], 0);
end;

procedure TTutorial.PassosTurorial;
begin
  with formPrincipal do
    case PassoAtual of
      1: begin
        Retangulo(lbValorBanca);
        mmTutorial.Text := 'Este é o valor inicial da tua banca, o primeiro ' +
          'valor antes de fazer qualquer aporte ou retirada.';
      end;
      2: begin
        Retangulo(lbValAporte);
        mmTutorial.Text := 'Essa é a diferença de valor entre aporte e retirada ' +
          'de dinheiro na tua banca. Se não houveram aportes, esse valor ficará ' +
          'negativo caso tenha retirado dinheiro.';
      end;
      3: begin
        Retangulo(lbValBancaTotal);
        mmTutorial.Text := 'Esse é o valor total da banca, considerando todos os ' +
          'aportes e retiradas até o mês atual, e o lucro dos meses anteriores';
      end;
      4: begin
        Retangulo(btnSalvarBancaInicial);
        mmTutorial.Text := 'Ao clicar nesse botão, abrirá um diálogo para ' +
          'digitar o valor inicial da banca, coforme dito no primeiro passo.';
      end;
    end;
end;

procedure TTutorial.CliqueBotao(Sender: TObject);
begin
  with formPrincipal do
  begin
    case TButton(Sender).Name of
      'btnTutorInicio': PassoAtual := 1;
      'btnTutorVolta': PassoAtual  := PassoAtual - 1;
      'btnTutorAvanca': PassoAtual := PassoAtual + 1;
      'btnTutorFechar': FinalizarTutorial;
    end;
    btnTutorInicio.Enabled := not (PassoAtual = 1);
    btnTutorVolta.Enabled  := not (PassoAtual = 1);
    btnTutorAvanca.Enabled := not (PassoAtual = 90);
  end;
end;

procedure TTutorial.Retangulo(Sender: TObject);
var
  Objeto: TControl;
begin
  with formPrincipal do
    with pbTutorial do
    begin
      Objeto := TControl(Sender);
      Parent := Abas(PassoAtual);
      BringToFront;
      Width  := Objeto.Width + 5;
      Height := Objeto.Height + 5;
      with Canvas do
      begin
        Pen.Color   := clRed;
        Brush.Style := bsClear;
        Rectangle(Objeto.Left + 5, Objeto.Top - 5, Objeto.Left + Objeto.Width + 5,
          Objeto.Top + Objeto.Height + 5);
      end;
    end;
end;

procedure TTutorial.FinalizarTutorial;
begin
  with formPrincipal do
  begin
    pnTutorial.Visible := False;
    pbTutorial.Visible := False;
  end;
  PassoAtual := 1;
end;

function TTutorial.Abas(Numero: integer): TTabSheet;
begin
  with formPrincipal do
  begin
    case Numero of
      1..14: Result  := tsPainel;
      15..21: Result := tsGraficos;
      22..24: Result := tsResumoLista;
      25..38: Result := tsApostas;
      39..47: Result := formNovaAposta.tsSimples;
      48..58: Result := formNovaAposta.tsMultipla;
      59..66: Result := tsGraficosMesMetodos;
      67..71: Result := tsDadosMesMetodos;
      72..77: Result := tsContrTimes;
      81..86: Result := tsContrPaises;
      87..90: Result := tsContrComp;
    end;
  end;
end;

end.
